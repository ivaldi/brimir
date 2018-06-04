FROM ubuntu:16.04
MAINTAINER GCLOUD, Inc. <network@gcloud.co.jp>
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  nginx \
  patch \
  git \
  curl \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libmysqld-dev \
  ca-certificates \
  imagemagick \
  libmagickwand-dev \
  language-pack-ja \
  libsqlite3-dev \
  unzip \
  sudo \
  cron \
  tzdata \
  libfontconfig \
  libicu55 \
  logrotate \
  rsyslog \
  vim \
  npm

ENV TZ Asia/Tokyo
RUN echo "${TZ}" > /etc/timezone \
  && rm /etc/localtime \
  && ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata

RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP:ja
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8

RUN useradd -m -d /home/brimir/ -s /bin/bash -g staff -G sudo brimir

# RubyとGemのセットアップ 
USER brimir
RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile 
RUN echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
RUN echo 'export PATH="$HOME/brimir/bin:$PATH"' >> ~/.bash_profile
RUN git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
ENV PATH /home/brimir/.rbenv/bin:$PATH
RUN rbenv install 2.4.1
RUN rbenv global 2.4.1
RUN echo "install: --no-ri --no-rdoc" >> ~/.gemrc
RUN echo "update: --no-ri --no-rdoc" >> ~/.gemrc
RUN /bin/bash --login -c "gem install bundler"

# Gem install
ADD Gemfile /home/brimir/Gemfile
ADD Gemfile.lock /home/brimir/Gemfile.lock
USER root
RUN chown brimir:staff /home/brimir/Gemfile
RUN chown brimir:staff /home/brimir/Gemfile.lock
USER brimir
RUN /bin/bash --login -c "bundle install --gemfile=/home/brimir/Gemfile --without postgresql sqlite test development"

USER root

ADD docker /root/misc
RUN cp -a /root/misc/* /
RUN chmod 644 /etc/logrotate.d/brimir

EXPOSE 80
CMD /bin/bash /root/start.sh
