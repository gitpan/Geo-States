use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;

use_ok( "Geo::States" );

throws_ok {
    Geo::States->new( 'Narnia' );
} qr/Supported country/;
