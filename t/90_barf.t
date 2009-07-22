use strict;
use Test::More;
use Test::Exception;
use Data::Decode
    qw(Chain Encode::Guess Encode::Guess::JP Encode::HTTP::Response);

BEGIN {
    require IO::Socket;

    my $socket = IO::Socket::INET->new(PeerPort => 80, PeerHost => "wpedia.goo.ne.jp");
    if (! $socket) {
        plan(skip_all => "This test requires internet connectivity");
    } else {
        eval "require LWP::UserAgent";
        if ($@) {
            plan(skip_all => "This test requires LWP::UserAgent");
        } else {
            plan(tests => 1);
        }
    }
}


lives_ok {
    my $decoder = Data::Decode->new(
        decoder => [
            Data::Decode::Encode::HTTP::Response->new(),
            Data::Decode::Encode::Guess::JP->new(),
        ]
    );

    my $url = "http://wpedia.goo.ne.jp/wiki/%E8%83%83";

    my $ua  = LWP::UserAgent->new;
    my $req = HTTP::Request->new( GET => $url );
    my $res = $ua->request($req);

    my $content = $decoder->decode( $res->content, { response => $res } );
};
