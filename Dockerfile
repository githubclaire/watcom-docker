# Watcom Docker Build Environment
#
# To build use:
# docker build -t lapinlabs/watcom .
FROM alpine:3.13
MAINTAINER Chad Rempp <crempp@gmail.com>

LABEL description="An OpenWatcom V2 build environment."

# Setup the build environment all in one pass. This helps us to reduce image
# size by doing cleanup in the same layer as the setup.
RUN apk add --no-cache --update --virtual .build-deps \
      g++ \
      gcc \
      git \
      make \
      musl-dev \
    # Build and install Watcom package
    && cd /tmp \
    && git clone --depth 1 --branch 2021-04-02-Build https://github.com/open-watcom/open-watcom-v2.git \
    && cd open-watcom-v2 \
    && echo "export OWNOBUILD=\"nt386 wgml\"" >> setvars.sh \
    && echo "export OWGUINOBUILD=1" >> setvars.sh \
    # Comment out inclusion of wgml/builder.ctl to avoid Dosbox dependency -- this SHOULD NOT be necessary
    && sed '/\[ INCLUDE <OWSRCDIR>\/wgml\/builder.ctl \]/{s/^/#/}' -i bld/builder.ctl \
    && ./build.sh \
    && cp build/binbuild/* /usr/local/bin \
    && cd / \
    # Clean up after ourselves (do this in the same layer)
    && rm -rf /tmp/open-watcom-v2 \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

CMD ["/bin/sh"]
