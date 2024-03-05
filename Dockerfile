# STAGE 1: Build
FROM golang:1.22-alpine AS build

# Install Node and NPM.
RUN apk update && apk upgrade && apk add --no-cache git nodejs bash npm

# Get dependencies for Go part of build
RUN go install github.com/go-bindata/go-bindata/go-bindata@latest

WORKDIR /go/src/github.com/kubernetes-up-and-running/kuard

# Copy all sources in
COPY . .

ARG version=test

# This is a set of variables that the build script expects
ENV VERBOSE=0
ENV PKG=github.com/kubernetes-up-and-running/kuard
ENV ARCH=amd64
ENV VERSION=$version

# Do the build. Script is part of incoming sources.
RUN build/build.sh

# STAGE 2: Runtime
FROM alpine

USER nobody:nobody
COPY --from=build /go/bin/kuard /kuard

CMD [ "/kuard" ]
