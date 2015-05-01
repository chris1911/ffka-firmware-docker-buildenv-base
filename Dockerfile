FROM debian:wheezy

MAINTAINER chris1911@users.noreply.github.com

ENV BASEDIR /gluon
ENV BUILDDIR /gluon/build
ENV DEBIAN_FRONTEND noninteractive

RUN echo >> /etc/apt/apt.conf.d/00aptitude 'APT::Install-Recommends "0";' && \
    echo >> /etc/apt/apt.conf.d/00aptitude 'APT::Install-Suggests "0";' && \
    apt-get -y update && \
    apt-get -y install sudo file git ca-certificates build-essential wget flex gettext pkg-config unzip zlib1g-dev libncurses5-dev gawk subversion python liblzma-dev liblzma5 vim p7zip-full bsdmainutils

RUN useradd -m gluonbuilder -s /bin/bash && \
    mkdir -p ${BUILDDIR} && \
    chown gluonbuilder:gluonbuilder -R ${BASEDIR}

# docker still ADDs files as root, even after setting a different USER; we use sudo to get around this limitation
# RUN echo 'gluonbuilder  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# openwrt: use unprivileged user to build sources (or fail if root)
USER gluonbuilder
ENV HOME /home/gluonbuilder
ENV DEBIAN_FRONTEND noninteractive

RUN \
    cd ${BUILDDIR} && \
    git config --global user.email "youremail@address.here" && \
    git config --global user.name "Your name here"
