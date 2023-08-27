# Terraform authentication for Azure

Terraform needs to be authenticated in order to interact with Azure resources.

## Authentication methods

Microsoft Azure offers a few authentication methods that allow Terraform to deploy resources, and one of them is an SP account.

The reason an SP account is better than other methods is that we don’t need to log in to Azure before running Terraform.

With the other methods (Azure CLI, or Cloud Shell), we need to login to Azure using az login or Cloud Shell.

## Creating a Service Principal using the Azure CLI

Firstly, login to the Azure CLI using:

```bash
$ az login
```

Once logged in - it's possible to list the Subscriptions associated with the account via:

```bash
$ az account list
```

The output (similar to below) will display one or more Subscriptions - with the id field being the subscription_id field referenced above.

```json
[
  {
    "cloudName": "AzureCloud",
    "id": "00000000-0000-0000-0000-000000000000",
    "isDefault": true,
    "name": "PAYG Subscription",
    "state": "Enabled",
    "tenantId": "00000000-0000-0000-0000-000000000000",
    "user": {
      "name": "user@example.com",
      "type": "user"
    }
  }
]
```

Should you have more than one Subscription, you can specify the Subscription to use via the following command:

```bash
$ az account set --subscription="00000000-0000-0000-0000-000000000000"
```

We can now create the Service Principal which will have permissions to manage resources in the specified Subscription using the following command:

```bash
$ az ad sp create-for-rbac --name="service_terraform" --role="Owner" --scopes="/subscriptions/00000000-0000-0000-0000-000000000000"
```

> The `Owner` role is necessary in order terraform will be able to assign roles on resources it will create.

This command will output 5 values:

```json
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "service_terraform",
  "name": "http://azure-cli-2017-06-05-10-41-15",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

Finally, it's possible to test these values work as expected by first logging in:

```bash
$ az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID
```

Once logged in as the Service Principal - we should be able to list the VM sizes by specifying an Azure region, for example here we use the West US region:

```bash
$ az vm list-sizes --location francecentral
```

Finally, since we're logged into the Azure CLI as a Service Principal we recommend logging out of the Azure CLI (but you can instead log in using your user account):

```bash
$ az logout
```

## Configuring the Service Principal in Terraform

As we've obtained the credentials for this Service Principal - it's possible to configure them in a few different ways but it is important to avoid storing them in source code.
We prefer storing the credentials as Environment Variables, for example:

```bash
$ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
$ export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

These values map to the Terraform variables like so:

- appId is the client_id defined above.
- password is the client_secret defined above.
- tenant is the tenant_id defined above.

After that, to authenticate with the Terraform Service Principal:

```bash
$ az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
```

> You can create your own `env.sh` script at the root of the project. Take example upon the model [env.sh.example](../env.sh.example).

## Add Azure AD permissions

Terraform needs to create Azure resources and AD applications or Service Principals, so it needs a high level of permissions.
You can give the `Owner` role on the subscription to the Terraform Service Principal `service_terraform`.
For managing Azure AD resources, the SP also needs some API access.

Find all details in [this very good post](https://simonemms.com/blog/2021/01/10/setting-terraform-service-principal-to-work-with-azure-active-directory/).

## Check Terraform works

You can create a `provider.tf` file:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "= 2.45.1"
    }
    azuread = {
      source  = "azuread"
      version = "= 1.3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

And try some Terraform commands:

```bash
$ terraform init
$ terraform plan
```

You will be sure of the correct functioning when you will create resources of different types with the providers `azurerm` and `azuread`.
