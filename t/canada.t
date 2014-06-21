use strict;
use warnings;

use Test::More tests => 11;
use Test::NoWarnings;

use_ok('Geo::States');

my $ca = Geo::States->new('CA');
isa_ok($ca, 'Geo::States');

isa_ok($ca->find('bc'), 'Geo::States::bc');
isa_ok($ca->find('british columbia'), 'Geo::States::british::columbia');

is($ca->find('AB')->text, 'Alberta', 'Lookup for AB returns Alberta');
is($ca->find('ab')->text, 'Alberta', 'Lookup for ab returns Alberta');

is($ca->find('Alberta')->text, 'AB', 'Lookup for Alberta returns AB');
is($ca->find('alberta')->text, 'AB', 'Lookup for alberta returns AB');

is($ca->find('Alberta')->capital, 'Edmonton', q<Alberta's capital is Edmonton>);

is($ca->find('foobar'), undef, 'Lookup for foobar returns undef');
