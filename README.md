# What is "DNS over HTTPS"

## Last Updated: 2-22-2020

A very small (268 MB) and lightweight DNS server which responds to standard DNS (see supported resource records) queries on the front-end via tcp+udp 53, and it looks them up via HTTPS on the back-end, using one of two choices:

1.) Cloud Flare's HTTPS DNS API:
https://developers.cloudflare.com/1.1.1.1/dns-over-https/json-format/

or

2.) Google's HTTPS DNS API:
https://developers.google.com/speed/public-dns/docs/dns-over-https


It then responds to the query via standard DNS responses, which makes it viable
for using things like dig/host, and even pointing your system's
/etc/resolv.conf

# How to run the "DNS over HTTPS":

You have two choices for the backend:

1.) (default) CloudFlare

```
docker run -it -d \
    --restart=always \
    -p 53:53/udp \
    -p 53:53 \
ventz/dns-over-https
```

or

2.) Google
```
docker run -it -d \
    --restart=always \
    -p 53:53/udp \
    -p 53:53 \
ventz/dns-over-https google
```

# How to run the "DNS over HTTPS" with IPv6 support?

You can add '6' as a second parameter after the now required backend provider input:

1.) CloudFlare IPv6 Support:
```
docker run -it -d \
    --restart=always \
    -p 53:53/udp \
    -p 53:53 \
ventz/dns-over-https cloudflare 6
```

or

2.) Google IPv6 Support:
```
docker run -it -d \
    --restart=always \
    -p 53:53/udp \
    -p 53:53 \
ventz/dns-over-https google 6
```


# How to use it?
After you run the service (see above: "DNS over HTTPS"), you can manually test:

```
dig cnn.com @DOCKER-CONTAINER-IP-ADDRESS
```
or
```
dig -x 207.241.224.2 @DOCKER-CONTAINER-IP-ADDRESS
```

Or, you can even point your /etc/resolv.conf to:
```
nameserver DOCKER-CONTAINER-IP-ADDRESS
```

# Supported Resource Record Types:

* A
* AAAA
* CNAME
* PTR
* NS
* SRV
* TXT
* SPF

It is *extremely* easy to add additional resource records.

If you need to add a new one, first find the value for it:
https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml#dns-parameters-4

Once you have the type and value, find the line in `entrypoint.pl` that looks like this:
```
elsif($qtype == 99) { $qtype = 'SPF'; }
```

and simply add another one for your new resource record.

For example, to add `LOC` (which is # 29), you would add:
```
elsif($qtype == 29) { $qtype = 'LOC'; }
```


Look up type you want and the value number (ex: 

# Help/Questions/Comments:
For help or more info, please open a GitHub [issue](https://github.com/ventz/docker-dns-over-https/issues)
