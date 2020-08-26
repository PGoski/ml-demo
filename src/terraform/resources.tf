resource "digitalocean_ssh_key" "default" {
  name       = "swarm-ssh"
  public_key = file(var.public_ssh_key_location)
}

resource "digitalocean_vpc" "example" {
  name     = "swarm-cassandra-network"
  region   = "fra1"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "swarm_manager" {
  image    = "docker-18-04"
  count    = var.swarm_managers_count
  name     = "swarm-manager-${count.index + 1}"
  region   = "fra1"
  size     = var.swarm_managers_size
  private_networking = true
  vpc_uuid = digitalocean_vpc.example.id
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}

resource "digitalocean_droplet" "swarm_worker" {
  image    = "docker-18-04"
  count    = var.swarm_workers_count
  name     = "swarm-worker-${count.index + 1}"
  region   = "fra1"
  size     = var.swarm_workers_size
  private_networking = true
  vpc_uuid = digitalocean_vpc.example.id
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}

resource "digitalocean_volume" "cassandra_data" {
  region                  = "fra1"
  count                   = var.swarm_workers_count
  name                    = "cassandra-data-${count.index + 1}"
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
  name     = "swarm-gw-${count.index + 1}"
  region   = "fra1"
  size     = var.swarm_gw_size
  private_networking = true
  vpc_uuid = digitalocean_vpc.example.id
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}

resource "digitalocean_floating_ip" "swarm_gw" {
  droplet_id = digitalocean_droplet.swarm_gw[0].id
  region     = digitalocean_droplet.swarm_gw[0].region
}
