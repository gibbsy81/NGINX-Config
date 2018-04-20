#If Server Accessed on HTTP Return 301 to HTTPS
server {
	listen 80;
	server_name example.com www.example.com;
	return 301 https://example.com/;
}
#HTTP
server {
	listen 443 ssl;
	server_name example.com www.example.com;
	ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
	root /var/www/example.com;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	ssl_prefer_server_ciphers on;
	ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';

	#Max Upload Size
	client_max_body_size 100M;
	
	# Add index.php to the list if you are using PHP
	index index.php index.html index.htm index.nginx-debian.html;
	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ =404;
	}

	# pass PHP scripts to FastCGI server
	#
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
	
		# With php-fpm (or other unix sockets):
		fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
		# With php-cgi (or other tcp sockets):
		#fastcgi_pass 127.0.0.1:9000;
	}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	location ~ /\.ht {
		deny all;
	}
}
