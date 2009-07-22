
package Data::Decode::Chain;
use Moose;
use MooseX::AttributeHelpers;
use namespace::clean -except => qw(meta);
use Data::Decode::Exception;
use Data::Decode::Types;

has decoders => (
    metaclass => 'Collection::Array',
    is => 'ro',
    isa => 'Data::Decode::DecoderList',
    required => 1,
    coerce => 1,
    provides => {
        elements => 'all_decoders',
    }
);

sub decode {
    my ($self, $decoder, $string, $hints) = @_;

    my $ret;
    foreach my $decoder ($self->all_decoders) {
        $ret = eval {
            $decoder->decode($decoder, $string, $hints);
        };
        my $e;
        if ($e = Data::Decode::Exception::Deferred->caught() ) {
            # Decoding was deffered, we don't do anything about this
            # error, and simply let the next decoder attempt to handle
            # this particular set of inputs.
            next;
        } elsif ( $e = Exception::Class->caught() ) {
            # This is a generic error, just propagate it
            eval { $e->isa('Data::Decode::Exception') } ?
                $e->rethrow : die $e;
        }
        last;
    }

    return $ret;
}

1;

__END__

=head1 NAME

Data::Decode::Chain - Chain Multiple Decoders

=head1 SYNOPSIS

  Data::Decode->new(
    strategy => Data::Decode::Chain->new(
      decoders => [
        Data::Decode::Whatever->new,
        Data::Decode::SomethingElse->new
      ]
    )
  );

=head1 METHODS

=head2 new

=head2 decode

=cut