#ssl certification https://techguides.yt/guides/free-wildcard-ssl-certificate-for-nextcloud-and-wordpress/

sudo apt-get install certbot python3-certbot-apache -y
sudo certbot certonly --manual -d nknc.tk --agree-tos --no-bootstrap --manual-public-ip-logging-ok --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
sudo mv /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak
sudo touch /etc/apache2/sites-available/default-ssl.conf
echo '<IfModule mod_ssl.c>
        <VirtualHost *:443>
               ServerName nknc.tk
               SSLEngine On
               SSLCertificateFile /etc/letsencrypt/live/nknc.tk/cert.pem
               SSLCertificateKeyFile /etc/letsencrypt/live/nknc.tk/privkey.pem
               DocumentRoot /var/www/nextcloud/

               <Directory /var/www/nextcloud/>
                   Require all granted
                   AllowOverride All
                   Options FollowSymLinks MultiViews

                   <IfModule mod_dav.c>
                    Dav off
                   </IfModule>

               SetEnv HOME /var/www/nextcloud
                   SetEnv HTTP_HOME /var/www/nextcloud

                   RewriteEngine On
                   RewriteRule ^/\.well-known/carddav https://%{SERVER_NAME}/remote.php/dav/ [R=301,L]
                   RewriteRule ^/\.well-known/caldav https://%{SERVER_NAME}/remote.php/dav/ [R=301,L]
                   RewriteRule ^/\.well-known/host-meta https://%{SERVER_NAME}/public.php?service=host-meta [QSA,L]
                   RewriteRule ^/\.well-known/host-meta\.json https://%{SERVER_NAME}/public.php?service=host-meta-json [QSA,L]
                   RewriteRule ^/\.well-known/webfinger https://%{SERVER_NAME}/public.php?service=webfinger [QSA,L]

                   <IfModule mod_headers.c>
                   Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
                   </IfModule>

               </Directory>

               ErrorLog ${APACHE_LOG_DIR}/error.log
               CustomLog ${APACHE_LOG_DIR}/access.log combined

       </VirtualHost>
</IfModule>' | sudo tee -a /etc/apache2/sites-available/default-ssl.conf > /dev/null
#sudo nano /etc/apache2/sites-available/default-ssl.conf
sudo a2ensite default-ssl.conf
sudo a2enmod ssl
sudo a2enmod rewrite
sudo service apache2 restart
