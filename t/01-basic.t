#!/usr/bin/perl

use Test::More tests => 6;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Schema;
my $rs = Schema->connect->resultset('Item');

ok($rs->can('count_or_create'));
ok($rs->can('count_for_update_or_create'));

#### test count_or_create
# row isn't there
my $rtn = $rs->count_or_create( { id => 1, name => 'A' } );
ok $rtn;
is $rtn->id, 1;
is $rtn->name, 'A';

$rtn = $rs->count_or_create( { id => 1, name => 'A' } );
is $rtn, 0;

1;