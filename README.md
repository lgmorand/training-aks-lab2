# Training AKS Lab 2 – Azure Kubernetes Service Workshop

This repository contains a hands-on workshop (~3 hours) designed to teach developers how to build, deploy and operate containerized applications on **Azure Kubernetes Service (AKS)**. The training is structured for groups of up to 15 participants sharing a single mutualized AKS cluster.

## Workshop content

The workshop is organised into **7 modules**:

| # | Module | Description |
|---|--------|-------------|
| 01 | **Introduction & Prerequisites** | Tool installation (Azure CLI, kubectl, Docker), AKS cluster access setup and Kubernetes basics |
| 02 | **Build** | Create a Dockerfile, build a container image locally, set up a CI/CD pipeline and push images to Azure Container Registry (ACR) |
| 03 | **Deployment** | Deploy an application with Kubernetes manifests, scale pods and collect logs |
| 04 | **Security** | DevSecOps practices – scan Dockerfiles (hadolint), validate manifests (kubeval, checkov), manage secrets with Azure Key Vault and workload identity |
| 05 | **Storage** | Persistent volumes, StorageClasses, Azure Managed Disks and Azure Files |
| 06 | **Autoscaling** | Horizontal Pod Autoscaler (HPA), KEDA (event-driven autoscaling) and load testing |
| 07 | **Clean Up** | Resource cleanup procedures |

## Technologies & services used

- **Azure** – AKS, ACR, Key Vault, Managed Identity, OIDC / Workload Identity, Azure Files & Managed Disks
- **Kubernetes** – kubectl, Deployments, Services, Secrets, HPA, KEDA
- **Containers** – Docker
- **DevSecOps** – hadolint, kubeval, checkov

## Sample applications

Two sample applications are provided in the [`sample-app/`](./sample-app) directory:

- **hello-world** – A simple containerized application used throughout the build and deployment exercises.
- **devsecops** – An Azure Voting App (Python frontend + Redis backend) used for the security scanning exercises.

## Prerequisites

1- For the lab n°1, we either 15 subscriptions or one subscriptions with 15 users with contributor roles. They will create a RG, deploy a cluster in it. Then we can delete/empty the subscription

2- For the lab n°2, we need one subscription where users don't need access to. But this subscription must have a pre-existing mutualized AKS cluster and an attached ACR. They are going to use one mutualized SPN to deploy inside the ACR and the cluster. Users **must** have Docker for Windows (or Linux) on their computer

## How to set up the lab environment

Create a subscription and run the [deploy.sh script](./infra/deploy.sh) to provision an ACR, a cluster and kubeconfig
