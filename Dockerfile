# Credit to Julien Guyomard (https://github.com/jguyomard). This Dockerfile
# is essentially based on his Dockerfile at
# https://github.com/jguyomard/docker-hugo/blob/master/Dockerfile. The only significant
# change is that the Hugo version is now an overridable argument rather than a fixed
# environment variable.

FROM alpine:3.19

MAINTAINER Luc Perkins <lperkins@linuxfoundation.org>

RUN set -x && apk add --no-cache --update \
    curl \
    git \
    openssh-client \
    rsync \
    libc6-compat \
    libstdc++ \
    nodejs \
    npm \
    hugo \
    build-base

RUN curl -L https://github.com/Gizra/minify/archive/refs/tags/1.0.0.tar.gz | tar -xz && \
    mv minify-1.0.0/minify /usr/local/bin && \
    rm -rf minify-1.0.0 && \
    addgroup -Sg 1000 hugo && \
    adduser -Sg hugo -u 1000 -h /src hugo

WORKDIR /src

EXPOSE 1313