#!/bin/bash

# Variables
read -p "Username: " user
read -p "Domain: " domain
dir="/var/www/$domain"

# Create user and directory
mkdir $dir
/sbin/adduser $user
chown -R $user:www-data $dir
/sbin/adduser $user www-data
echo "$domain will be here soon" > $dir/index.php

# phpfpm socket config
cat <<EOT >> /etc/php/8.3/fpm/pool.d/$domain.conf
[$domain]
listen = /var/lib/php8.3-fpm/$domain.sock
listen.owner = $user
listen.group = www-data
listen.mode = 0660

user = $user
group = www-data

pm = static
pm.max_children = 15

chdir = /

env[HOSTNAME] = \$HOSTNAME
env[PATH] = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EOT

# nginx config
cat <<EOT >> /etc/nginx/sites-enabled/$domain.vhost
server {
  server_name  www.$domain;
  rewrite ^(.*) https://$domain\$1 permanent;
  listen 80;
  #listen 443 ssl http2; # managed by Certbot
}

server {
  server_name $domain;
  root $dir/;
  index index.php;

	location = /xmlrpc.php {
		deny all;
	}
	location = /favicon.ico {
		log_not_found off;
		access_log off;
	}
	location = /robots.txt {
		allow all;
		log_not_found off;
		access_log off;
	}

	location ~ \.php$ {
		try_files /e1d4ea2d073f20faebaf9539ddde872c.htm @php;
	}
	location @php {
		try_files \$uri =404;
		include /etc/nginx/fastcgi_params;
		fastcgi_pass unix:/var/lib/php8.3-fpm/$domain.sock;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		fastcgi_intercept_errors on;
	}

	location ~ ^/(status|ping)$ {
		access_log off;
		deny all;
	}
	location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc|css|js|woff|woff2|webp)$ {
		expires max;
		add_header Pragma public;
		add_header Cache-Control "public, must-revalidate, proxy-revalidate";
	}
	location / {
		try_files \$uri \$uri/ /index.php?\$args;
	}

	#error_page 404 /404.php;
	listen 80;
	#listen 443 ssl http2;
}
EOT

# Restart nginx + php
systemctl restart nginx && systemctl restart php8.3-fpm
