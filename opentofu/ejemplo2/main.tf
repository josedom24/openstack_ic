#############################################
# 1. Resolver red por nombre (para usar ports)
#############################################

data "openstack_networking_network_v2" "net" {
  name = var.network
}


#############################################
# 2. Security Group SSH
#############################################

resource "openstack_networking_secgroup_v2" "ssh_sg" {
  name        = "ssh-sg"
  description = "Permite acceso SSH"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ssh_sg.id
}


#############################################
# 3. Puerto Neutron para la instancia
#############################################

resource "openstack_networking_port_v2" "server_port" {
  name       = "server-port"
  network_id = data.openstack_networking_network_v2.net.id

  security_group_ids = [
    openstack_networking_secgroup_v2.ssh_sg.id
  ]
}


#############################################
# 4. Volumen raíz (boot from volume)
#############################################

data "openstack_images_image_v2" "img" {
  name = var.image
}

resource "openstack_blockstorage_volume_v3" "root_volume" {
  name     = "root-volume"
  size     = var.root_volume_size
  image_id = data.openstack_images_image_v2.img.id
}

#############################################
# 5. Volumen adicional (data)
#############################################

resource "openstack_blockstorage_volume_v3" "data_volume" {
  name = "data-volume"
  size = var.data_volume_size
}


#############################################
# 6. Instancia que arranca desde un volumen
#############################################

resource "openstack_compute_instance_v2" "my_server" {
  name        = "demo-server-vol"
  flavor_name = var.flavor
  key_pair    = var.key_name

  network {
    port = openstack_networking_port_v2.server_port.id
  }

  # Boot from volume
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.root_volume.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = false
  }
}


#############################################
# 7. Adjuntar el volumen adicional a la VM
#############################################

resource "openstack_compute_volume_attach_v2" "attach_data_volume" {
  instance_id = openstack_compute_instance_v2.my_server.id
  volume_id   = openstack_blockstorage_volume_v3.data_volume.id
  device      = "/dev/vdb"
}


#############################################
# 8. Floating IP + asociación
#############################################

resource "openstack_networking_floatingip_v2" "floating_ip" {
  pool = var.public_network
}

resource "openstack_networking_floatingip_associate_v2" "floating_ip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.floating_ip.address
  port_id     = openstack_networking_port_v2.server_port.id
}
