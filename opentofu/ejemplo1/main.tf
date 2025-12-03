# Buscar la red por nombre (o UUID, ambos funcionan)
data "openstack_networking_network_v2" "net" {
  name = var.network
}

# Puerto Neutron
resource "openstack_networking_port_v2" "server_port" {
  name       = "server-port"
  network_id = data.openstack_networking_network_v2.net.id
}

# Instancia Nova
resource "openstack_compute_instance_v2" "my_server" {
  name        = "demo-server"
  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = var.key_name

  network {
    port = openstack_networking_port_v2.server_port.id
  }
}

# Floating IP
resource "openstack_networking_floatingip_v2" "floating_ip" {
  pool = var.public_network
}

# Asociación IP flotante ↔ puerto
resource "openstack_networking_floatingip_associate_v2" "floating_ip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.floating_ip.address
  port_id     = openstack_networking_port_v2.server_port.id
}
