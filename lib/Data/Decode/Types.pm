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
        Class::MOP::load_class('Data::Decode::Chain');
        Data::Decode::Chain->new(decoders => $_)
    }
;

subtype 'Data::Decode::DecoderList'
    => as 'ArrayRef[Data::Decode::Decoder]'
;

coerce 'Data::Decode::DecoderList'
    => from 'ArrayRef'
    => via {
        my @list = @$_;
        return [
            map {
                Class::MOP::blessed $_ ? $_ :
                do {
                    if (!s/^\+//) {
                        $_ = "Data::Decode::$_";
                    }
                    Class::MOP::load_class($_);
                    $_->new();
                }
            } @list
        ]
    }
;

1;
