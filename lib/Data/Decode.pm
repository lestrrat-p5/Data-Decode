package Data::Decode;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::clean -except => qw(meta);
use Data::Decode::Exception;
use Data::Decode::Types;

our $VERSION = '0.00007_01';

has decoder => (
    is => 'ro',
    isa => 'Data::Decode::Decoder',
    required => 1,
    coerce => 1,
);

sub import {
    my ( $self, @modules ) = @_;

    foreach my $class (@modules) {
        if ($class !~ s/^\+//) {
            $class = "Data::Decode::$class";
            Class::MOP::load_class($class);
        }
    }
}

sub decode {
    my ($self, $data, $hints) = @_;

    return () unless defined $data;
    $hints ||= {};

    my $ret = eval {
        $self->decoder->decode($self, $data, $hints);
    };
    my $e;
    if ($e = Data::Decode::Exception::Deferred->caught() ) {
        # Just deferred. return ()
        return ();
    } elsif ( $e = Exception::Class->caught() ) {
        # Oh, this we re-throw
        eval { $e->isa('Data::Decode::Exception') } ?
            $e->rethrow : die $e;
    }
    return $ret;
}

1;

__END__

=head1 NAME

Data::Decode - Pluggable Data Decoder

=head1 SYNOPSIS

  # simple usage (you probably won't use this form much)
  use Data::Decode qw( Encode::Guess );

  my $decoder = Data::Decode->new(
    decoder => Data::Decode::Encode::Gues->new()
  );
  $decoder->decode($data);

  # cascading several decoders
  use Data::Decode
    qw( HTTP::Response Encode::Guess );

  my $decoder = Data::Decode->new(
    decoder => [
      Data::Decode::Encode::HTTP::Response->new(),
      Data::Decode::Encode::Guess->new(),
    ]
  );

  my $res = LWP::UserAgent->new->get("http://whatever.example.com");

  my $decoded = $decoder->decode($res->content, { response => $res });

=head1 DESCRIPTION

Data::Decode implements a pluggable "decoder". The main aim is to provide
a uniform interface to decode a given data while allowing the actual
algorithm being used to be changed depending on your needs..

For now this is aimed at decoding miscellaneous text to perl's internal 
unicode encoding, but should be able to handle anything if you give it a 
proper plugin

=head1 DECODING TO UNICODE

Japanese, which is the language that I mainly deal with, has an annoying
property: It can come in at least 4 different flavors (utf-8, shift-jis,
euc-jp and iso-2022-jp). Even worse, vendors may have more vendor-specific 
symbols, such as the pictograms in mobile phones.

Ways to decode these strings into unicode varies between each environment 
and application.

Many modules require that the strings be normalized to unicode, but they
all handle this normalization process differently, which is, well, not exactly
an optimal solution.

Data::Decode provides a uniform interface to this problem, and a few common
ways decoding is handled. The actual decoding strategies are separated out
from the surface interface, so other users who find a particular strategy to
decode strings can then upload their way to CPAN, and everyone can benefit
from it.

=head1 CASCADING 

Data::Decode comes with a simple chaining functionality. You can take as many
decoders as you want, and you can stack them on top of each other. To enable
this feature, just provide an array as the decoder, instead of a single object.

=head1 METHODS

=head2 new

Instantiates a new Data::Decode object.

=over 4

=item decoder

Required. Takes in the object that encapsulates the actual decoding logic.

(WARNING: Subject to change - we may require an object that implements a role
instead of just a function in the future. Beware!) The object must have a 
method named "decode", which takes in a reference to the Data::Decode object 
and a string to be decoded. An optional third parameter may be provided to 
specify any hints that could be used to figure out what to do. 

  # a decode() method
  sub decode {
    my ($self, $decoder, $string, $hints) = @_;
    # $decoder = Data::Decode object
    # $string  = a scalar to be decoded
    # $hints   = a hashref of hints
  }

You may also specify the class names of the decoders -- in that case, an 
argument-less new() will be called upon the class name to instantiate the
decoder.

If you provide a list of decoders, Data::Decode::Chain will automatically be
set for you.

  my $decoder = Data::Decode->new(
    decoder => [  # This will turn into a Data::Decode::Chain object
      Decoder1->new(),
      Decoder2->new(),
      Decoder3->new(),
      ...
    ]
  );

=back

=head2 decode

Decodes a string. Takes in a string, and a hashref of hints to be used
for decoding. The meaning or the usage of the hints may differ between 
the actual underlying decoders.

=head2 decoder

Get the underlying decoder object.

=head1 AUTHOR

Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut