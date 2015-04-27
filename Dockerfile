FROM debian:wheezy

#
# Adopt SITENAME (and SITE_GIT) below to have gluon use your own site.cfg
# Beware: GLUON_TARGET is not just a directory name, but the variable is also used by gluon to select the target architecture.
# Available architectures as of 2015-04-25 are: ar71xx-generic, mpc85xx-generic
# X86 support is still unstable in the latest release (cur: 2014.4.x). Stay tuned.
#
MAINTAINER <anon>@world.com
ENV SITENAME ffka
ENV SITE_GIT https://github.com/ffka/site-ffka
ENV BRANCH 2014.4.x
ENV GLUON_TARGET ar71xx-generic

# docker still ADDs files as root, even after setting a different USER; we use sudo to get around this limitation
RUN echo >> /etc/apt/apt.conf.d/00aptitude "APT::Install-Recommends \"0\";" && \
    echo >> /etc/apt/apt.conf.d/00aptitude "APT::Install-Suggests \"0\";" && \
    useradd -m gluonbuilder -s /bin/bash && \
    apt-get -y update && \
    apt-get -y install sudo && \
    echo 'gluonbuilder  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir /gluon && \
    chown gluonbuilder:gluonbuilder -R /gluon

# openwrt: use unprivileged user to build sources
USER gluonbuilder
ENV HOME /home/gluonbuilder
ENV DEBIAN_FRONTEND noninteractive

# Important: execute all following commands including the cleanup steps inside a single 'RUN'-statement.
# Docker creates a layer for each statement. Executing each command in its own layer will drastically increase the container's size as temporary files are still present in lower layers.
# N.b. Docker hub will cancel a single statement after 2 hours with an 'Unexpected failure'.
# If we split up the commands in single statement, a layer is created for each statement, which will be part of the final image and has to be downloaded by everyone pulling the image.
RUN \
    sudo apt-get -y install file git ca-certificates build-essential wget flex gettext pkg-config unzip && \
    sudo apt-get -y install zlib1g-dev libncurses5-dev gawk subversion python liblzma-dev liblzma5 vim p7zip-full && \
    mkdir -p /gluon/${GLUON_TARGET} && \
    cd /gluon/${GLUON_TARGET} && \
    git config --global user.email "youremail@address.here" && \
    git config --global user.name "Your name here" && \
    git clone https://github.com/freifunk-gluon/gluon.git /gluon/${GLUON_TARGET}/ && \
    git clone ${SITE_GIT} /gluon/${GLUON_TARGET}/site && \
    git checkout -b ${BRANCH} remotes/origin/${BRANCH}
