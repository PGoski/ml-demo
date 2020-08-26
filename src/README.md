## Introduction

This is a set of Terraform configuration files and Ansible playbooks for deploying a Swarm cluster with Cassandra to DigitalOceans cloud.

## How to deploy

First, init, plan and apply Terraform configuration:
~~~
terraform init
terraform plan
terraform apply -auto-approve
~~~

After Terraform finishes, run all-init.yml Ansible playbook:
~~~
ansible-playbook all-init.yml
~~~

This play will create users and disable root ssh. So, from now on we should start using technical account for configuring nodes. \
\
Run all remaining Ansible plays:
~~~
ansible-playbook all-common.yml  # Runs common tasks on all nodes
ansible-playbook gw.yml  # Configures gateways
ansible-playbook swarm.yml  # Configures Swarm cluster
ansible-playbook cassandra.yml  # Deploys Cassandra cluster on the created Swarm
~~~

## To Do:

* Currently the upscaling of the cluster works great but we should do downscaling, too!

* Terraform and Ansible files should be in a separate (private) repos. That will allow us to create a pretty nifty CI/CD pipeline. One example would be:
  - After Haproxy+Swarm monitoring will see a greater increase of load, where existing nodes can't keep up, it can push refreshed Terraform config to master (i.e increased cluster size)
  - This will trigger a Terraform action (test & deploy).
  - Successful Terraform deploy will trigger an Ansible action, which will add Swarm workers to a cluster and deploy additional Cassandra nodes.

* Improve security of gateways and Cassandra endpoints

* Secure all secrets. Some password-manager implementation would be great to have!
