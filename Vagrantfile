# -*- mode: ruby -*-
# vi: set ft=ruby:


require 'yaml'
boxes = ENV['BOXES'] || ['ubuntu/xenial64', 'gobadiah/macos-sierra']
DEFAULT_VM_MEMORY = 1024
DEFAULT_VM_CPU = 2
VAGRANT_CONFIG_VERSION = 2

Vagrant.configure(VAGRANT_CONFIG_VERSION) do |config|
  Array(boxes).each do |image|
    config.vm.define image.to_s.sub('/', '_') do |box|
      box.vm.box = image.to_s
      box.vm.provider "virtualbox" do |vb|
        vb.memory = DEFAULT_VM_MEMORY
        vb.cpus = DEFAULT_VM_CPU
      end
      box.ssh.forward_agent = true

      config.vm.synced_folder ".", "/vagrant", type: "rsync" # or "rsync"
      config.vm.provision "shell", privileged: false, name: "shell", inline: <<-SHELL
        /vagrant/dotfiles/install.sh
      SHELL
    end
  end
end
