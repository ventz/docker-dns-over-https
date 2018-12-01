FROM alpine:latest

RUN apk add --update curl wget perl perl-dev alpine-sdk perl-libwww perl-params-util perl-module-build perl-lwp-protocol-https
RUN curl -L https://cpanmin.us | perl - App::cpanminus

RUN cpanm --sudo Net::DNS::Nameserver
RUN cpanm --sudo WWW::Mechanize
RUN cpanm --sudo JSON::XS

COPY entrypoint.pl /

ENTRYPOINT ["/entrypoint.pl"]
