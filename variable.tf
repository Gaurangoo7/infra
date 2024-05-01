variable "rds_port" {
  type        = number
  default     = "5432"
  description = "Port for postgress "
}

variable "cidr_list" {
  type        = string
  default     = "10.0.1.0/24"
}

variable "cidr_list1" {
  type        = string
  default     = "10.0.2.0/24"
}

variable "ec2_names" {
  type        = list
  default     = ["web","api","rds-db"]
  description = "description"
}

