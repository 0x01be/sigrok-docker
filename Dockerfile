FROM arm32v6/alpine as builder

RUN apk --no-cache add --virtual sigrok-build-dependencies \
    git \
    build-base \
    cmake \
    pkgconfig \
    autoconf \
    automake \
    libtool \
    glib-dev \
    libzip-dev \
    libusb-dev \
    libftdi1-dev \
    hidapi-dev \
    bluez-dev \
    libieee1284-dev \
    doxygen \
    graphviz \
    autoconf-archive \
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

