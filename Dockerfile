FROM ubuntu:precise

RUN echo 'deb http://nl3.archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list

RUN apt-get update

# install required dependencies for everything below
RUN apt-get install -y git curl build-essential autoconf libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libpq-dev nodejs postgresql pwgen libcurl4-openssl-dev imagemagick

# install ruby-build
RUN git clone https://github.com/sstephenson/ruby-build.git /tmp/ruby-build
RUN /tmp/ruby-build/install.sh
RUN rm -r /tmp/ruby-build

# install ruby in /usr/local
RUN ruby-build 2.0.0-p353 /usr/local

# install bundler
RUN gem install bundle

# clone the repo
RUN git clone https://github.com/ivaldi/brimir /home/brimir/

# add a javascript runtime
RUN echo 'gem "therubyracer"' >> /home/brimir/Gemfile

# install all gems needed for production
RUN cd /home/brimir && bundle install --without development:test

# install passenger & nginx
RUN gem install passenger
RUN passenger-install-nginx-module --auto --auto-download --prefix=/usr/local
RUN head -n `grep -n server /usr/local/conf/nginx.conf | head -n 1 | awk -F: '{print $1}'` /usr/local/conf/nginx.conf > /tmp/nginx.conf
RUN echo '\nserver_name localhost;\nroot /home/brimir/public;\npassenger_enabled on;\n}\n}\ndaemon off;' >> /tmp/nginx.conf
RUN mv /tmp/nginx.conf /usr/local/conf/nginx.conf

# setup database using our local script
RUN /home/brimir/script/setup-database /home/brimir/

ENV RAILS_ENV production
# precompile assets
RUN cd /home/brimir && rake assets:precompile
# load database schema and fill with default seed data
RUN service postgresql start && cd /home/brimir && rake db:migrate && rake db:seed

CMD service postgresql start && /usr/local/sbin/nginx
EXPOSE 80
