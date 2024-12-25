# Training AKS Lab2

## Prerequisites

1- For the lab n°1, we either 15 subscriptions or one subscriptions with 15 users with contributor roles. They will create a RG, deploy a cluster in it. Then we can delete/empty the subscription

2- For the lab n°2, we need one subscription where users don't need access to. But this subscription must have a pre-existing mutualiazed AKS cluster and an attached ACR. They are gonna to use on mutualized SPN to deploy inside the ACR and the cluster. Users **must** have Docker for windows (or Linux) on their computer

## How to set up the lab environment

Create a subscription and run the [deploy.sh script](./infra/deploy.sh) to provision an ACR, a cluster and kubeconfig
