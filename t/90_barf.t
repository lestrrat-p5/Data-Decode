use strict;
use Test::More (tests => 1);
use Test::Exception;
use Data::Decode
    qw(Chain Encode::Guess Encode::Guess::JP Encode::HTTP::Response);
use LWP::UserAgent;

lives_ok {

my $decoder = Data::Decode->new(
    decoder => Data::Decode::Chain->new(
        decoders => [
            Data::Decode::Encode::HTTP::Response->new(),
            Data::Decode::Encode::Guess->new(
                encodings => [qw(euc-jp sjis jis utf8)]
            ),
            Data::Decode::Encode::Guess::JP->new(),
        ]
    )
);

my $url = "http://cpansearch.perl.org/src/DMAKI/Data-Decode-0.00006/t/encode/02_guess_jp.t";

#my $url = "http://www.goo.ne.jp";
#my $url = "http://mt.endeworks.jp/d-6/2007/11/datadecode.html";
#my $url = "http://yahoo.com";
#my $url = 'http://wpedia.goo.ne.jp/wiki/%E8%83%83';

my $ua  = LWP::UserAgent->new;
my $req = HTTP::Request->new( GET => $url );
my $res = $ua->request($req);

my $content = $decoder->decode( $res->content, { response => $res } );
};
