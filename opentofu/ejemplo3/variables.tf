variable "image" {
  type        = string
  description = "Imagen para las instancias"
}

variable "flavor" {
  type        = string
  description = "Flavor de las máquinas"
}

variable "key_name" {
  type        = string
  description = "Par de claves SSH"
}

variable "public_network" {
  type        = string
  description = "Nombre de la red pública"
}
