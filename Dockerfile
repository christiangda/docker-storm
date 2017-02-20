FROM openjdk:8-jre-alpine

MAINTAINER Christian González <christiangda@gmail.com>

# Arguments from docker build proccess
ARG STORM_MIRROR
ARG STORM_VERSION

# Default values
ENV STORM_VERSION ${STORM_VERSION:-1.0.2}
ENV STORM_MIRROR ${STORM_MIRROR:-http://apache.mirrors.pair.com}

# Container's Labels
LABEL Description "Apache Storm docker image" \
      Vendor "Christian González" \
      Name "Apache Storm" \
      Version ${STORM_VERSION}

LABEL Build "docker build --no-cache --rm \
            --build-arg STORM_VERSION=1.0.2 \
            --build-arg STORM_MIRROR=http://apache.mirrors.pair.com \
            --tag christiangda/storm:1.0.2 \
            --tag christiangda/storm:latest \
            --tag christiangda/storm:canary ." \
      Run "docker run --rm -ti -h "storm-01.develop.local" christiangda/storm" \
      Connect "docker exec -ti <container id from 'docker ps' command> /bin/bash"

# Update and install Apache Storm
RUN apk --no-cache --update add \
    wget \
    bash \
    python \
    python-dev \
    py-pip \
    && mkdir /opt \
    && wget -q -O - $STORM_MIRROR/storm/apache-storm-$STORM_VERSION/apache-storm-$STORM_VERSION.tar.gz | tar -xzf - -C /opt \
    && mv /opt/apache-storm-$STORM_VERSION /opt/apache-storm \
    && mkdir -p /opt/apache-storm/logs \
    && mkdir -p /opt/apache-storm/storm-local \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

# create folser for aws credentials (to share folder wit user)
RUN mkdir ~/.aws

# Environment variables
ENV container docker
ENV STORM_HOME "/opt/apache-storm"
ENV PATH $STORM_HOME/bin:$PATH

# Initial configuration Files
COPY storm.yaml /opt/apache-storm/conf/
COPY storm_env.ini /opt/apache-storm/conf/
COPY storm-env.sh /opt/apache-storm/conf/

COPY start-up-daemons.sh /bin/
RUN chmod +x /bin/start-up-daemons.sh

# Exposed ports
EXPOSE 8080 8000 6627 6700 6701 6702 6703

WORKDIR /opt/apache-storm

VOLUME ["/opt/apache-storm/conf", "/opt/apache-storm/logs", "/opt/apache-storm/storm-local", "/tmp", "/root/.aws"]

ENTRYPOINT ["/bin/start-up-daemons.sh"]
CMD ["nimbus","ui","supervisor","logviewer","drpc"]
