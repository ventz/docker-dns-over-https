#!/bin/bash
docker run -it -d -p 53:53/udp -p 53:53 ventz/dns-relay-over-https
