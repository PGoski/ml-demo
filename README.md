# ml-demo
Technical task

## Spinning up a development VM
After you cloned the repo, simply run vagrant up command:
~~~
vagrant up
~~~

It will spin up a CentOS 8 VM. Provision will take ~5 min. \
Vagrant will also link the ./src directory to the /devel inside the VM (via NFS).

After it finishes you can log in and start working:
~~~
vagrant ssh
sudo -i
cd /devel
~~~

## Requirements:
- Qemu-KVM, Libvirt
- Vagrant >= 2.2.5
- vagrant-libvirt plugin
- Ansible >= 2
- Python >= 3

Tested on setup:
- Ubintu 20.04 LTS (Focal Fossa)
- QEMU-KVM 4.2.0 (Debian 1:4.2-3ubuntu6.2), libvirtd (libvirt) 6.0.0
- Vagrant 2.2.9, vagrant-libvirt (0.1.2, global)
- Ansible 2.9.6, Python 3.8.2

## PS:
Ansible group_vars directory, inventory and some othes configuration files containing sensitive information are excluded (see the end of .gitignore).
