package Data::Decode::Types;
use Moose::Util::TypeConstraints;
use namespace::clean -except => qw(meta);

subtype 'Data::Decode::Decoder'
    => as 'Object'
    => where { $_->can('decode') }
;

1;
