output "swarm_manager_ip" {
  value = digitalocean_droplet.swarm_manager.*.ipv4_address_private
}

output "swarm_worker_ip" {
  value = digitalocean_droplet.swarm_worker.*.ipv4_address_private
}

output "swarm_gw_ip" {
  value = digitalocean_droplet.swarm_gw.*.ipv4_address
}

output "floating_ip" {
  value = digitalocean_floating_ip.swarm_gw.ip_address
}

/*
output "swarm_loadbalancer_ip" {
  value = digitalocean_loadbalancer.public.ip
}
*/