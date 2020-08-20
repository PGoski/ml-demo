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
