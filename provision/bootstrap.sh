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
cp /var/www/provision/nginx_vhost /etc/nginx/sites-available/nginx_vhost > /dev/null
ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled/
rm -rf /etc/nginx/sites-available/default
service nginx restart > /dev/null

#echo "Download Magento CE 1.9.x"
#cd /vagrant
#wget http://www.magentocommerce.com/downloads/assets/1.9.1.0/magento-1.9.1.0.tar.gz > /dev/null 2>&1
#tar zxvf magento-1.9.1.0.tar.gz > /dev/null
#rm -f xvf magento-1.9.1.0.tar.gz

echo "Checkout Magento CE 1.9.1.x with latest Patches"
cd /vagrant
git clone --depth=1 https://github.com/mageprofis/magento.git magento
rm -rf /vagrant/magento/.git

echo "Remove obsolete Magento Files"
cd /vagrant/magento
rm -f RELEASE_NOTES.txt
rm -f LICENSE_AFL.txt
rm -f LICENSE.html
rm -f LICENSE.txt
rm -f favicon.ico
rm -r PATCH_*

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

echo "Install Magento CE"
cd /vagrant/magento
php -f install.php -- --license_agreement_accepted yes --locale "de_DE" --timezone "America/Phoenix" --default_currency EUR --db_host "127.0.0.1" --db_name magento --db_user magento_user --db_pass magento_pass --db_prefix "" --session_save "files" --admin_frontname "admin" --url "http://localhost/" --use_rewrites "yes" --use_secure "no" --secure_base_url "http://localhost/" --use_secure_admin "yes" --admin_firstname "Admin" --admin_lastname "Admin" --admin_email "admin.user@example.com" --admin_username "admin" --admin_password "m123456789"

echo "Adjust Base URLs"
mysql -u root -p1234 -e "UPDATE magento.core_config_data set value ='http://127.0.0.1:4567/' where path like '%base_url%';"

echo "Install n98-magerun and its bash-completion"
cd /vagrant/magento
wget "https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar" > /dev/null 2>&1
wget "https://raw.githubusercontent.com/netz98/n98-magerun/master/autocompletion/bash/bash_complete" -O "magerun-bash-completion" > /dev/null 2>&1
chmod +x ./n98-magerun.phar
mv ./n98-magerun.phar /usr/local/bin/
mv ./magerun-bash-completion /etc/bash_completion.d/n98-magerun.phar
n98-magerun.phar dev:symlinks --on --global

echo "Install Composer"
cd /vagrant
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

echo "Install useful Magento modules through Composer"
cd /vagrant/composer
composer update

echo "Install modman and its bash-completion"
wget "https://raw.githubusercontent.com/colinmollenhour/modman/master/modman" > /dev/null 2>&1
wget "https://raw.githubusercontent.com/colinmollenhour/modman/master/bash_completion" -O "modman-bash-completion" > /dev/null 2>&1
chmod +x ./modman
mv ./modman /usr/local/bin/
mv ./modman-bash-completion /etc/bash_completion.d/modman

echo "Install generate-modman"
cd /vagrant/magento
curl -sS https://raw.githubusercontent.com/mhauri/generate-modman/master/generate-modman > generate-modman
mv generate-modman /usr/local/bin
chmod 755 /usr/local/bin/generate-modman

echo "Clear Cache and Reindex"
cd /vagrant/magento
n98-magerun.phar cache:enable
n98-magerun.phar cache:flush
n98-magerun.phar cache:clean
n98-magerun.phar index:reindex:all

echo "Finished provisioning."