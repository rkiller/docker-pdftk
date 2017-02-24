FROM ubuntu:trusty

MAINTAINER Roger Killer <roger@clineva.com>

ENV GCC_VERSION 4.9.4
ENV PDFTK_VERSION 2.02

RUN apt-get update && \
#    apt-get install -y unzip build-essential gcj-jdk && \
    apt-get install -y unzip build-essential && \
    apt-get clean

RUN mkdir /tmp/env && \
    mkdir /tmp/env/gcc && \
    mkdir /tmp/src
ADD http://www.netgull.com/gcc/releases/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz /tmp/src/
RUN tar -xzf /tmp/src/gcc-${GCC_VERSION}.tar.gz -C /tmp/src && \
    cd /tmp/src/gcc-${GCC_VERSION} && \
    ./configure --prefix=/tmp/env/gcc --enable-libgcj --enable-threads=posix --enable-shared --enable-languages='c++,java' && \
    make && \
    make install && \
    export PATH=/tmp/env/gcc/bin:$PATH && \
    export LD_LIBRARY_PATH=/tmp/env/gcc/lib:$LD_LIBRARY_PATH && \
    which gcc && \
    which gcj

# The directory containing the PDF files to be processed is expected to be mounted here
# as a docker volume when running the container.
RUN mkdir /work
WORKDIR /work
VOLUME ["/work"]

ADD https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk-${PDFTK_VERSION}-src.zip /tmp/
RUN unzip /tmp/pdftk-${PDFTK_VERSION}-src.zip -d /tmp && \
    sed -i 's/VERSUFF=-4.6/VERSUFF=-4.8/g' /tmp/pdftk-${PDFTK_VERSION}-dist/pdftk/Makefile.Debian && \
    cd /tmp/pdftk-${PDFTK_VERSION}-dist/pdftk && \
    make -f Makefile.Debian && \
    make -f Makefile.Debian install && \
    rm -Rf /tmp/pdftk-*

ENTRYPOINT ["/usr/local/bin/pdftk"]
