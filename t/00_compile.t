use strict;
use warnings;
use Test::More;

use_ok $_ for qw(
    MyBBS
    MyBBS::PC
    MyBBS::PC::Dispatcher
    MyBBS::PC::C::Root
    MyBBS::PC::C::Account
    MyBBS::Admin
    MyBBS::Admin::Dispatcher
    MyBBS::Admin::C::Root
);

done_testing;
