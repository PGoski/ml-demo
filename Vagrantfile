# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

Vagrant.require_version ">= 2.2.5"
VAGRANTFILE_API_VERSION = "2"

machines = YAML.load_file('hosts.yml')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.provider 'libvirt'
    
    machines.each do |machine|
        config.vm.define machine['name'] do |node|

            node.vm.box = machine['box']
            node.vm.hostname = machine['name']
            node.vm.synced_folder '.', '/vagrant', disabled: true
            node.vm.network :private_network, :ip => machine['ip']

            node.vm.provider 'libvirt' do |vb|
                vb.memory = machine['ram']
                vb.cpus = machine['cpus']
            end

            if machine.has_key?('network_ports')
                machine['network_ports'].each do |port|
                    node.vm.network "forwarded_port", guest: port['guest'], host: port['host']
                end
            end

            if machine.has_key?('nfs_folders')              
                machine['nfs_folders'].each do |nfs_folders|
                    node.vm.synced_folder nfs_folders['src'], nfs_folders['dest'], type: "nfs"
                end
            end

            if machine.has_key?('provision')
                machine['provision'].each do |script|
                    node.vm.provision "shell", path: script['src']
                end
            end

        end
    end
end
