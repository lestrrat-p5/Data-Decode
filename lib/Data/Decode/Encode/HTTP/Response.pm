
package Data::Decode::Encode::HTTP::Response;
use Moose;
use namespace::clean -except => qw(meta);
use Data::Decode::Exception;
use Data::Decode::Util qw(try_decode pick_encoding);
use Encode();

has parser => (
    is => 'ro',
    isa => 'Data::Decode::Encode::HTTP::Response::Parser',
    lazy_build => 1,
);

sub _build_parser {
    require Data::Decode::Encode::HTTP::Response::Parser;
    return Data::Decode::Encode::HTTP::Response::Parser->new();
}

sub decode {
    my ($self, $decoder, $string, $hints) = @_;

    if (! $hints->{response} || ! eval { $hints->{response}->isa('HTTP::Response') }) {
        Data::Decode::Exception::Deferred->throw;
    }
    my $res = $hints->{response};

    my $decoded;
    { # Attempt to decode from header information
        my $from_header;
        if ( ($res->header('Content-Type') || '') =~ /charset=([\w\-_]+)/i ) {
            $from_header = $1;
        }
        my $encoding = pick_encoding( $from_header );
        $decoded = try_decode($encoding, $string);
        return $decoded if $decoded;
    }

    { # Attempt to decode from meta information
        my $p = $self->parser();
        my $encoding = pick_encoding(
            $p->extract_encodings( $res->content )
        );
        $decoded = try_decode($encoding, $string);
        return $decoded if $decoded;
    }

    Data::Decode::Exception::Deferred->throw;
}

1;

__END__

=head1 NAME

Data::Decode::Encode::HTTP::Response - Get Encoding Hints From HTTP::Response

=head1 METHODS

=head2 new

=head2 decode

=head2 parser

=cut