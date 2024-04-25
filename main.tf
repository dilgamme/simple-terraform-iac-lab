# Define provider and required variables
provider "azurerm" {
  subscription_id = "your Azure subscription id"
  features {
        resource_group {
        prevent_deletion_if_contains_resources = false
     }
}
}

provider "azurerm" {
    alias = "mgmt"
    subscription_id ="your Azure subscription id"
    features {}

}

resource "random_string" "random_suffix" {
  length  = 3
  special = false
  upper = false
  lower = true
}

# Define resource group
resource "azurerm_resource_group" "rg_kochamshop" {
  name     = "rg-kochamshop"
  location = "West Europe"
}

# Define virtual network
resource "azurerm_virtual_network" "kochamshop_vnet" {
  name                = "kocham-shop-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_kochamshop.location
  resource_group_name = azurerm_resource_group.rg_kochamshop.name
}


# Define subnets
resource "azurerm_subnet" "snet_inra" {
  name                 = "snet-infra"
  resource_group_name  = azurerm_resource_group.rg_kochamshop.name
  virtual_network_name = azurerm_virtual_network.kochamshop_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "snet_app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.rg_kochamshop.name
  virtual_network_name = azurerm_virtual_network.kochamshop_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "snet_data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.rg_kochamshop.name
  virtual_network_name = azurerm_virtual_network.kochamshop_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Define Azure Static Web Site
resource "azurerm_static_web_app" "kochamshop_static" {
  name               = "kochamshop-main"
  location           = azurerm_resource_group.rg_kochamshop.location
  resource_group_name = azurerm_resource_group.rg_kochamshop.name
  sku_tier            = "Standard"
  sku_size            = "Standard"


#     source {
#     type                 = "GitHub"
#     repository_url       = "https://github.com/dilgamme/kochamshop.git"
#     branch               = "master"
#     repository_token     = "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" // "${var.github_token}"
# }

}


# Define Azure App Service
resource "azurerm_linux_web_app" "kochamshop_app" {
  name                = "kochamshop-app"
  location            = azurerm_resource_group.rg_kochamshop.location
  resource_group_name = azurerm_resource_group.rg_kochamshop.name
  service_plan_id     = azurerm_service_plan.kochamshop_app_plan.id

  site_config {}

}

resource "azurerm_app_service_source_control" "web-tier" {
  app_id   = azurerm_linux_web_app.kochamshop_app.id
  repo_url = "https://github.com/dilgamme/kochamshop.git"
  branch   = "master"
}

# Define App Service Plan
resource "azurerm_service_plan" "kochamshop_app_plan" {
  name                = "kochamshop_app_plan"
  location            = azurerm_resource_group.rg_kochamshop.location
  resource_group_name = azurerm_resource_group.rg_kochamshop.name
  os_type             = "Linux"
  sku_name            = "P1v2"
}




# Define Azure SQL Server
resource "azurerm_mssql_server" "sqlserver-kochamshop" {
  name                         = "sqlserver-kochamshop"
resource_group_name          = azurerm_resource_group.rg_kochamshop.name
  location                     = "eastus"
  version                      = "12.0"
  minimum_tls_version          = "1.2"

  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"

  tags = {
    environment = "production"
  }
}

# Define Azure SQL Database
resource "azurerm_mssql_database" "master_db_kochamshop" {
  name           = "master_db_kochamshop"
  server_id      = azurerm_mssql_server.sqlserver-kochamshop.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  //license_type   = "LicenseIncluded"
  //max_size_gb    = 4
  read_scale     = true
  sku_name       = "P1"
  zone_redundant = false
  enclave_type   = "VBS"

  tags = {
    foo = "bar"
  }

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

# Define Azure Storage Account
resource "azurerm_storage_account" "strgacc_kochamshop" {
  name                     = "stracckmshop${random_string.random_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg_kochamshop.name
  location                 = azurerm_resource_group.rg_kochamshop.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


# Define Virtual Machine
resource "azurerm_virtual_machine" "vm_infra_kochamshop" {
  name                  = var.vmname
  location              = azurerm_resource_group.rg_kochamshop.location
  resource_group_name   = azurerm_resource_group.rg_kochamshop.name
  network_interface_ids = [azurerm_network_interface.vm_infra_kochamshop_nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "vm-infra-kochamshop-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Define Network Interface for Virtual Machine
resource "azurerm_network_interface" "vm_infra_kochamshop_nic" {
  name                      = "vm-infra-kochamshop-nic"
  location                  = azurerm_resource_group.rg_kochamshop.location
  resource_group_name       = azurerm_resource_group.rg_kochamshop.name
  enable_ip_forwarding      = false
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet_data.id
    private_ip_address_allocation = "Dynamic"
  }
}

###Infra VM
variable "windows_vm_count" {
  description = "The number of Windows virtual machines to deploy."
  default     = 4
}

# Create network interfaces for Windows VMs
resource "azurerm_network_interface" "windows_vm_nic" {
  count               = var.windows_vm_count
  name                = "windows-vm-nic-${count.index + 1}"  # Change this to your preferred naming convention
  location                  = azurerm_resource_group.rg_kochamshop.location
  resource_group_name       = azurerm_resource_group.rg_kochamshop.name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.snet_inra.id
  }
}

resource "azurerm_windows_virtual_machine" "windows_vm" {
  count                = var.windows_vm_count
  name                 = "infraVM${count.index + 1}"  # Change this to your preferred naming convention
  location                  = azurerm_resource_group.rg_kochamshop.location
  resource_group_name       = azurerm_resource_group.rg_kochamshop.name
  size                 = "Standard_DS1_v2"  # Change this to your preferred VM size
  admin_username       = "adminuser"  # Change this to your preferred admin username
  admin_password       = "Password1234!"  # Change this to your preferred admin password (make sure it meets Azure's complexity requirements)
  network_interface_ids = [azurerm_network_interface.windows_vm_nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}