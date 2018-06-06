#!/bin/bash

APP_ROOT=/home/brimir/brimir
RAILS_ROOT=$APP_ROOT
WORK_ROOT=/root

chown -R brimir:staff $APP_ROOT

cd $WORK_ROOT
. $RAILS_ROOT/.env

RAILS_ENV=$ENVIRONMENT

. setup_nginx_conf.sh

sudo -u brimir -i bash -c "cd $RAILS_ROOT && bundle install"
sudo -u brimir -i bash -c "cd $RAILS_ROOT && rake db:migrate RAILS_ENV=$RAILS_ENV"
if test $RAILS_ENV = "production"; then
  sudo -u brimir -i bash -c "cd $RAILS_ROOT && rake assets:precompile RAILS_ENV=$RAILS_ENV"
fi
rm $RAILS_ROOT/tmp/pids/unicorn.pid
sudo -u brimir -i bash -c "cd $RAILS_ROOT && RAILS_ENV=$RAILS_ENV RAILS_RELATIVE_URL_ROOT=$RAILS_RELATIVE_URL_ROOT god -c $RAILS_ROOT/lib/gods/unicorn.god"
nginx

sudo cron -f
