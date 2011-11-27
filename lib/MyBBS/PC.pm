package MyBBS::PC;
use strict;
use warnings;
use utf8;
use parent qw(MyBBS Amon2::Web);
use File::Spec;

# dispatcher
use MyBBS::PC::Dispatcher;
sub dispatch {
    return MyBBS::PC::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

# setup view class
use Text::Xslate;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        $view_conf->{path} = [ File::Spec->catdir(__PACKAGE__->base_dir(), 'tmpl/pc') ];
    }
    my $view = Text::Xslate->new(+{
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::Star' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
            static_file => do {
                my %static_file_cache;
                sub {
                    my $fname = shift;
                    my $c = Amon2->context;
                    if (not exists $static_file_cache{$fname}) {
                        my $fullpath = File::Spec->catfile($c->base_dir(), $fname);
                        $static_file_cache{$fname} = (stat $fullpath)[9];
                    }
                    return $c->uri_for($fname, { 't' => $static_file_cache{$fname} || 0 });
                }
            },
        },
        %$view_conf
    });
    sub create_view { $view }
}


# load plugins
use File::Path qw(mkpath);
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::CSRFDefender',
);
use Log::Minimal;
__PACKAGE__->load_plugin(
    'Web::Auth' => {
        module      => 'Twitter',
        on_finished => sub {
            my ($c, $access_token, $access_token_secret, $user_id, $screen_name)
                                    = @_;
            my $member = $c->db->single(
                member => {
                twitter_user_id => $user_id,
                }
            );
            if (!$member) {
                # register
                $member = $c->db->insert(
                    member => {
                        nickname                    => $screen_name,
                        twitter_access_token        => $access_token,
                        twitter_access_token_secret => $access_token_secret,
                        twitter_user_id             => $user_id,
                        twitter_screen_name         => $screen_name,
                        ctime                       => time(),
                    }
                );
            }
            $c->session->set(member_id => $member->id);
            return $c->redirect;
        },
        on_error => sub {
            my ( $c, $errmsg ) = @_;
            critf( "Twitter error: %s", $errmsg );
            return $c->show_error(
                'Twitter returned error response... Please try again later...');
        },
    },
);
sub session_member {
    my $c = shift;
    if (my $member_id = $c->session->get('member_id')) {
        return $c->db->single(member => {id => $member_id});
    } else {
        return;
    }
}

sub show_error {
    my ($c, $msg, $code) = @_;
    my $res = $c->render('error.tt', {message => $msg});
    $res->code($code || 500);
    return $res;
}

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

1;
