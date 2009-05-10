#!/usr/bin/perl

use Test::More tests => 6;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Schema;
my $rs = Schema->connect->resultset('Item');

$rs->find_or_create( { id => 1, name => 'A' } );
my $row = $rs->find(1);
ok($row);
is $row->id, 1;
is $row->name, 'A';

$rs->update_or_create( { id => 1, name => 'B' } );
$row = $rs->find(1);
ok($row);
is $row->id, 1;
is $row->name, 'B';

1;