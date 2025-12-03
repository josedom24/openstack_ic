output "instance_name" {
  description = "Nombre de la instancia creada"
  value       = openstack_compute_instance_v2.my_server.name
}

output "fixed_ip_address" {
  description = "IP fija interna asignada al puerto"
  value       = openstack_networking_port_v2.server_port.all_fixed_ips[0]
}

output "floating_ip_address" {
  description = "IP flotante asignada a la instancia"
  value       = openstack_networking_floatingip_v2.floating_ip.address
}
