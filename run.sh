#!/bin/bash
docker run -it -d --restart=always -p 53:53/udp -p 53:53 ventz/dns-over-https
