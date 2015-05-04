FROM debian:wheezy

MAINTAINER chris1911@users.noreply.github.com

ENV BASEDIR /gluon
ENV BUILDDIR /gluon/build

RUN	\
	echo >> /etc/apt/apt.conf.d/00aptitude 'APT::Install-Recommends "0";' && \
	echo >> /etc/apt/apt.conf.d/00aptitude 'APT::Install-Suggests "0";' && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get -y update && \
	apt-get -y install bsdmainutils build-essential ca-certificates cmake file \
			   flex gawk gettext git less liblzma-dev liblzma5 libncurses5-dev \
			   p7zip-full pkg-config python subversion sudo unzip vim wget zlib1g-dev

RUN	\
	useradd -m gluonbuilder -s /bin/bash && \
	mkdir -p ${BUILDDIR} && \
	chown gluonbuilder:gluonbuilder -R ${BASEDIR} && \
	echo 'gluonbuilder  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# openwrt: use unprivileged user to build sources (or fail if root)
USER gluonbuilder
ENV HOME /home/gluonbuilder

RUN \
	cd ${BUILDDIR} && \
	git config --global user.email "youremail@address.here" && \
	git config --global user.name "Your name here"
