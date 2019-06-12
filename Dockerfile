# Usage:
# > docker build -t folexflu/cosmos-nameservice .
# docker run --name nameservice -d -p 26658:26658 -p 26656:26656 -p 26657:26657 folexflu/cosmos-nameservice:latest seed moniker-1
# docker run --name nameservice -d -p 26658:26658 -p 26656:26656 -p 26657:26657 -v /genesis.json:/root/genesis.json folexflu/cosmos-nameservice:latest seed peer moniker-2 seedid@ip:26657
FROM golang:alpine AS build-env

# Set up dependencies
ENV PACKAGES make git libc-dev gcc linux-headers eudev-dev
# ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev

# Add source files
COPY . /go/src/github.com/cosmos/sdk-application-tutorial

# Set working directory for the build
WORKDIR /go/src/github.com/cosmos/sdk-application-tutorial

# Install minimum necessary dependencies, build Cosmos SDK, remove packages
RUN apk add --no-cache $PACKAGES && make install

# Final image
FROM alpine:edge

# Install ca-certificates
RUN apk add --update ca-certificates
WORKDIR /root

# Copy over binaries from the build-env
COPY --from=build-env /go/bin/nsd /usr/bin/nsd
COPY --from=build-env /go/bin/nscli /usr/bin/nscli
COPY --from=build-env /go/src/github.com/cosmos/sdk-application-tutorial/run.sh /run.sh
RUN chmod +x /run.sh

# Run gaiad by default, omit entrypoint to ease using container with gaiacli
ENTRYPOINT ["/run.sh"]