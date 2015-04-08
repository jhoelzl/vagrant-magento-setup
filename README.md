# Vagrant Magento Nginx
Vagrant Configuration Setup for Magento

## Installs

* Magento CE 1.9.1.0
* MySQL
* Git
* PHP
* PHP-FPM
* Nginx
* Composer
* n98-magerun

## Getting Started

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](http://www.vagrantup.com/)
* Clone or [download](https://github.com/jhoelzl/vagrant-magento-setup/archive/master.zip) this repository to the root of your project directory `git clone https://github.com/jhoelzl/vagrant-magento-setup`
* In your project directory, run `vagrant up` and `vagrant ssh`
* You can access the shop frontend over port 4567: [http://127.0.0.1:4567](http://127.0.0.1:4567)
* When you're done, run `vagrant halt`

The first time you run this, Vagrant will download the bare Ubuntu box image. This can take a little while as the image is a few-hundred Mb. This is only performed once.

## Login Credentials
* SSH user / password / port: vagrant / vagrant / 2222
* mySQL root user / password / port: root / 1234 / 3306
* mySQL database: magento
* mySQL magento user / password / port: magento_user / magento_pass / 3306
* Magento backend user / password: admin / m123456789

## Customize
When you change settings in the Vagrantfile, run `vagrant reload --provision` in order to update the settings. Feel free to make a pull request when you have improved something!
