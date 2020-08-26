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

data "template_file" "all_vars" {
  template = file("${path.module}/templates/all_vars.tmpl")

  depends_on = [
    digitalocean_floating_ip.swarm_gw,
    digitalocean_droplet.swarm_gw
  ]

  vars = {
    floating_ip = digitalocean_floating_ip.swarm_gw.ip_address
    do_token = var.do_token
    swarm_gw1_private_ip = digitalocean_droplet.swarm_gw[0].ipv4_address_private
    swarm_gw2_private_ip = digitalocean_droplet.swarm_gw[1].ipv4_address_private
  }
}

resource "null_resource" "define_ansible_all_vars" {
  triggers = {
    template_rendered = "${data.template_file.all_vars.rendered}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.all_vars.rendered}' > ../ansible/group_vars/all.yml"
  }
}
