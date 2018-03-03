FROM ubuntu:14.04

MAINTAINER Pouya Na <pouya@applariat.com>

COPY ./builder.sh /

#install docker
RUN apt-get -qq update \
    && apt-get --yes --force-yes install apt-transport-https ca-certificates wget curl zip \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
    && echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list \
    && apt-get -qq update \
    && apt-get --yes --force-yes install docker-engine

ENTRYPOINT ["/builder.sh"]