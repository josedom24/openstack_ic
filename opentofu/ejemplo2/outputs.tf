output "instance_name" {
  description = "Nombre de la instancia"
  value       = openstack_compute_instance_v2.my_server.name
}

output "floating_ip" {
  description = "IP pública asignada"
  value       = openstack_networking_floatingip_v2.floating_ip.address
}

output "data_volume_id" {
  description = "ID del volumen adicional"
  value       = openstack_blockstorage_volume_v3.data_volume.id
}
