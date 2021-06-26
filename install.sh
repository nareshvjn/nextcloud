#!/bin/bash

#nextcloud installation https://techguides.yt/guides/how-to-install-and-configure-nextcloud-hub-21/
sudo timedatectl set-timezone Asia/Kolkata
sudo apt update
sudo apt install apache2 mysql-server php7.4 php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring php7.4-intl php7.4-gmp php7.4-bcmath php7.4-xml libapache2-mod-php7.4 php7.4-zip php-apcu -y
sudo mysql_secure_installation
read -p "Enter database name: " db
read -p "Enter Username for database: " user
stty -echo
read -p "Enter password for database: " pass
read -p "Enter password for mysql root: " rootpass
stty echo
sudo mysql -p=$rootpass -u "root" -Bse "CREATE DATABASE $db;
CREATE USER '${user}'@'localhost' IDENTIFIED BY '${pass}';
GRANT ALL PRIVILEGES ON $db.* TO '${user}'@'localhost';
flush privileges;
quit"
#mysql> create database nextcloud;
#mysql> create user 'nextcloud'@'localhost' identified by 'nkvjn';
#mysql> grant all privileges on nextcloud.* to 'nextcloud'@'localhost';
#mysql> flush privileges;
#mysql> quit
#wget https://download.nextcloud.com/server/releases/nextcloud-21.0.2.zip
sudo unzip nextcloud-21.0.2.zip -d /var/www
cd /var/www
sudo chown -R www-data:www-data nextcloud/
sudo a2enmod headers env dir mime rewrite
sudo service apache2 restart
sudo mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak
sudo touch /etc/apache2/sites-available/000-default.conf
echo '<VirtualHost *:80>

    ServerName cloud.yourdomain.com
    DocumentRoot /var/www/nextcloud

    <Directory /var/www/nextcloud/>
        Require all granted
        AllowOverride All
        Options FollowSymLinks

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

</VirtualHost>' | sudo tee -a /etc/apache2/sites-available/000-default.conf > /dev/null
#sudo nano /etc/apache2/sites-available/000-default.conf
sudo service apache2 restart
read -p "open http://`hostname -I | cut -d' ' -f1` and press Enter" enter
read -p "Enter domain name: " dns
if [ "$dns" != "" ]; then
sudo sed -i "9i 1 => '$dns'," /var/www/nextcloud/config/config.php
fi
sudo sed -i "11i\  \'default_phone_region' => 'IN'," /var/www/nextcloud/config/config.php
sudo sed -i "12i\  \'memcache.local' => '\\\OC\\\Memcache\\\APCu'," /var/www/nextcloud/config/config.php
sudo sed -i "13i\  \'htaccess.RewriteBase' => '/'," /var/www/nextcloud/config/config.php
#echo "#  'trusted_domains' =>
#  array(
#    0 => 192.168.1.50:80
#    1 => yourdomain.com
#  ),
#  'default_phone_region' => 'IN',
#  'memcache.local' => '\OC\Memcache\APCu',
#  'htaccess.RewriteBase' => '/'," | sudo tee -a /var/www/nextcloud/config/config.php > /dev/null
#sudo nano /var/www/nextcloud/config/config.php
sudo -u www-data php /var/www/nextcloud/occ maintenance:update:htaccess
#sudo cp -a /var/www/nextcloud/data/. /mnt/cloud/data/

sudo sed -i '409 s/128/512/' /etc/php/7.4/apache2/php.ini
#sudo nano /etc/php/7.4/apache2/php.ini
#memory_limit = 512M
read -p "Paste this next window */5  *  *  *  * php -f /var/www/nextcloud/cron.php" cron
sudo crontab -u www-data -e

#sudo apt remove imagemagick-6-common php-imagick -y
#sudo apt autoremove -y
sudo apt install imagemagick php-imagick -y

#ssl certification https://techguides.yt/guides/free-wildcard-ssl-certificate-for-nextcloud-and-wordpress/

#sudo apt-get install certbot python3-certbot-apache -y
#sudo certbot certonly --manual -d nknc.tk --agree-tos --no-bootstrap --manual-public-ip-logging-ok --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
#echo '<IfModule mod_ssl.c>
#        <VirtualHost *:443>
#               ServerName nknc.tk
#               SSLEngine On
#               SSLCertificateFile /etc/letsencrypt/live/nknc.tk/cert.pem
#               SSLCertificateKeyFile /etc/letsencrypt/live/nknc.tk/privkey.pem
#               DocumentRoot /var/www/nextcloud/
#
#               <Directory /var/www/nextcloud/>
#                   Require all granted
#                   AllowOverride All
#                   Options FollowSymLinks MultiViews
#
#                   <IfModule mod_dav.c>
#                    Dav off
#                   </IfModule>
#
#	            SetEnv HOME /var/www/nextcloud
#                   SetEnv HTTP_HOME /var/www/nextcloud
#
#                   RewriteEngine On
#                   RewriteRule ^/\.well-known/carddav https://%{SERVER_NAME}/remote.php/dav/ [R=301,L]
#                   RewriteRule ^/\.well-known/caldav https://%{SERVER_NAME}/remote.php/dav/ [R=301,L]
#                   RewriteRule ^/\.well-known/host-meta https://%{SERVER_NAME}/public.php?service=host-meta [QSA,L]
#                   RewriteRule ^/\.well-known/host-meta\.json https://%{SERVER_NAME}/public.php?service=host-meta-json [QSA,L]
#                   RewriteRule ^/\.well-known/webfinger https://%{SERVER_NAME}/public.php?service=webfinger [QSA,L]
#
#                   <IfModule mod_headers.c>
#                   Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
#                   </IfModule>
#
#               </Directory>
#
#               ErrorLog ${APACHE_LOG_DIR}/error.log
#               CustomLog ${APACHE_LOG_DIR}/access.log combined
#
#       </VirtualHost>
#</IfModule>' | sudo tee -a /etc/apache2/sites-available/default-ssl.conf > /dev/null
#sudo nano /etc/apache2/sites-available/default-ssl.conf
#sudo a2ensite default-ssl.conf
#sudo a2enmod ssl
#sudo a2enmod rewrite
sudo service apache2 restart
echo "You have successfully installed NextCloud
Please visit http://`hostname -I | cut -d' ' -f1`"
read -p "Press ENTER to exit" bye
kill -9 $PPID
