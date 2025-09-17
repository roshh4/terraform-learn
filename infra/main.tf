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

resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_user_assigned_identity.aci_identity.principal_id
}

resource "azurerm_container_group" "aci" {
  name                = "${var.project_name}-aci"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = coalesce(var.dns_label, var.project_name)

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.aci_identity.id]
  }

  container {
    name   = var.project_name
    image  = "${data.azurerm_container_registry.acr.login_server}/${var.project_name}:${var.image_tag}"
    cpu    = 0.5
    memory = 0.5

    ports {
      port     = 8080
      protocol = "TCP"
    }

    environment_variables = {}
  }

  image_registry_credential {
    server                     = data.azurerm_container_registry.acr.login_server
    user_assigned_identity_id  = data.azurerm_user_assigned_identity.aci_identity.id
  }

  tags = {
    app = var.project_name
  }
}

output "fqdn" {
  description = "Public FQDN of the container instance"
  value       = azurerm_container_group.aci.fqdn
}


