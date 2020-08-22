resource "digitalocean_ssh_key" "default" {
  name       = "swarm-ssh"
  public_key = file(var.public_ssh_key_location)
}

resource "digitalocean_vpc" "example" {
  name     = "example-project-network"
  region   = "fra1"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "swarm_manager" {
  image    = "docker-18-04"
  count    = var.swarm_managers_count
  name     = "swarm-manager-${count.index}"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  private_networking = true
  vpc_uuid = digitalocean_vpc.example.id
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  /*
  connection {
    user        = "root"
    type        = "ssh"
    host = self.ipv4_address
    private_key = file(var.private_ssh_key_location)
    timeout = "2m"
  }
  */
}

resource "digitalocean_droplet" "swarm_worker" {
  image    = "docker-18-04"
  count    = var.swarm_workers_count
  name     = "swarm-worker-${count.index}"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  private_networking = true
  vpc_uuid = digitalocean_vpc.example.id
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  /*
  connection {
    user        = "root"
    type        = "ssh"
    host = self.ipv4_address
    private_key = file(var.private_ssh_key_location)
  }
  */
}

resource "digitalocean_volume" "cassandra_data" {
  region                  = "fra1"
  count                   = var.swarm_workers_count
  name                    = "cassandra-data-${count.index}"
  size                    = 10
  initial_filesystem_type = "ext4"
  description             = "an example volume"
}

resource "digitalocean_volume_attachment" "cassandra_data_attachment" {
  count      = var.swarm_workers_count
  droplet_id = digitalocean_droplet.swarm_worker[count.index].id
  volume_id  = digitalocean_volume.cassandra_data[count.index].id
}

resource "digitalocean_droplet" "swarm_gw" {
  image    = "ubuntu-18-04-x64"
  count    = 2
  name     = "swarm-gw-${count.index}"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  private_networking = true
  vpc_uuid = digitalocean_vpc.example.id
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  /*
  connection {
    user        = "root"
    type        = "ssh"
    host = self.ipv4_address
    private_key = file(var.private_ssh_key_location)
    timeout = "2m"
  }
  */
}

resource "digitalocean_floating_ip" "swarm_gw" {
  droplet_id = digitalocean_droplet.swarm_gw[0].id
  region     = digitalocean_droplet.swarm_gw[0].region
}




data "template_file" "inventory" {
  template = file("${path.module}/templates/inventory.tmpl")

  depends_on = [
    digitalocean_droplet.swarm_manager,
    digitalocean_droplet.swarm_worker,
    digitalocean_droplet.swarm_gw,
  ]

  vars = {
    manager_ipv4_addr = "${join("\n", digitalocean_droplet.swarm_manager.*.ipv4_address_private)}"
    worker_ipv4_addr = "${join("\n", digitalocean_droplet.swarm_worker.*.ipv4_address_private)}"
    gw_ipv4_addr = "${join("\n", digitalocean_droplet.swarm_gw.*.ipv4_address)}"
  }
}

resource "null_resource" "define_ansible_inventory" {
  triggers = {
    template_rendered = "${data.template_file.inventory.rendered}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ../ansible/inventory/production.yml"
  }
}




data "template_file" "gatewayed" {
  template = file("${path.module}/templates/gatewayed.tmpl")

  depends_on = [
    digitalocean_floating_ip.swarm_gw,
  ]

  vars = {
    floating_ip = digitalocean_floating_ip.swarm_gw.ip_address
  }
}

resource "null_resource" "define_ansible_gatewayed" {
  triggers = {
    template_rendered = "${data.template_file.gatewayed.rendered}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.gatewayed.rendered}' > ../ansible/group_vars/gatewayed.yml"
  }
}





/*
resource "digitalocean_loadbalancer" "public" {
  name   = "swarm-load-balancer"
  region = "fra1"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 8080
    target_protocol = "http"
  }

  healthcheck {
    port     = 8080
    protocol = "tcp"
  }

  droplet_ids = digitalocean_droplet.swarm_worker.*.id
}

resource "digitalocean_project" "docker-swarm-cassandra" {
  name        = "docker-swarm-cassandra"
  environment = "Development"
  resources   = flatten([
    digitalocean_droplet.swarm_manager.*.urn, 
    digitalocean_droplet.swarm_worker.*.urn,
    digitalocean_volume.cassandra_data.*.urn,
    digitalocean_loadbalancer.public.urn
    ])
}
*/
