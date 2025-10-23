variable "name" {
  description = "The name of the Cosmos DB database."
  type        = string
}

variable "mongo_version" {
  description = "The version of the MongoDB database."
  type        = string
  default     = "5.0"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "vnet_id" {
  description = "Virtual Network ID for Private DNS zone link"
  type        = string
  nullable = true 
  default = null
  validation {
    condition = var.network_mode != "private" || var.vnet_id != null
    error_message = "vnet_id is required when network_mode is \"private\"."  
  }
}

variable "location" {
  description = "The location of the resource group."
  type        = string
}

variable "administrator_username" {
  description = "The username of the administrator." 
  type        = string 
} 

variable "administrator_password" {
  description = "The password of the administrator."
  type        = string
  nullable = true
  default = null
  sensitive   = true
}

variable "network_mode" {
  description = "The network mode of the cluster."
  type        = string
  default     = "public" # private or public
  validation {
    condition     = contains(["public", "private"], var.network_mode)
    error_message = "network_mode must be either \"public\" or \"private\"."
  }
}

variable "subnet_id" {
  description = "The ID of the subnet for private endpoint."
  type        = string
  nullable = true
  default = null
  validation {
    condition = var.network_mode != "private" || var.subnet_id != null
    error_message = "subnet_id is required when network_mode is \"private\"."
  }
}

variable "tags" {
  description = "The tags of the Cosmos DB database."
  type        = map(string)
  default     = {}
}

variable "cluster_tier" {
  description = "The tier of the cluster."
  type        = object({
    compute_tier = string
    storage_size_in_gb = number
    shard_count = number
    enable_high_availability = bool # Auto recover if shard is down (same region)
  })
  default = {
    compute_tier = "M10"
    storage_size_in_gb = 32
    shard_count = 1
    enable_high_availability = true
  }
}
