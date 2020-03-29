FROM ubuntu:trusty
MAINTAINER mrdotb "https://github.com/mrdotb"

COPY 42norminette /
COPY norminette.sh /

ENV LLVM_VERSION 3.4.2
ENV RBX_VERSION 2.2.6

ENV LLVM_INSTALL_DIR /tmp/llvm
ENV RBX_INSTALL_DIR /opt/42norminette_rubinius

# Generate and set UTF-8 locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update
RUN apt-get install -y wget ruby-dev make automake
RUN apt-get install -y g++ flex bison zlib1g-dev libyaml-dev libssl-dev \
      libgdbm-dev libreadline-dev libncurses5-dev 
RUN apt-get install -y python python2.7
RUN apt-get install -y build-essential libxml2-dev libxslt1-dev libsqlite3-dev

RUN gem install bundler -v '~>1'

RUN wget -O http://llvm.org/releases/${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.gz
RUN tar -xf llvm-${LLVM_version}.src.tar.gz
