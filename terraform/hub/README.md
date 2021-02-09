# Hub

This stack deploy the common infrastructure, mainly the exposition of service to Internet.

## Requirement

### Check variables

Check the variables of the stack in the file [variables.tf](./variables.tf).

#### Domain

Name of the domain to use:

```hcl
variable "domain" {
  type    = string
  default = "linkbynet.com"
}
```

#### Application DNS

The list of DNS that point to App gateway and need to be redirected to AKS environments:

```hcl
variable "exposed_dns" {
  type = map
  default = {
    "app-dev" = {
      "dns"       = "dev.linkbynet.com"
      "env"       = "dev"
      "protocol" = "Http"
    }
  }
}
```

#### Vnet peering

Adapt the list of vnets you want to peer with the hub:

```hcl
# The name corresponds to both vnet name and resource group name
variable "vnet_spoke_to_peer" {
  type = list
  default = [
    "hub-and-spoke-aks-dev"
  ]
}
```

> **Note**: All vnets in the list must exist or you may have errors when executing the stack.

## Provision or update infrastructure

Apply differences with the live infrastructure:

```bash
$ terraform apply
```

## Check

Check the backend health of the Application Gateway.

![backend](../../docs/img/appgw_backend.png)

> As long as the backend is not indicated as healthy the Application Gateway will never forward requests and you will get an HTTP 502 error (Bad Gateway).
