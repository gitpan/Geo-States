use strict;
use warnings;

use Test::More tests => 11;
use Test::NoWarnings;

use_ok('Geo::States');

my $us = Geo::States->new('US');
isa_ok($us, 'Geo::States');

isa_ok($us->find('ny'), 'Geo::States::ny');
isa_ok($us->find('new york'), 'Geo::States::new::york');

is($us->find('TN')->text, 'Tennessee', 'Lookup for TN returns Tennessee');
is($us->find('tn')->text, 'Tennessee', 'Lookup for tn returns Tennessee');

is($us->find('Tennessee')->text, 'TN', 'Lookup for Tennessee returns TN');
is($us->find('tennessee')->text, 'TN', 'Lookup for tennessee returns TN');

is($us->find('Tennessee')->capital, 'Nashville', q<Tennessee's capital is Nashville>);

is($us->find('foobar'), undef, 'Lookup for foobar returns undef');

