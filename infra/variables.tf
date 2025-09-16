variable "project_name" {
  type        = string
  description = "Project/app name used for resource naming"
  default     = "my-backend"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "southeastasia"
}

/* docker_image variable removed; image now built from ACR login_server and image_tag */

variable "acr_name" {
  type        = string
  description = "Name for Azure Container Registry (lowercase alphanumeric, 5-50 chars)"
}

variable "acr_resource_group_name" {
  type        = string
  description = "Resource group name where the existing ACR resides"
}

variable "image_tag" {
  type        = string
  description = "Image tag to deploy (e.g., latest or v123)"
  default     = "latest"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "dns_label" {
  type        = string
  description = "Public DNS label for the container instance"
  default     = null
}


