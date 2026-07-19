FROM quay.io/fedora/fedora:41

# python3-lxml is for validate-feed.py, which runs against the built feed at the
# end of container-build.sh. The RPM avoids a pip install and a compiler run.
RUN dnf -y install ruby ruby-devel openssl-devel gcc-c++ \
    make @development-tools git-core rsync python3 python3-lxml && \
    dnf clean all

WORKDIR /build
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

COPY bin/container-build.sh /usr/local/bin/container-build.sh
RUN chmod +x /usr/local/bin/container-build.sh

ENTRYPOINT ["container-build.sh"]
