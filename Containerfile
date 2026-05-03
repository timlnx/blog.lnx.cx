FROM quay.io/fedora/fedora:41

RUN dnf -y install ruby ruby-devel openssl-devel gcc-c++ \
    make @development-tools git-core rsync && \
    dnf clean all

WORKDIR /build
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

COPY container-build.sh /usr/local/bin/container-build.sh
RUN chmod +x /usr/local/bin/container-build.sh

ENTRYPOINT ["container-build.sh"]
