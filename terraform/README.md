# Proxmox VM deployment using Terraform

This directory contains Terraform code to deploy VMs to Proxmox 8 that run docker containers on Debian 12.

## Pre-requisites

- Provide variables in `.tfvars` files in the `terraform` directory. See the `terraform/variables.tf` file for a list of variables. Prefix the file extension with `.auto` to have Terraform automatically load the variables.
- Installed Terraform
- Proxmox host with API access

## Usage

```bash
terraform init -upgrade
```
to initialize the Terraform environment.

```bash
terraform plan -out output.tfplan
```
to plan what Terraform will do.

```bash
terraform apply output.tfplan
```
to apply the plan and deploy the VMs.

The plan command can be prefixed with `TF_VAR_` to set variables on the command line. For example:
```bash
TF_VAR_FORCE_UPDATE_PACKAGES=<some string value> terraform plan -out output.tfplan
```
to force update packages on the VMs. Otherwise this is only done monthly.

## License

See the LICENSE file.