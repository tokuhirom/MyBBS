package MyBBS::PC::C::Entry;
use strict;
use warnings;
use utf8;

sub create {
    my ($class, $c) = @_;
    if (my $body = $c->request->param('body')) {
        $c->db->insert(
            'entry' => {
                body => $body,
            }
        );
    }
    return $c->redirect('/');
}

1;

