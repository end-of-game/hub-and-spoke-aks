# Hub and spoke AKS

This project contains sources to build an hub and spoke infrastructure on Azure with multiple AKS environments.

## Architecture overview

The archirecture is built on an [hub and spoke network topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli).

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

### Service principal for Terraform

[Setup Service Principal for Terraform](docs/tf_azure_authent.md)

### Backend

Terraform needs a shared storage to store state files.
In Azure, stores the state as a Blob with the given Key within the Blob Container within the Blob Storage Account. This backend also supports state locking and consistency checking via native capabilities of Azure Blob Storage.

[Create the terraform backend if it doesn't already exists](docs/tf_backend.md)

## Deployment

### Infrastructure

The infrastructure is divided in two different terraform stacks containing resources which will have different lifecycle:

- [`aks`](terraform/aks/README.md):
  - implements an AKS environment
  - use terraform workspace to manage multiple environments with their specificities
- [`hub`](terraform/hub/README.md): implements the hub containing cross environment components