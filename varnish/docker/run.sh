
# Waiting for remote host

if [ ! -n "$REMOTE_HOST" ] || [ ! -n "$REMOTE_PORT" ]; then
  echo 'TARGET_HOST and TARGET_PORT must be set. Exiting...'
  exit 1
fi

COUNT=0
until nc -z -v -w30 $REMOTE_HOST $REMOTE_PORT; do
  echo 'Waiting for Remote Host...'
  sleep 0.5

  COUNT=$((COUNT+1))

  if [ $COUNT -gt 60 ]; then
    echo 'Remote host is not ready. Exiting...'
    exit 1
  fi
done

# Applying default.vcl variables 
sed -i "s~\$REMOTE_HOST~$REMOTE_HOST~g" /etc/varnish/default.vcl
sed -i "s~\$REMOTE_PORT~$REMOTE_PORT~g" /etc/varnish/default.vcl

varnishd \
  -a :80 \
  -T localhost:6082 \
  -f /etc/varnish/default.vcl \
  -S /etc/varnish/secret \
  -s malloc,256m

varnishncsa