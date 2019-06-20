#!/usr/bin/perl
use strict;
use warnings;

#use lib "/root/modules/lib/perl5";

use Net::DNS::Nameserver;
use WWW::Mechanize;
use JSON::XS;

# By default we use "CloudFlare" as our HTTPS->DNS backend.
# Users may override this by passing "google" as an argument
our $provider = 'cloudflare';
our $listen = ['0.0.0.0'];

my $input = $ARGV[0];
if($input && ($input eq 'google')) {
	$provider = 'google';
}
my $ip = $ARGV[1];
if($ip && ($ip == 6)) {
    $listen = ['0.0.0.0', '::'];
}

print STDERR "\n=> Provider Selected for DNS-over-HTTPS backend: $provider\n\n";

sub reply_handler {
    my ($qname, $qclass, $qtype, $peerhost,$query,$conn) = @_;
    my ($rcode, @ans, @auth, @add);

    print STDERR "Received query from $peerhost to ". $conn->{sockhost}. "\n";
    print STDERR $query->string;

    my $return = dns_over_https($qname, $qclass, $qtype);
    my ($a, $r) = @{$return};
    @ans = @{$a};
    $rcode = $r;
    #$rcode = "NOERROR";
    #$rcode = "NXDOMAIN";

    # mark the answer as authoritive (by setting the 'aa' flag
    return ($rcode, \@ans, \@auth, \@add, { aa => 1 });
}

sub dns_over_https {
    my ($query, $qclass, $type) = @_;

    my @ans;
    my $rcode = "NOERROR";

    my $mech = WWW::Mechanize->new('ssl_opts' => { 'verify_hostname' => 1 });
	$mech->add_header( Accept => 'application/dns-json' );   
    my $url = "https://cloudflare-dns.com/dns-query?name=$query&type=$type";
	if($provider eq 'google') { $url = "https://dns.google.com/resolve?name=$query&type=$type"; }
    $mech->get( $url );
    my $result = $mech->content;
    
    my $decoded_response = decode_json($result);
    my $status = $decoded_response->{'Status'};
    my @items = @{$decoded_response->{'Answer'}}; 
    if($status == 0) {
        $rcode = "NOERROR";
        for my $answer (@items) {
            my $qname = $answer->{'name'};
            my $qtype = $answer->{'type'};
            my $ttl = $answer->{'TTL'};
            my $rdata = $answer->{'data'};

            # https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml#dns-parameters-4 
            if($qtype == 1) { $qtype = 'A'; }                                                       
            elsif($qtype == 2) { $qtype = 'NS'; }                                                   
            elsif($qtype == 5) { $qtype = 'CNAME'; }                                                
            elsif($qtype == 12) { $qtype = 'PTR'; }                                                 
            elsif($qtype == 16) { $qtype = 'TXT'; }                                                 
            elsif($qtype == 28) { $qtype = 'AAAA'; }                                                 
            elsif($qtype == 33) { $qtype = 'SRV'; }                                                 
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
    LocalAddr    => $listen,
    LocalPort    => 53,
    ReplyHandler => \&reply_handler,
    Verbose      => 0
    ) || die "couldn't create nameserver object\n";

$ns->main_loop;
