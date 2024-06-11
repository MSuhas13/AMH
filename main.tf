terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {} 
  client_secret    = "B~28Q~eUJA8MkIKZJDaJAMIvYgDH4aX6P7.wGc6."
  client_id        = "0780bbdf-f99a-4738-b6d0-4226f2c122e5"
  tenant_id        = "46c67f70-2696-4620-9bce-b9e6864b268f"
  subscription_id  = "fdeb2770-237a-4225-bf41-039d363b01db"
}
resource "azurerm_resource_group" "rg" {
  name     = "${var.rgname}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.prefix}"
  address_space       = ["${var.vnet_cidr_prefix}"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.subnet}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet1.name}"
  address_prefixes     = ["${var.subnet1_cidr_prefix}"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_storage_account" "stgacnt" {
  name                     = "${var.storageaccount}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"


  network_rules {
   default_action             = "Deny"
   ip_rules                   = ["100.0.0.1"]
   virtual_network_subnet_ids = [azurerm_subnet.subnet1.id]
  }

  tags = {
    environment = "dev"
  }
}

