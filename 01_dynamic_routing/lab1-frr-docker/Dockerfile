FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    frr \
    frr-openrc \
    tcpdump \
    bash \
    curl \
    iproute2

# Set up FRR directories and configurations
RUN mkdir -p /run/frr && \
    chown -R frr:frr /run/frr && \
    mkdir -p /etc/frr && \
    chown -R frr:frr /etc/frr && \
    echo "frr defaults traditional" > /etc/frr/daemons && \
    echo "hostname frr-router" >> /etc/frr/daemons && \
    echo "zebra=yes" >> /etc/frr/daemons && \
    echo "bgpd=yes" >> /etc/frr/daemons && \
    echo "ospfd=no" >> /etc/frr/daemons && \
    echo "ospf6d=no" >> /etc/frr/daemons && \
    echo "ripd=no" >> /etc/frr/daemons && \
    echo "ripngd=no" >> /etc/frr/daemons && \
    echo "isisd=no" >> /etc/frr/daemons && \
    echo "pimd=no" >> /etc/frr/daemons && \
    echo "ldpd=no" >> /etc/frr/daemons && \
    echo "nhrpd=no" >> /etc/frr/daemons && \
    echo "eigrpd=no" >> /etc/frr/daemons && \
    echo "babeld=no" >> /etc/frr/daemons && \
    echo "sharpd=no" >> /etc/frr/daemons && \
    echo "staticd=yes" >> /etc/frr/daemons && \
    echo "pbrd=no" >> /etc/frr/daemons && \
    echo "bfdd=no" >> /etc/frr/daemons && \
    echo "fabricd=no" >> /etc/frr/daemons && \
    echo "vrrpd=no" >> /etc/frr/daemons && \
    mkdir -p /var/run/frr && \
    chown -R frr:frr /var/run/frr

# Default command
ENTRYPOINT ["/bin/bash"]
CMD ["tail", "-f", "/dev/null"] 