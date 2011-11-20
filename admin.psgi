use strict;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;

use MyBBS::Admin;
use Plack::App::File;
use Plack::Session::Store::DBI;
use DBI;

my $basedir = File::Spec->rel2abs(dirname(__FILE__));
my $db_config = MyBBS->config->{DBI} || die "Missing configuration for DBI";
{
    my $c = MyBBS->new();
    $c->setup_schema();
}
builder {
    enable 'Plack::Middleware::Auth::Basic',
        authenticator => sub { $_[0] eq 'admin' && $_[1] eq 'admin' };
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/robots\.txt|/favicon\.ico)$},
        root => File::Spec->catdir(dirname(__FILE__), 'static', 'adin');
    enable 'Plack::Middleware::ReverseProxy';
    enable 'Plack::Middleware::Session',
        store => Plack::Session::Store::DBI->new(
            get_dbh => sub {
                DBI->connect( @$db_config )
                    or die $DBI::errstr;
            }
        );

    mount '/static/' => Plack::App::File->new(root => File::Spec->catdir($basedir, 'static', 'admin'));
    mount '/' => MyBBS::Admin->to_app();
};
