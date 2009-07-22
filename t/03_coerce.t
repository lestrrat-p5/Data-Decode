use strict;
use Test::More (tests => 4);
use Test::Exception;

use Data::Decode;

lives_ok {
    my $decoder = Data::Decode->new(decoder => [ 'Encode::HTTP::Response', 'Encode::Guess' ]);
    isa_ok( $decoder->decoder, 'Data::Decode::Chain' );
    my $decoders = $decoder->decoder->decoders;

    isa_ok( $decoders->[0], 'Data::Decode::Encode::HTTP::Response');
    isa_ok( $decoders->[1], 'Data::Decode::Encode::Guess');
};
