#!/bin/sh
if [ ! -f /etc/phpmyadmin/config.secret.inc.php ]; then
    cat > /etc/phpmyadmin/config.secret.inc.php <<EOT
<?php
\$cfg['blowfish_secret'] = '$(tr -dc 'a-zA-Z0-9~!@#$%^&*_()+}{?></";.,[]=-' < /dev/urandom | fold -w 32 | head -n 1)';
EOT
fi

if [ ! -f /etc/phpmyadmin/config.user.inc.php ]; then
    touch /etc/phpmyadmin/config.user.inc.php
fi

mkdir -p /var/nginx/client_body_temp
chown nobody:nogroup /sessions /var/nginx/client_body_temp
mkdir -p /var/run/php/
chown nobody:nogroup /var/run/php/
touch /var/log/php-fpm.log
chown nobody:nogroup /var/log/php-fpm.log

if [ ! -f /etc/ssl/phpmyadmin.pem ]; then
	curl -s -d @/opt/phpmyadmin.csr.json cfssl:8888/api/v1/cfssl/newcert | cfssljson phpmyadmin
	curl -s -d '{ "label": "default" }' cfssl:8888/api/v1/cfssl/info | jq -r .result.certificate > root.pem
	cat root.pem >> phpmyadmin.pem
	mv phpmyadmin* /etc/ssl/
fi

exec "$@"
