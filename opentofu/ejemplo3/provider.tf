terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54.0"
    }
  }
}

provider "openstack" {
  # No se configuran credenciales aquí.
  # Se cargarán desde las variables de entorno exportadas por source openrc.sh
}
