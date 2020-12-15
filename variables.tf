variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "pub_key" {
  type = string
  default = ""
  description = "public key generated from the *.pem"
}
