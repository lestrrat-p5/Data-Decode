package Data::Decode::Types;
use Moose::Util::TypeConstraints;
use namespace::clean -except => qw(meta);

subtype 'Data::Decode::Decoder'
    => as 'Object'
    => where { $_->can('decode') }
    => message {
        "$_ does not implement a method named decode()"
    }
;

coerce 'Data::Decode::Decoder'
    => from 'ArrayRef',
    => via {
        Data::Decode::Chain->new(decoders => $_)
    }
;

1;
