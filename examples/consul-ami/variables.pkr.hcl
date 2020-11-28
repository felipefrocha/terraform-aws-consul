variable "aws_region" {
  description = "Region where to deploy this image"
  type    = string
  default = "us-east-1"
}

variable "consul_version" {
  description = "Consul version used to deploy all suggested archtecture"
  type    = string
  default = "1.9.0"
}

variable "download_url" {
  description = "URL of the full package zip file for consul"
  type    = string
//  default = "${var.CONSUL_DOWNLOAD_URL}"
}