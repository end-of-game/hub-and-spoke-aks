
# Bookinfo Sample Microservices(Istio) and terraform hub spoke deployment

This project contains sources to build an hub and spoke infrastructure on Azure with multiple AKS environments.

## Architecture overview

## Requirements

### Tools

These tools must be present in your environment to execute the different stacks of the project:

- [Git](https://git-scm.com/downloads)
- [Python 3.7](https://www.python.org/downloads/release/python-370/)
- [Azure CLI 2.18.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform 0.14.5](https://www.terraform.io/downloads.html)
- [kubectl 1.20.1](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm 3.2.1](https://helm.sh/docs/intro/install/)

> You can build a Docker base image including all these requirements in order to guarantee that all team members and your CI tool use exactly the same environment to work with the project.

## Deployment

In this example project each stack get its own dedicated Resource Group.

>Depends on your way of working, you may prefer having the backend Account Storage and Key Vault in a same `Common` resource group, or in the `hub` resource group.
Maybe you haven't enough permissions to create Resource Group in your subscription and someone else from IT team will provide them to you. In these different use cases you will have to adapt the code a little bit to feet your needs.

### Service principal for Terraform

[Setup Service Principal for Terraform](terraformIAC/docs/tf_azure_authent.md)

### Backend

Terraform needs a shared storage to store state files.
In Azure, stores the state as a Blob with the given Key within the Blob Container within the Blob Storage Account. This backend also supports state locking and consistency checking via native capabilities of Azure Blob Storage.

[Create the terraform backend if it doesn't already exists](terraformIAC/docs/tf_backend.md)

### Key vault

Infrastructure stacks often need a secret manager and this corresponds to good practices tu use one. So we will provision an Azure Key Vault before building the hub and spoke infrastructure.

This stack create the Key Vault itself but will also be responsible for maintaining permission delegations to users, groups and applications of the company to consume or manage secrets, keys and certificates.

[Deploy the Key Vault if it doesn't already exists](terraformIAC/terraform/vault/README.md)

### Infrastructure

The infrastructure is divided in two different terraform stacks containing resources which will have different lifecycle:

- `aks`
  - implements an AKS environment
  - use terraform workspace to manage multiple environments with their specificities
- `hub`
  - implements the hub containing cross environment components like:
    - connectivity with Internet or DC
    - eventually a Bastion
    - DNS resources

#### Create a spoke AKS environment

[Follow these instruction to create an AKS environment](terraformIAC/terraform/aks/README.md)

#### Create the hub

[Follow these instruction to create the hub](terraformIAC/terraform/hub/README.md)


## Conclusion

You have built a first version of an hub and spoke infrastructure for your AKS environements.
Obviously there are still things to add and maybe some things need to be adapted to your specific context, but this is a first basis for work.
