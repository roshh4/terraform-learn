data "azurerm_resource_group" "rg" {
  name = coalesce(var.resource_group_name, "${var.project_name}-rg")
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

data "azurerm_user_assigned_identity" "aci_identity" {
  name                = "${var.project_name}-aci-identity"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Role assignment already exists - no need to manage it

resource "azurerm_container_group" "aci" {
  name                = "${var.project_name}-aci"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = var.project_name
  os_type             = "Linux"

  container {
    name   = var.project_name
    image  = "${data.azurerm_container_registry.acr.login_server}/${var.project_name}:${var.image_tag}"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.aci_identity.id]
  }

  image_registry_credential {
    server   = data.azurerm_container_registry.acr.login_server
    username = data.azurerm_container_registry.acr.admin_username
    password = data.azurerm_container_registry.acr.admin_password
  }
}

output "fqdn" {
  description = "Public FQDN of the container instance"
  value       = azurerm_container_group.aci.fqdn
}