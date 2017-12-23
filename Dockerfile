FROM debian:stretch as builder
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
	apt-get install -q -y golang git-core procps nano vim tree sudo && \
	apt-get clean

ENV GOPATH=/root/go
RUN mkdir -p /root/go/src
COPY rest-api /root/go/src/dyndns
RUN cd /root/go/src/dyndns && go get && go test -v

FROM debian:stretch
MAINTAINER David Prandzioch <hello+ddns@davd.eu>, Daniel Schulz <danielschulz2005@hotmail.com>

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
	apt-get install -q -y bind9 dnsutils && \
	apt-get clean

RUN chmod 770 /var/cache/bind
COPY setup.sh /root/setup.sh
RUN chmod +x /root/setup.sh
COPY named.conf.options /etc/bind/named.conf.options
COPY --from=builder /root/go/bin/dyndns /root/dyndns

EXPOSE 53 53/udp 8080
CMD ["sh", "-c", "/root/setup.sh ; service bind9 start ; /root/dyndns"]
