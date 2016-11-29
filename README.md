# What is "DNS over HTTPS"

A very small (250MB) container which will create a full DNS server
that listens on tcp+udp 53.

It responds to standard DNS queries, and it looks up the requests on
the backend using Google's HTTPS DNS API:
https://developers.google.com/speed/public-dns/docs/dns-over-https

It then responds to the query via standard DNS responses, which makes it viable
for using things like dig/host, and even pointing your system's
/etc/resolv.conf

# How to run the "DNS over HTTPS":
```
docker run \
    -it -d \
    -p 53:53/udp \
    -p 53:53 \
ventz/dns-over-https
```

# How to use it?
After you run the service (see above: "DNS over HTTPS"), you can manually test:

```
dig cnn.com @docker-container-ip-address
```
or
```
dig -x 8.8.8.8 @docker-container-ip-address
```

Or, you can even point your /etc/resolv.conf to:
```
nameserver DOCKER-CONTAINER-IP-ADDRESS
```

# Help/Questions/Comments:
For help or more info, feel free to contact Ventz Petkov: ventz@vpetkov.net
