FROM ubuntu:trusty

MAINTAINER mrdotb "https://github.com/mrdotb"

COPY . /

# Generate and set UTF-8 locale
RUN locale-gen en_US.UTF-8

ENV  LLVM_VERSION=3.4.2 \
     RBX_VERSION=2.2.6 \
     LLVM_INSTALL_DIR=/tmp/llvm \
     RBX_INSTALL_DIR=/opt/42norminette_rubinius \
     LANG=en_US.UTF-8 \
     LC_ALL=en_US.UTF-8

RUN buildDeps="automake \
               bison \
               build-essential \
               flex \
               g++ \
               git \
               libffi-dev \
               libgdbm-dev \
               libncurses5-dev  \
               libreadline-dev \
               libsqlite3-dev \
               libssl-dev \
               libxml2-dev \
               libxslt1-dev \
               libyaml-dev \
               make \
               python \
               python2.7 \
               ruby-dev \
               zlib1g-dev \
               wget" && \
      apt-get update -yqq && \
      apt-get install -yq --no-install-recommends $buildDeps && \
      apt-get autoremove -y && \
      apt-get clean -y && \
      rm -rf /var/lib/apt/lists/*

# Download, compile and install LLVM
RUN nb_threads=$(cat /proc/cpuinfo | grep processor | wc -l) && \
    wget http://llvm.org/releases/$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.gz && \
    tar -xf llvm-$LLVM_VERSION.src.tar.gz && \
    rm -rf llvm-$LLVM_VERSION.src.tar.gz && \
    cd llvm-$LLVM_VERSION.src && \
    ./configure --disable-assertions --disable-shared \
    --prefix=$LLVM_INSTALL_DIR --disable-docs --enable-libffi \
    --enable-optimized && \
    make -j$nb_threads && \
    make install

# Download, compile and install rubinius
RUN gem install bundler -v '~> 1' && \
    wget https://github.com/rubinius/rubinius/releases/download/v$RBX_VERSION/rubinius-$RBX_VERSION.tar.bz2 && \
    tar -xf rubinius-$RBX_VERSION.tar.bz2 && \
    rm -rf rubinius-$RBX_VERSION.tar.bz2 && \
    cp rubiniusGemfile /rubinius-$RBX_VERSION/Gemfile && \
    cd rubinius-$RBX_VERSION && \
    bundle install --path=. && \
    ./configure --llvm-path=$LLVM_INSTALL_DIR --prefix=$RBX_INSTALL_DIR \
    --llvm-config="$LLVM_INSTALL_DIR/bin/llvm-config" \
    --libc=/lib/x86_64-linux-gnu/libc.so.6 && \
    bundle exec rake || echo 0 && \
    sed -i "s/rb_warning0(\"\`\"op\"' after local variable is interpreted as binary operator\")/rb_warning0(\"\`\" op \"' after local variable is interpreted as binary operator\")/" staging/runtime/gems/rubinius-melbourne-2.1.0.0/ext/rubinius/melbourne/grammar.cpp && \
    sed -i 's/rb_warning0("even though it seems like "syn""))/rb_warning0("even though it seems like " syn ""))/' staging/runtime/gems/rubinius-melbourne-2.1.0.0/ext/rubinius/melbourne/grammar.cpp && \
    bundle exec rake || echo 0 && \
    bundle exec rake install && \
    rm -rf /tmp/llvm

# Install bundler
RUN $RBX_INSTALL_DIR/bin/gem install bundler -v '~>1' && \
    cd 42norminette && \
    $RBX_INSTALL_DIR/gems/bin/bundle install --path=. && \
    $RBX_INSTALL_DIR/bin/rbx compile -o norminette.rbc norminette.rb && \
    sed -i "s@/usr/bin/rbx@${RBX_INSTALL_DIR}/bin/rbx@" norminette.rb && \
    OLD_SIG="$(head -n 2 compiled/rules.rbc | tail -n 1)" && \
    NEW_SIG="$(head -n 2 norminette.rbc | tail -n 1)" && \
    sed -i "s/${OLD_SIG}/${NEW_SIG}/" compiled/rules.rbc && \
    sed -i "s/${OLD_SIG}/${NEW_SIG}/" compiled/*/*.rbc && \
    cp /digest.rb /opt/42norminette_rubinius/gems/gems/rubysl-digest-2.0.3/lib/rubysl/digest/digest.rb

# Cleanup
RUN rm -rf llvm-$LLVM_VERSION.src rubinius-$RBX_VERSION

ENTRYPOINT  ["./norminette.sh"]
