#!/usr/bin/perl

use Test::More;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

BEGIN {

    eval { require SQL::Translator }
        or plan skip_all => "SQL::Translator is required for this test";

    eval { require IO::Scalar }
        or plan skip_all => "IO::Scalar is required for this test";

    plan tests => 16;
};

use Schema;
my $rs = Schema->connect->resultset('Item');

{   # new, with void context
    $rs->find_or_create( { id => 1, name => 'A' } );
#    diag($Schema::ioscalar);
    ok( $Schema::ioscalar =~ /SELECT\s+1\s+/ );
    my $row = $rs->find(1);
    ok($row);
    is $row->id, 1;
    is $row->name, 'A';
    
    $Schema::ioscalar = '';
    $rs->update_or_create( { id => 1, name => 'B' } );
    ok( $Schema::ioscalar =~ /SELECT\s+1\s+/ );
    $row = $rs->find(1);
    ok($row);
    is $row->id, 1;
    is $row->name, 'B';
}

{   # old, with context
    $Schema::ioscalar = '';
    my $row = $rs->find_or_create( { id => 2, name => 'A' } );
    ok( $Schema::ioscalar !~ /SELECT\s+1\s+/ );
    ok($row);
    is $row->id, 2;
    is $row->name, 'A';
    
    $Schema::ioscalar = '';
    $row = $rs->update_or_create( { id => 2, name => 'B' } );
    ok( $Schema::ioscalar !~ /SELECT\s+1\s+/ );
    ok($row);
    is $row->id, 2;
    is $row->name, 'B';
}

1;