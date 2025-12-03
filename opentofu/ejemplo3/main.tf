###############################################################
# 1. RED Y SUBRED
#    Equivalente a OS::Neutron::Net y OS::Neutron::Subnet
###############################################################

###############################################################
# Resolver red pública por NOMBRE o UUID
###############################################################

data "openstack_networking_network_v2" "public_net" {
  name = var.public_network
}


# Crear red interna llamada "asir-net"
resource "openstack_networking_network_v2" "asir_net" {
  name = "asir-net"
}

# Crear subred 192.168.10.0/24 asociada a esa red
resource "openstack_networking_subnet_v2" "asir_subnet" {
  name       = "asir-subnet"
  network_id = openstack_networking_network_v2.asir_net.id
  cidr       = "192.168.10.0/24"
  ip_version = 4
  gateway_ip = "192.168.10.1"
  enable_dhcp     = true

  dns_nameservers = ["8.8.8.8"]

  # Terraform requiere bloques individuales para los pools
  allocation_pool {
    start = "192.168.10.10"
    end   = "192.168.10.200"
  }
}




###############################################################
# 2. ROUTER + INTERFAZ
#    Equivalente a OS::Neutron::Router y RouterInterface
###############################################################

# Crear router y conectarlo a la red pública (FLAT / External)
resource "openstack_networking_router_v2" "asir_router" {
  name                = "asir-router"
  external_network_id = data.openstack_networking_network_v2.public_net.id
}
# Conectar la subred interna al router
resource "openstack_networking_router_interface_v2" "asir_router_interface" {
  router_id = openstack_networking_router_v2.asir_router.id
  subnet_id = openstack_networking_subnet_v2.asir_subnet.id
}


###############################################################
# 3. SECURITY GROUP SSH
#    Equivalente a OS::Neutron::SecurityGroup
###############################################################

# Crear Security Group que permitirá solo SSH
resource "openstack_networking_secgroup_v2" "ssh_sg" {
  name        = "ssh-sg"
  description = "Permite tráfico SSH"
}

# Regla para permitir SSH desde cualquier origen
resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ssh_sg.id
}


###############################################################
# 4. PUERTOS NEUTRON PARA VM1 Y VM2
#    Equivalente a OS::Neutron::Port
###############################################################

resource "openstack_networking_port_v2" "port_vm1" {
  name       = "port-vm1"
  network_id = openstack_networking_network_v2.asir_net.id

  security_group_ids = [
    openstack_networking_secgroup_v2.ssh_sg.id
  ]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.asir_subnet.id
  }
}

resource "openstack_networking_port_v2" "port_vm2" {
  name       = "port-vm2"
  network_id = openstack_networking_network_v2.asir_net.id

  security_group_ids = [
    openstack_networking_secgroup_v2.ssh_sg.id
  ]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.asir_subnet.id
  }
}


###############################################################
# 5. VM1 (con IP flotante)
#    Equivalente a OS::Nova::Server
###############################################################

resource "openstack_compute_instance_v2" "vm1" {
  name        = "maquina-1"
  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = var.key_name

  network {
    port = openstack_networking_port_v2.port_vm1.id
  }
}


###############################################################
# 6. FLOATING IP PARA VM1
#    Equivalente a OS::Neutron::FloatingIP + Association
###############################################################

# Reservar una IP flotante desde la red pública
resource "openstack_networking_floatingip_v2" "fip_vm1" {
  pool = var.public_network
}

# Asociar la IP flotante al puerto de VM1
resource "openstack_networking_floatingip_associate_v2" "fip_assoc_vm1" {
  floating_ip = openstack_networking_floatingip_v2.fip_vm1.address
  port_id     = openstack_networking_port_v2.port_vm1.id

  # Igual que en Heat usamos depends_on para asegurar el orden:
  depends_on = [
    openstack_networking_router_interface_v2.asir_router_interface
  ]
}


###############################################################
# 7. VM2 (sin IP flotante)
###############################################################

resource "openstack_compute_instance_v2" "vm2" {
  name        = "maquina-2"
  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = var.key_name

  network {
    port = openstack_networking_port_v2.port_vm2.id
  }
}
