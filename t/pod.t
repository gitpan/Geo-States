use strict;
use warnings;

use Test::More;

eval 'use Test::Pod::Coverage';
plan skip_all => 'Test::POD::Coverage required for POD testing' if $@;

plan tests => 1;
pod_coverage_ok('Geo::States', {trustme => [qr/^(?:new|find)$/]}, 'POD looks good');
