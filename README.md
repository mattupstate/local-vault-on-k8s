# Automating Vault on a Local K8s Cluster

## Context

You're working on a system that is deployed to a Kubernetes cluster and requires Vault as a service to operate.
You want to be able to work on this system locally and for Vault to resemble production to avoid discrepencies with Vault's "dev" server mode.
How can you automate the deployment and configuration of Vault in the local development environment to meet this goal and maintain a reasonable developer experience?

## Solution

Mainstream tools are combined to automate the deployment and configuration of Vault.
Tools are "glued" together using [Task](https://taskfile.dev/).
The approach should be able to be adapted to other combinations of tools without much difficulty.

### Prerequisites

* A local Kubernetes cluster via one of the following (or similar):
    * [Docker Desktop](https://docs.docker.com/desktop/kubernetes/)
    * [Rancher Desktop](https://docs.rancherdesktop.io/ui/preferences/kubernetes)
    * [minikube](https://minikube.sigs.k8s.io/docs/start/)
* The following tools are installed:
    * [Helm](https://helm.sh/docs/intro/install/)
    * [Terraform](https://developer.hashicorp.com/terraform/downloads)
    * [Task](https://taskfile.dev/installation/)

### Tasks

Commands to deploy and configure Vault are performed in a specific sequence.
They are expressed in `Taskfile.yaml` and broken into two logical stages.
Assuming a clean Kubernetes cluster, all stages can be executed by running:

    task vault

The following describes the two logical phases encapsulated by this task:

#### `task vault:deploy`

The `vault:deploy` task deploys Vault via Terraform and Helm from files in the `./01-deploy` directory. 
It includes a customized "post-start" script that initializes and unseals vault automatically.
The script also writes down the root token to a well known place in the Vault container.

> Typically this task does not need to be executed again unless starting from scratch.

#### `task vault:configure`

The `vault:configure` task applies desired configuration against the running Vault service via Terraform.
Before Terraform is run the root token is copied from the Vault container to a local `.auto.tfvars.json` file.
A temporary port-fowarding process is also created to afford the local environment to connect to Vault.

> This task can be run independently after making changes to Terraform files in `./02-configure` to apply the desired state.

## Etc

This solution was extracted from [mattupstate/acme](https://github.com/mattupstate/acme)
