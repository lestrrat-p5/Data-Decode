use strict;
use inc::Module::Install;

name('Data-Decode');
all_from('lib/Data/Decode.pm');

requires 'Moose';
requires 'MooseX::AttributeHelpers';
requires 'MooseX::NonMoose';
requires 'namespace::clean';
requires 'Encode';
requires 'Encode::Guess';
requires 'Exception::Class';
requires 'HTML::Parser';

test_requires 'Test::More';
test_requires 'Test::Exception';

tests('t/*.t t/*/*.t');

WriteAll;