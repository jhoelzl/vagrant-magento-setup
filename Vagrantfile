Vagrant.configure(2) do |config|

	config.vm.box = "hashicorp/precise64"

  	config.vm.network :forwarded_port, host: 4567, guest: 80, auto_correct: true

  	config.vm.synced_folder "./", "/var/www", create: true, group: "www-data", owner: "www-data"

  	config.vm.provider "virtualbox" do |vb|
		vb.name = "Magento 1.9.1.0 Test Environment"
   	end
 
 	config.vm.provision "shell" do |s|
    	s.path = "provision/bootstrap.sh"
	end

end