package Geo::States;

use strict;
use warnings;

use utf8;
use Carp ();

our $VERSION = '0.04';

# first, our giant data structure
our %state_abbr = (
    us => {
        al => {text => 'Alabama',        capital => 'Montgomery'},
        ak => {text => 'Alaska',         capital => 'Juneau'},
        as => {text => 'American Samoa', capital => 'Pago Pago'},
        az => {text => 'Arizona',        capital => 'Phoenix'},
        ar => {text => 'Arkansas',       capital => 'Little Rock'},
        ca => {text => 'California',     capital => 'Sacramento'},
        co => {text => 'Colorado',       capital => 'Denver'},
        ct => {text => 'Connecticut',    capital => 'Hartford'},
        de => {text => 'Delaware',       capital => 'Dover'},
        dc => {text => 'District of Columbia', capital => undef },
        fl => {text => 'Florida',        capital => 'Tallahassee'},
        ga => {text => 'Georgia',        capital => 'Atlanta'},
        gu => {text => 'Guam',           capital => 'Hagåtña'},
        hi => {text => 'Hawaii',         capital => 'Honolulu'},
        id => {text => 'Idaho',          capital => 'Boise'},
        il => {text => 'Illinois',       capital => 'Springfield'},
        in => {text => 'Indiana',        capital => 'Indianapolis'},
        ia => {text => 'Iowa',           capital => 'Des Moines'},
        ks => {text => 'Kansas',         capital => 'Topeka'},
        ky => {text => 'Kentucky',       capital => 'Frankfort'},
        la => {text => 'Louisiana',      capital => 'Baton Rouge'},
        me => {text => 'Maine',          capital => 'Augusta'},
        md => {text => 'Maryland',       capital => 'Annapolis'},
        ma => {text => 'Massachusetts',  capital => 'Boston'},
        mi => {text => 'Michigan',       capital => 'Lansing'},
        mn => {text => 'Minnesota',      capital => 'St. Paul'},
        ms => {text => 'Mississippi',    capital => 'Jackson'},
        mo => {text => 'Missouri',       capital => 'Jefferson City'},
        mt => {text => 'Montana',        capital => 'Helena'},
        ne => {text => 'Nebraska',       capital => 'Lincoln'},
        nv => {text => 'Nevada',         capital => 'Carson City'},
        nh => {text => 'New Hampshire',  capital => 'Concord'},
        nj => {text => 'New Jersey',     capital => 'Trenton'},
        nm => {text => 'New Mexico',     capital => 'Santa Fe'},
        ny => {text => 'New York',       capital => 'Albany'},
        nc => {text => 'North Carolina', capital => 'Raleigh'},
        nd => {text => 'North Dakota',   capital => 'Bismarck'},
        mp => {text => 'Northern Mariana Islands', capital => 'Capitol Hill'},
        oh => {text => 'Ohio',           capital => 'Columbus'},
        ok => {text => 'Oklahoma',       capital => 'Oklahoma City'},
        or => {text => 'Oregon',         capital => 'Salem'},
        pa => {text => 'Pennsylvania',   capital => 'Harrisburg'},
        pr => {text => 'Puerto Rico',    capital => 'San Juan'},
        ri => {text => 'Rhode Island',   capital => 'Providence'},
        sc => {text => 'South Carolina', capital => 'Columbia'},
        sd => {text => 'South Dakota',   capital => 'Pierre'},
        tn => {text => 'Tennessee',      capital => 'Nashville'},
        tx => {text => 'Texas',          capital => 'Austin'},
        ut => {text => 'Utah',           capital => 'Salt Lake City'},
        vi => {text => 'Virgin Islands', capital => 'Charlotte Amalie'},
        vt => {text => 'Vermont',        capital => 'Montpelier'},
        va => {text => 'Virginia',       capital => 'Richmond'},
        wa => {text => 'Washington',     capital => 'Olympia'},
        wv => {text => 'West Virginia',  capital => 'Charleston'},
        wi => {text => 'Wisconsin',      capital => 'Madison'},
        wy => {text => 'Wyoming',        capital => 'Cheyenne'},
    },
    ca => {
        ab => {text => 'Alberta',                   capital => 'Edmonton'},
        bc => {text => 'British Columbia',          capital => 'Victoria'},
        mb => {text => 'Manitoba',                  capital => 'Winnipeg'},
        nb => {text => 'New Brunswick',             capital => 'Fredericton'},
        nl => {text => 'Newfoundland and Labrador', capital => q<St. John's>},
        ns => {text => 'Nova Scotia',               capital => 'Halifax'},
        nt => {text => 'Northwest Territories',     capital => 'Yellowknife'},
        nu => {text => 'Nunavut',                   capital => 'Iqaluit'},
        on => {text => 'Ontario',                   capital => 'Toronto'},
        pe => {text => 'Prince Edward Island',      capital => 'Charlottetown'},
        qc => {text => 'Quebec',                    capital => 'Quebec City'},
        sk => {text => 'Saskatchewan',              capital => 'Regina'},
        yt => {text => 'Yukon',                     capital => 'Whitehorse'},
    },
);

our %state_name;
our %objects;

sub new {
    my ($class, $country) = @_;

    Carp::croak 'Usage: Geo::States->new($COUNTRY)' unless $country;

    $country = lc($country);

    Carp::croak "Supported country codes include US and CA"
        unless $country eq 'us' or $country eq 'ca';

    # we already have a hash written, this code will
    #   build the same hash with the names and abbrv. swapped
    while (my ($key, $val) = each %{$state_abbr{$country}}) {
        $state_name{$country}{lc($val->{text})} = {text => uc($key), capital => $val->{capital}};
    }

    bless({country => $country}, $class);
}

# I've done some hackery here. you can decide if it's good or bad
# I want to access the find() function like an object
#
# This is because I think this syntax is nice:
# say $geo->find('TN')->text
sub find {
    my $self  = shift;
    my $state = shift or return undef;

    my $country = $self->{country};

    $state = lc($state);

    # if we have already blessed code for this state, return it
    # this avoids redefining the same subroutines
    return $objects{$state} if $objects{$state};

    my $data = length($state) == 2 ?    #
      $state_abbr{$country}{$state}
      : $state_name{$country}{$state}
      or return undef;

    $state =~ s/\s/::/g;
    my $class = ref($self) . "::$state";

    # and basically here I've done something similar
    #   to what I read in the Mojo::Base attributes code
    # I make my own class with methods (text and capital), bless and return
    my $code = "package $class;\n";
    for my $sub (keys %$data) {
        $code .= "sub $sub { '$data->{$sub}' };\n";
    }
    eval "$code;1" or Carp::croak "Geo::States error: $@";
    my $ref = bless(\$code, $class);
    $objects{$state} = $ref;
    $ref;
}

1;
__END__

=encoding utf-8

=head1 NAME

Geo::States - Lookup states and capitals by state names or abbreviations

=head1 SYNOPSIS

  use Geo::States;

  my $COUNTRY = 'US' || 'CA';
  my $geo = Geo::States->new($COUNTRY);

  say $geo->find('TN')->text;        # Tennessee
  say $geo->find('Tennessee')->text; # TN
  say $geo->find('TN')->capital;     # Nashville

=head1 DESCRIPTION

Geo::States will find a US or Canadian state/province (by name or
abbreviation) and return an object with two subroutines:

=over

=item text()

The text of the state.  If given full name, text() will return
the abbreviation, and vice versa.

=item capital()

Returns the capital name of the given state

=back

=head1 AUTHOR

Curtis Brandt E<lt>curtis@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (C) <2014> Curtis Brandt <curtis@cpan.org>

=head1 LICENSE

MIT license.  See LICENSE file for details.

=cut
