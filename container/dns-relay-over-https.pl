#!/usr/bin/perl
use strict;
use warnings;

#use lib "/root/modules/lib/perl5";

use Net::DNS::Nameserver;
use WWW::Mechanize;
use JSON::XS;

sub reply_handler {
    my ($qname, $qclass, $qtype, $peerhost,$query,$conn) = @_;
    my ($rcode, @ans, @auth, @add);

    print STDERR "Received query from $peerhost to ". $conn->{sockhost}. "\n";
    print STDERR $query->string;

    my $return = google_dns_over_https($qname, $qclass);
    my ($a, $r) = @{$return};
    @ans = @{$a};
    $rcode = $r;
    #$rcode = "NOERROR";
    #$rcode = "NXDOMAIN";

    # mark the answer as authoritive (by setting the 'aa' flag
    return ($rcode, \@ans, \@auth, \@add, { aa => 1 });
}

sub google_dns_over_https {
    my ($query, $qclass) = @_;

    my @ans;
    my $rcode = "NOERROR";

    my $mech = WWW::Mechanize->new('ssl_opts' => { 'verify_hostname' => 1 });
    $mech->agent_alias( 'Mac Safari' );
    my $url = "https://dns.google.com/resolve?name=$query";
    $mech->get( $url );
    my $result = $mech->content;
    
    my $decoded_response = decode_json($result);
    my $status = $decoded_response->{'Status'};
    my @items = $decoded_response->{'Answer'}[0];
    if($status == 0) {
        $rcode = "NOERROR";
        for my $answer (@items) {
            my $qname = $answer->{'name'};
            my $qtype = $answer->{'type'};
            my $ttl = $answer->{'TTL'};
            my $rdata = $answer->{'data'};
            if($qtype == 1) { $qtype = 'A'; }
            elsif($qtype == 5) { $qtype = 'CNAME'; }
            elsif($qtype == 99) { $qtype = 'SPF'; }
            #print "$qname | $ttl | $qclass | $qtype | $rdata";exit;
            my $rr = new Net::DNS::RR("$qname $ttl $qclass $qtype $rdata");
            push @ans, $rr;
        }
    }
    my @return = (\@ans, $rcode);
    return \@return;
}


my $ns = new Net::DNS::Nameserver(
    LocalAddr    => [ '0.0.0.0' ],
    LocalPort    => 53,
    ReplyHandler => \&reply_handler,
    Verbose      => 0
    ) || die "couldn't create nameserver object\n";

$ns->main_loop;
