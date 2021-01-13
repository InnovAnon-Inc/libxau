FROM innovanon/xorg-base:latest as builder-01
USER root
COPY --from=innovanon/util-macros /tmp/util-macros.txz /tmp/
COPY --from=innovanon/xorgproto   /tmp/xorgproto.txz   /tmp/
RUN extract.sh

ARG LFS=/mnt/lfs
WORKDIR $LFS/sources
USER lfs
RUN sleep 31                                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libXau.git \
 && cd                                                                      libXau     \
 && ./autogen.sh                                                                       \
 && ./configure $XORG_CONFIG                                                           \
 && make                                                                               \
 && make DESTDIR=/tmp/libXau install                                                   \
 && rm -rf                                                                  libXau     \
 && cd           /tmp/libXau                                                           \
 && strip.sh .                                                                         \
 && tar  pacf        ../libXau.txz .                                                     \
 && cd ..                                                                              \
 && rm -rf       /tmp/libXau

FROM scratch as final
COPY --from=builder-01 /tmp/libXau.txz /tmp/

