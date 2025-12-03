variable "image" {
  type        = string
  description = "Imagen para la instancia"
}

variable "flavor" {
  type        = string
  description = "Flavor para la instancia"
}

variable "network" {
  type        = string
  description = "Red interna donde conectar la instancia (ID o nombre)"
}

variable "key_name" {
  type        = string
  description = "Par de claves SSH"
}

variable "public_network" {
  type        = string
  description = "Red pública para la IP flotante"
}
