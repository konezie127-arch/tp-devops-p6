variable "region" {
  description = "Region AWS (imposee par le projet : eu-north-1)"
  type        = string
  default     = "eu-north-1"
}

variable "name" {
  type    = string
  default = "p6-vm"
}

variable "size" {
  type    = string
  default = "t3.micro"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/p6_key.pub"
}

variable "ssh_user" {
  type    = string
  default = "deploy"
}

variable "open_ports" {
  type    = list(number)
  default = [22, 80, 443]
}

variable "ssh_allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
