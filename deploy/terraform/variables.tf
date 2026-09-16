variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west1"
}

variable "vpc_id" {
  description = "VPC ID for private network"
  type        = string
  default     = "projects/cova-task-manager/global/networks/default"
}

variable "db_password" {
  description = "MySQL database password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true
}