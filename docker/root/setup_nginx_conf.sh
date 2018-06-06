if test $BASIC_AUTH != "true"; then
  patch -F 3  -d / -p 0 < /root/remove_nginx_auth_basic.patch
fi

if test -n "$ALLOW_ONLY_IOS_KEY"; then
  $APP_ROOT/../.rbenv/versions/*/bin/ruby -pi -e '$_.sub! "__%ALLOW_ONLY_IOS_KEY%__", "'$ALLOW_ONLY_IOS_KEY'"' /etc/nginx/sites-available/default
else
  patch -F 3  -d / -p 0 < /root/remove_nginx_auth_ios.patch
fi

if test -n "$RAILS_RELATIVE_URL_ROOT" && test $RAILS_ENV = "production"; then
  mkdir -p $RAILS_ROOT/public/$RAILS_RELATIVE_URL_ROOT
  ln -sf $RAILS_ROOT/public/assets $RAILS_ROOT/public/$RAILS_RELATIVE_URL_ROOT/assets
   $APP_ROOT/../.rbenv/versions/*/bin/ruby -pi -e '$_.sub! "__%RAILS_RELATIVE_URL_ROOT%__", "'$RAILS_RELATIVE_URL_ROOT'"' /etc/nginx/sites-available/default
else
  patch -F 3  -d / -p 0 < /root/remove_nginx_subdirectory_assets.patch 
fi

