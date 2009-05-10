#!/usr/bin/perl

use Test::More tests => 1;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Schema;
my $rs = Schema->connect->resultset('Item');

ok(1);

1;