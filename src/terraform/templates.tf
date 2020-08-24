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

data "template_file" "swarm_cluster_vars" {
  template = file("${path.module}/templates/swarm_cluster.tmpl")

  depends_on = [
    digitalocean_floating_ip.swarm_gw,
  ]

  vars = {
    floating_ip = digitalocean_floating_ip.swarm_gw.ip_address
  }
}

resource "null_resource" "define_ansible_swarm_cluster_vars" {
  triggers = {
    template_rendered = "${data.template_file.swarm_cluster_vars.rendered}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.swarm_cluster_vars.rendered}' > ../ansible/group_vars/swarm_cluster.yml"
  }
}
