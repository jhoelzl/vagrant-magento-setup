#!/usr/bin/env bash

echo "Provisioning virtual machine..."
apt-get update > /dev/null

echo "Installing Git"
apt-get install git -y > /dev/null
 
echo "Installing Nginx"
apt-get install nginx -y > /dev/null

echo "Updating PHP repository"
apt-get install python-software-properties build-essential -y > /dev/null
add-apt-repository ppa:ondrej/php5 -y > /dev/null
apt-get update > /dev/null


echo "Installing PHP"
apt-get install php5-common php5-dev php5-cli php5-fpm -y > /dev/null
 
echo "Installing PHP extensions"
apt-get install curl php5-curl php5-gd php5-mcrypt php5-mysql -y > /dev/null

echo "Preparing MySQL"
apt-get install debconf-utils -y > /dev/null
debconf-set-selections <<< "mysql-server mysql-server/root_password password 1234"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 1234"

echo "Installing MySQL"
apt-get install mysql-server -y > /dev/null

echo "Preparing Magento Database and User"
sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
mysql -u root -p1234 -e "create database IF NOT EXISTS magento; GRANT ALL PRIVILEGES ON magento.* TO magento_user@'%' IDENTIFIED BY 'magento_pass'; GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY '1234';"
service mysql restart > /dev/null

echo "Configuring Nginx"
cp /var/www/provision/config/nginx_vhost /etc/nginx/sites-available/nginx_vhost > /dev/null
ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled/
rm -rf /etc/nginx/sites-available/default
service nginx restart > /dev/null

echo "Install n98-magerun"
cd /vagrant/magento
wget https://raw.github.com/netz98/n98-magerun/master/n98-magerun.phar > /dev/null 2>&1
chmod +x ./n98-magerun.phar
sudo mv ./n98-magerun.phar /usr/local/bin/

echo "Install Composer"
cd /vagrant
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

#echo "Download Magento CE 1.9.x"
#cd /vagrant
#wget http://www.magentocommerce.com/downloads/assets/1.9.1.0/magento-1.9.1.0.tar.gz > /dev/null 2>&1
#tar zxvf magento-1.9.1.0.tar.gz > /dev/null
#rm -f xvf magento-1.9.1.0.tar.gz

echo "Install Magento CE and useful modules through Composer"
mkdir -p /vagrant/magento
cd /vagrant/composer
composer update

echo "Set correct Permissions"
cd /vagrant/magento
chmod -R o+w media var
chmod o+w app/etc
chown -R vagrant:vagrant /vagrant
find . -type d -exec chmod 775 {} \;
find . -type f -exec chmod 664 {} \;
chmod -R 777 app/etc/*
chmod -R 777 var/*
chmod -R 777 media/*
chmod 550 mage

echo "Remove obsolete Files"
cd /vagrant/magento
rm -f RELEASE_NOTES.txt
rm -f LICENSE_AFL.txt
rm -f LICENSE.html
rm -f LICENSE.txt

echo "Install Magento CE"
cd /vagrant/magento
php -f install.php -- \
--license_agreement_accepted yes \
--locale "de_DE" \
--timezone "America/Phoenix" \
--default_currency EUR \
--db_host "127.0.0.1" \
--db_name magento \
--db_user magento_user \
--db_pass magento_pass \
--db_prefix "" \
--session_save "files" \
--admin_frontname "admin" \
--url "http://localhost/" \
--use_rewrites "yes" \
--use_secure "no" \
--secure_base_url "http://localhost/" \
--use_secure_admin "yes" \
--admin_firstname "Admin" \
--admin_lastname "Admin" \
--admin_email "admin.user@example.com" \
--admin_username "admin" \
--admin_password "m123456789" \
--encryption_key "BRuvuCrUd4aSWutr"

echo "Adjust URLs and Reindex"
mysql -u root -p1234 -e "UPDATE magento.core_config_data set value ='http://127.0.0.1:4567/' where path like '%base_url%';"
php -f shell/indexer.php reindexall

echo "Finished provisioning."
