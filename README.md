# Azure Resource Deployment using Terraform

This repository contains a Terraform script (`main.tf` and other .tf files) that allows you to deploy resources into your Azure subscription.

## Prerequisites

1. An active Azure subscription.
2. Terraform installed on your local machine.
3. Azure CLI installed on your local machine.

## Instructions

Follow the steps below to deploy resources into your Azure subscription:

1. **Clone the repository**

   Clone this repository to your local machine.

   ```bash
   git clone <repository-url>


## Login to Azure Open a terminal and login to your Azure account using the Azure CLI.
az login

## Follow the prompts in your browser to complete the authentication process.

## Initialize Terraform Navigate to the directory containing the main.tf file and initialize Terraform.
cd <directory-containing-main.tf>
terraform init

## Plan the deployment Run the following command to have Terraform create an execution plan.

terraform plan
## Review the execution plan to understand what resources Terraform will create.
## Apply the deployment Run the following command to apply the desired state defined in main.tf.

terraform apply

## Confirm the apply with a yes when prompted.
## Please note that this will create resources in your Azure subscription and may incur costs. Always review and understand the resources being created before applying the changes.



This README provides a step-by-step guide on how to use the `main.tf` file to deploy resources into an Azure subscription. Please replace `<repository-url>` and `<directory-containing-main.tf>` with the actual URL of your repository and the directory path respectively. Remember to always review the Terraform scripts before running them to understand what resources will be created and to avoid unexpected costs.