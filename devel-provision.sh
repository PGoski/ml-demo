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
    vim

# Install Terraform
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform
terraform -install-autocomplete

# Install Ansible
yum install -y ansible

# Install and enable LibVirt
# yum install @virt
# dnf -y install virt-top libguestfs-tools
dnf module install -y virt
dnf install -y virt-install virt-viewer libguestfs-tools
systemctl enable libvirtd.service
systemctl start libvirtd.service

# Clean cache
yum clean all
dnf clean all
