locals {
  appgw_ipconfig                 = "${local.stack_name}-appgw-ipconfig"
  frontend_ip_configuration_name = "${local.stack_name}-appgw-feip"
  frontend_port_name             = "${local.stack_name}-appgw-feport"
  listener_name                  = "${local.stack_name}-appgw-lstn"
}

resource "azurerm_user_assigned_identity" "appgw" {
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  name                = "${local.stack_name}-appgw"
}

# Get wildcard certificate from Vault
# data "azurerm_key_vault_certificate" "wildcard" {
#   name         = var.certificate_wildcard_name_in_vault
#   key_vault_id = data.azurerm_key_vault.vault.ids
# }

# Create public IP for App Gateway
# - #TODO Eventually add a public DNS in order to be independant from the public IP that will change if we recreate it
resource "azurerm_public_ip" "appgw" {
  name                = "${local.stack_name}-appgw"
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.default_tags
}

# Create Application Gateway with WAF
# - Need at least one listner/backend/routing rule to be created
resource "azurerm_application_gateway" "appgw" {
  name                = "${local.stack_name}-appgw"
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  enable_http2        = true

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.1"

    disabled_rule_group {
      rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
      rules           = [931130]
    }
    disabled_rule_group {
      rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
      rules = [
        941320,
        941130,
        941170,
        941100,
        941150,
      941160]
    }
    disabled_rule_group {
      rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
      rules = [
        942130,
        942200,
        942260,
        942430,
        942100,
        942370,
        942340,
        942450,
        942150,
        942410,
        942440,
      942390]
    }
    disabled_rule_group {
      rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
      rules           = [930110]
    }
  }
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw.id]
  }
  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }
  autoscale_configuration {
    min_capacity = 0
    max_capacity = 2
  }
  gateway_ip_configuration {
    name      = local.appgw_ipconfig
    subnet_id = azurerm_subnet.waf.id
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # Ports exposed
  frontend_port {
    name = "${local.frontend_port_name}-Https"
    port = 443
  }
  frontend_port {
    name = "${local.frontend_port_name}-Http"
    port = 80
  }

  # Certificates
  # ssl_certificate {
  #   name                = "wildcard"
  #   key_vault_secret_id = data.azurerm_key_vault_certificate.wildcard.secret_id
  # }

  # -----------------------------------------------
  # Backends
  # One per environment
  backend_address_pool {
    name         = "dev"
    ip_addresses = [var.aks_private_lb_ip.dev]
  }
  backend_address_pool {
    name         = "staging"
    ip_addresses = [var.aks_private_lb_ip.staging]
  }
  backend_address_pool {
    name         = "prod"
    ip_addresses = [var.aks_private_lb_ip.prod]
  }

  # -----------------------------------------------
  # Backend endpoints
  # One per environment
  backend_http_settings {
    name                  = "dev"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "dev"
  }
  backend_http_settings {
    name                  = "staging"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "staging"
  }
  backend_http_settings {
    name                  = "prod"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = "prod"
  }

  # -----------------------------------------------
  # Probe health
  # One per environment
  probe {
    name                                      = "dev"
    host                                      = "dev.${var.domain}"
    interval                                  = 30
    path                                      = "/"
    pick_host_name_from_backend_http_settings = false
    protocol                                  = "Http"
    timeout                                   = 30
    unhealthy_threshold                       = 3
  }
  probe {
    name                                      = "staging"
    host                                      = "staging.${var.domain}"
    interval                                  = 30
    path                                      = "/"
    pick_host_name_from_backend_http_settings = false
    protocol                                  = "Http"
    timeout                                   = 30
    unhealthy_threshold                       = 3
  }
  probe {
    name                                      = "prod"
    host                                      = var.domain
    interval                                  = 30
    path                                      = "/"
    pick_host_name_from_backend_http_settings = false
    protocol                                  = "Http"
    timeout                                   = 30
    unhealthy_threshold                       = 3
  }

  # -----------------------------------------------
  # Listeners
  # One per DNS in exposed_dns variable
  dynamic "http_listener" {
    for_each = var.exposed_dns
    content {
      name                           = "${http_listener.value.protocol}-${http_listener.key}"
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = "${local.frontend_port_name}-${http_listener.value.protocol}"
      protocol                       = http_listener.value.protocol
      host_name                      = http_listener.value.dns
      # Uncomment for Https listeners
      # ssl_certificate_name           = "wildcard"
    }
  }

  # -----------------------------------------------
  # Routes from listener to backend
  # One per DNS in exposed_dns variable
  dynamic "request_routing_rule" {
    for_each = var.exposed_dns
    content {
      name                       = request_routing_rule.key
      rule_type                  = "Basic"
      http_listener_name         = "${request_routing_rule.value.protocol}-${request_routing_rule.key}"
      backend_address_pool_name  = request_routing_rule.value.env
      backend_http_settings_name = request_routing_rule.value.env
    }
  }
}
