use strict;
use inc::Module::Install;

name('Data-Decode');
all_from('lib/Data/Decode.pm');

requires 'Moose';
requires 'MooseX::AttributeHelpers';
requires 'MooseX::NonMoose';
requires('Encode');
requires('Encode::Guess');
requires('Exception::Class');
requires('HTML::Parser');
requires('HTTP::Response::Encoding');

tests('t/*.t t/*/*.t');

auto_install;
WriteAll;