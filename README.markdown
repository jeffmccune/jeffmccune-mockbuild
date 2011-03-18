# Puppet mockbuild Module

Jeff McCune <jeff@puppetlabs.com>
2011-03-17

This module manages a basic RPM Build environment.  I've tested this with the
vagrant boxes for CentOS 5.5 64 bit and RHEL 6.0 64 Bit.

The Vagrant boxes should be posted to:

 http://vagrantbox.es/

The overall idea is that a vagrant project directory will be used to build
packages from a base box.  This module should be used with the Puppet
provisioner in Vagrant to provision the build box.

## Example Vagrantfile

    Vagrant::Config.run do |config|

      # Change this box name depending on the system you want.
      box = "rhel60_64"

      # Every Vagrant virtual environment requires a box to build off of.
      config.vm.box = "#{box}"
      config.vm.box_url = "http://faro.puppetlabs.lan/vagrant/#{box}.box"

      config.vm.customize do |vm|
        vm.memory_size = 768
        vm.cpu_count = 2
      end

      config.vm.provision :shell, :path => "setup_build_env.sh"

      # This will provision the box using puppet
      config.vm.provision :puppet do |puppet|
        puppet.options        = "-v --vardir=/var/lib/puppet --ssldir=/var/lib/puppet/ssl"
        puppet.module_path    = "modules"
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = "site.pp"
      end

    end

