variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "pub_key" {
  type = string
  default = ""
  description = "public key generated from the *.pem"
}
