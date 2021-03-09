variable "auth_token" {
  description = "Your Equinix Metal API key"
}

variable "facilities" {
  default = ["ewr1"]
}

variable "node_plan" {
  default     = "m1.xlarge.x86"
}

variable "loadbalancer_count" {
  default     = "2"
}

variable "webserver_count" {
  default     = "2"
}

variable "gateway_IP" {
  description = "Gateway private IP address"
}

variable "webserver1_private_IP" {
  description = "Webserver 1 private IP address"
}

variable "webserver2_private_IP" {
  description = "Webserver 2 private IP address"
}
