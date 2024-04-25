# variable "github_personal_access_token" {
#   description = "GitHub Personal Access Token used for authentication"
# }

variable "tenant_id" {
  description = "Azure Tenant ID"
}

# variable "object_id" {
#   description = "Object ID of the Azure AD application or service principal"
# }

variable "vmname" {
    description = "It is the name for the virtual machines"
    type = string
    default = "vm-infra-kochamshop"
}