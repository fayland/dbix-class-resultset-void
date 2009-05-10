#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok('DBIx::Class::ResultSetX::Count');
}

diag(
"Testing DBIx::Class::ResultSetX::Count $DBIx::Class::ResultSetX::Count::VERSION, Perl $], $^X"
);
