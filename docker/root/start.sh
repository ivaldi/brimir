#!/bin/bash

APP_ROOT=/home/brimir/brimir
RAILS_ROOT=$APP_ROOT
WORK_ROOT=/root

chown -R brimir:staff $APP_ROOT

cd $WORK_ROOT
. $RAILS_ROOT/.env

if test $BASIC_AUTH = "true"; then
  patch -d / -p 0 < /root/nginx-auth_basic.patch
fi

if test -n "$RAILS_RELATIVE_URL_ROOT"; then
  mkdir -p $RAILS_ROOT/public/$RAILS_RELATIVE_URL_ROOT
  ln -s $RAILS_ROOT/public/assets $RAILS_ROOT/public/$RAILS_RELATIVE_URL_ROOT/assets
fi
/home/brimir/.rbenv/versions/*/bin/ruby -pi -e '$_.sub! "__%RAILS_RELATIVE_URL_ROOT%__", "'$RAILS_RELATIVE_URL_ROOT'"' /etc/nginx/sites-available/default

RAILS_ENV=$ENVIRONMENT
sudo -u brimir -i bash -c "cd $RAILS_ROOT && bundle install"
sudo -u brimir -i bash -c "cd $RAILS_ROOT && rake db:migrate RAILS_ENV=$RAILS_ENV"
if test $RAILS_ENV = "production"; then
  sudo -u brimir -i bash -c "cd $RAILS_ROOT && rake assets:precompile RAILS_ENV=$RAILS_ENV"
fi
rm $RAILS_ROOT/tmp/pids/unicorn.pid
sudo -u brimir -i bash -c "cd $RAILS_ROOT && RAILS_ENV=$RAILS_ENV RAILS_RELATIVE_URL_ROOT=$RAILS_RELATIVE_URL_ROOT god -c $RAILS_ROOT/lib/gods/unicorn.god"
nginx

sudo cron -f
