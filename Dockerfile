FROM arm32v6/alpine as builder

RUN apk --no-cache add --virtual sigrok-build-dependencies \
    git \
    build-base \
    cmake \
    pkgconfig \
    autoconf \
    autoconf-archive \
    automake \
    libtool \
    doxygen \
    graphviz \
    glib-dev \
    libzip-dev \
    libusb-dev \
    libftdi1-dev \
    hidapi-dev \
    bluez-dev \
    libieee1284-dev \
    python3-dev \
    glibmm-dev

RUN git clone --depth 1 git://sigrok.org/libserialport /libserialport

WORKDIR /libserialport

RUN ./autogen.sh
RUN ./configure --prefix=/opt/sigrok
RUN make
RUN make install

RUN git clone --depth 1 git://sigrok.org/libsigrok /libsigrok

WORKDIR /libsigrok
RUN ./autogen.sh
RUN ./configure --prefix=/opt/sigrok
RUN make
RUN make install

ENV SIGROK_CLI_LIBS /opt/sigrok/lib

RUN git clone --depth 1 git://sigrok.org/libsigrokdecode /libsigrokdecode

WORKDIR /libsigrokdecode
RUN ./autogen.sh
RUN ./configure --prefix=/opt/sigrok
RUN make
RUN make install

FROM arm32v6/alpine

COPY --from=builder /opt/sigrok/ /opt/sigrok/

RUN apk --no-cache add --virtual sigrok-runtime-dependencies \
    glib-dev \
    libzip-dev \
    libusb-dev \
    libftdi1-dev \
    hidapi-dev \
    bluez-dev \
    libieee1284-dev \
    python3-dev \
    glibmm-dev

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/opt/sigrok/lib
ENV LD_RUN_PATH $LD_RUN_PATH:/opt/sigrok/lib

