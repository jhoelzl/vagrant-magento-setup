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
sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

echo "Preparing Magento Database and User"
mysql -u root -p1234 -e "create database IF NOT EXISTS magento2; GRANT ALL PRIVILEGES ON magento.* TO magento_user@'%' IDENTIFIED BY 'magento_pass'"
service mysql restart > /dev/null

echo "Installing MySQL"
apt-get install mysql-server -y > /dev/null

echo "Configuring Nginx"
cp /var/www/provision/config/nginx_vhost /etc/nginx/sites-available/nginx_vhost > /dev/null
ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled/
rm -rf /etc/nginx/sites-available/default
service nginx restart > /dev/null


echo "Install n98-magerun"
cd /vagrant/
wget https://raw.github.com/netz98/n98-magerun/master/n98-magerun.phar
chmod +x ./n98-magerun.phar
sudo mv ./n98-magerun.phar /usr/local/bin/


echo "Finished provisioning."
