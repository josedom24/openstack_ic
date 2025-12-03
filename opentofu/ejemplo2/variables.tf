variable "image" {
  type        = string
  description = "Imagen base para crear el volumen raíz"
}

variable "flavor" {
  type        = string
  description = "Flavor de la instancia"
}

variable "network" {
  type        = string
  description = "Nombre o ID de la red interna"
}

variable "key_name" {
  type        = string
  description = "Par de claves SSH"
}

variable "public_network" {
  type        = string
  description = "Red pública para la IP flotante"
}

variable "root_volume_size" {
  type        = number
  description = "Tamaño del volumen raíz (GB)"
}

variable "data_volume_size" {
  type        = number
  description = "Tamaño del volumen adicional (GB)"
}
