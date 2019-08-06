// EC2 instance configurations
variable "node_instance_type" {
  description = "Instance type of the node instance"
  default     = "t3.small"
}

variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default = "keys/harmony-foundation.pub"
}

variable "private_key_path" {
  description = "Enter the path to the SSH Private Key to add to AWS."
  default = "keys/harmony-foundation"
}

variable "node_volume_size" {
  description = "Root Volume size of the node instance"
  default     = 30
}

variable "aws_region" {
  description = "Region user wants to run node instance in"
  default = "us-west-1"
}

