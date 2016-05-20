FROM qnib/alpn-base

ENV DUMB_INIT_VER=1.0.0
###### Inspired (if not copied) from 
#> https://github.com/neeravkumar/dockerfiles/blob/3da7fb3bb4e9c9795169c4a61e79f86fcccf0449/alpine-openrc/Dockerfile
# Install openrc
RUN apk update && apk add openrc wget &&\
    # Tell openrc its running inside a container, till now that has meant LXC
    sed -i 's/#rc_sys=.*/rc_sys="lxc"/g' /etc/rc.conf && \
    # Hand over all enviroment variables to OpenRC
    sed -i 's/#rc_env_allow=.*/rc_env_allow="*"/g' /etc/rc.conf && \
    # Tell openrc loopback and net are already there, since docker handles the networking
    echo 'rc_provide="loopback net"' >> /etc/rc.conf && \
    # no need for loggers
    sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf && \
    # can't get ttys unless you run the container in privileged mode
    sed -i '/tty/d' /etc/inittab &&\
    # can't set hostname since docker sets it
    sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname &&\
    # can't mount tmpfs since not privileged
    sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh &&\
    # can't do cgroups
    sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh && \
    # Dumb-init 
    wget -qO /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VER}/dumb-init_${DUMB_INIT_VER}_amd64 && \
    chmod +x /usr/local/bin/dumb-init && \
    apk del wget && \
    rm -rf /var/cache/apk/*
CMD ["/sbin/init"]
