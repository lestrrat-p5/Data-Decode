package Data::Decode::Encode::Guess::JP;
use Moose;
use namespace::clean -except => qw(meta);

extends 'Data::Decode::Encode::Guess';

sub _build_encodings {
    return [ qw(shiftjis euc-jp 7bit-jis utf8) ];
}

1;

__END__

=head1 NAME

Data::Decode::Encode::Guess::JP - Generic Encode::Guess For Japanese Encodings

=head1 SYNOPSIS

  Data::Decode->new(
    decoder => Data::Decode::Encode::Guess::JP->new()
  );

=head1 METHODS

=head2 new

=cut