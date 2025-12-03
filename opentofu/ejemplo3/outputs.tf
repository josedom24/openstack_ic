###############################################################
# Outputs del Ejemplo 3 (versión correcta y estable)
###############################################################

# IP flotante asignada a la máquina 1
output "vm1_floating_ip" {
  description = "IP flotante asignada a la máquina 1"
  value       = openstack_networking_floatingip_v2.fip_vm1.address
}

# IP interna de VM1 (la forma más segura)
output "vm1_fixed_ip" {
  description = "IP interna de la máquina 1"
  value       = openstack_compute_instance_v2.vm1.network[0].fixed_ip_v4
}

# IP interna de VM2
output "vm2_fixed_ip" {
  description = "IP interna de la máquina 2"
  value       = openstack_compute_instance_v2.vm2.network[0].fixed_ip_v4
}
