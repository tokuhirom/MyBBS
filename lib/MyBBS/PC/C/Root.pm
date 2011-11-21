package MyBBS::PC::C::Root;
use strict;
use warnings;
use utf8;

sub index {
    my ($class, $c) = @_;
    my $page = $c->req->param('page') || 1;
    my ($entries, $pager) = $c->db->search_with_pager('entry' => {}, {order_by => 'id DESC', page => $page, rows => 20});
    $c->render('index.tt', { entries => $entries, pager => $pager });
}

1;
