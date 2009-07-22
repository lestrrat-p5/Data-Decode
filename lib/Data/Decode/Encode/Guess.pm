
package Data::Decode::Encode::Guess;
use Moose;
use namespace::clean -except => qw(meta);
use Encode();
use Encode::Guess();

has encodings => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy_build => 1,
);

sub _build_encodings {
    return [];
}

sub guess_encoding {
    my ($self, $decoder, $string, $hints) = @_;
    local $Encode::Guess::NoUTFAutoGuess = 1;
    return Encode::Guess::guess_encoding(
        $string,
        @{ $self->encodings }
    );
}

sub decode {
    my ($self, $decoder, $string, $hints) = @_;

    my $guess = $self->guess_encoding($decoder, $string, $hints);
    if (! ref $guess) {
        Data::Decode::Exception::Deferred->throw($guess);
    }

    return eval { $guess->decode( $string ) } ||
        Data::Decode::Exception::Deferred->throw("Failed to decode string from " . $guess->name . ": $@")
    ;
}

1;

__END__

=head1 NAME

Data::Decode::Encode::Guess - Generic Encode::Guess Decoder

=head1 SYNOPSIS

  Data::Decode->new(
    strategy => Data::Decode::Encode::Guess->new(
      encodings => [ $enc1, $enc2, $enc3 ]
    )
  );

=head1 METHODS

=head2 new

=head2 decode

=cut
