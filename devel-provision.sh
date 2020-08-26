#!/usr/bin/env bash

# Install common libraries
yum install -y yum-utils
yum install -y epel-release
yum install -y \
    git \
    htop \
    net-tools \
    telnet \
    wget \
    vim \
    jq

# Install Terraform
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform
terraform -install-autocomplete

# Install Ansible
yum install -y ansible
ansible-galaxy install kwoodson.yedit

# Clean cache
yum clean all
dnf clean all
