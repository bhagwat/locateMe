NameVirtualHost bhagwat-kumar.appspot.com:80
<VirtualHost bhagwat-kumar.appspot.com>
        ServerName   bhagwat-kumar.appspot.com
	ServerAlias bhagwat-kumar.appspot.com
        UseCanonicalName On
        RewriteEngine On
        ServerAdmin  "radialgoal@gmail.com"
        TransferLog  /var/log/apache2/facebook_google_map_access_log 
        ErrorLog  /var/log/apache2/facebook_google_map_error_log 
	DocumentRoot /var/www/facebook_google_map
        ErrorDocument 503 /errors/error404.html
		AddDefaultCharset UTF-8
	<IfModule mod_proxy.c>
		ProxyPass / http://localhost:8080/
		ProxyPassReverse / http://localhost:8080/
		ProxyPreserveHost On
	</IfModule>

	<Location />
		order allow,deny
		allow from all
		<IfModule mod_deflate.c>
			AddOutputFilterByType DEFLATE text/html text/css text/plain text/xml application/x-javascript application/javascript
			# Netscape 4.x has some problems...
			BrowserMatch ^Mozilla/4 gzip-only-text/html
			# Netscape 4.06-4.08 have some more problems
			BrowserMatch ^Mozilla/4\.0[678] no-gzip
			# MSIE masquerades as Netscape, but it is fine
					# BrowserMatch \bMSIE !no-gzip !gzip-only-text/html
			# NOTE: Due to a bug in mod_setenvif up to Apache 2.0.48
			# the above regex won't work. You can use the following
			# workaround to get the desired effect:
			BrowserMatch \bMSI[E] !no-gzip !gzip-only-text/html

			# Make sure proxies don't deliver the wrong content
			Header append Vary User-Agent env=!dont-vary
		</IfModule> 
	</Location>

    RewriteRule ^/errors/error404.html /errors/error404.html

</VirtualHost>

