# Azure Managed Redis Deployment Examples

Welcome to the **Azure Managed Redis Deployment Examples** repository! 🚀

This repository provides Infrastructure as Code (IaC) examples for deploying **Azure Managed Redis (AMR)** using different IaC tools. Whether you're using **Terraform**, **Bicep**, or **Pulumi**, this repository will help you automate and manage your Redis instances efficiently.

## 📌 Why Use This Repository?
- **Automate Deployments**: Deploy Azure Managed Redis quickly and consistently.
- **Learn IaC Best Practices**: Use Terraform, Bicep, or Pulumi to provision Redis with security and scalability in mind.
- **Reduce Manual Errors**: Ensure infrastructure consistency across environments.

## 🚀 Deployment Examples
This repository includes IaC examples for deploying Azure Managed Redis using:

### 🔹 Terraform
- Define Redis instances using Terraform HCL.
- Automate provisioning and configuration.
- Example files: `terraform/main.tf`, `terraform/outputs.tf`, `terraform/providers.tf`, `terraform/terraform.tfvars`, `terraform/variables.tf`

### 🔹 Bicep
- Use Azure’s native infrastructure-as-code language.
- Simplify ARM template deployment with cleaner syntax.
- Example file: `bicep/amr/main.bicep`

### 🔹 Pulumi
- Write IaC using TypeScript, Python, or Go.
- Manage Azure resources programmatically.
- Example files: `pulumi/Pulumi.yaml`

## 🛠 Prerequisites
Before using these examples, ensure you have:
- An **Azure subscription**
- The **Azure CLI** installed ([Install Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
- The relevant IaC tools installed:
    - [Terraform](https://developer.hashicorp.com/terraform/downloads)
    - [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
    - [Pulumi](https://www.pulumi.com/docs/get-started/)

## 📖 Usage Instructions
### 1️⃣ Clone the Repository
```sh
git clone https://github.com/robertopc1/amr-deployment-examples.git
cd amr-deployment-examples
```

### 2️⃣ Authenticate to Azure
```sh
az login
az account set --subscription "<your-subscription-id>"
```

### 3️⃣ Deploy Using Your Preferred IaC Tool
#### Terraform

Set variable values in `terraform/terraform.tfvars` (subscription id etc.)

```bash
cd terraform
terraform init
terraform plan -out main.tfplan
terraform apply "main.tfplan"
```
#### Bicep
```sh
cd bicep
az deployment sub create --location <azure-location> --template-file main.bicep --parameters main.bicepparam
```
#### Pulumi
```sh
cd pulumi
pulumi up
```

## 🤝 Contributing
Contributions are welcome! Feel free to submit a **pull request** to add improvements or new IaC examples.

## 📬 Contact
For questions or feedback, reach out via [LinkedIn](https://www.linkedin.com/in/robertopc/).

Happy coding! 🎉
