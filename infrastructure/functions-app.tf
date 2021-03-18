terraform {
  backend "azurerm" {
    resource_group_name  = "demo-infrastructure"
    storage_account_name = "demoinfrastructure"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "azure-functions-seandemo"
  location = "East US 2"
}

resource "azurerm_storage_account" "example" {
  name                     = "functionsappseandemo"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "example" {
  name                = "azure-functions-seandemo-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "example" {
  name                       = "azure-functions-seandemo"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  source_control {
    repo_url           = "https://github.com/SeanKilleen/terraform-azure-functions"
    branch             = "main"
    manual_integration = false
    rollback_enabled   = false
  }
}
