# aviVmw

## Goals
Spin up a full VMware/Avi environment (through Terraform) with V-center integration without NSX-T integration

## Prerequisites:
- TF installed in the orchestrator VM
- VMware credential/details are configured as environment variables:
```
TF_VAR_vsphere_user=******
TF_VAR_vsphere_server=******
TF_VAR_vsphere_password=******
TF_VAR_avi_password=******
TF_VAR_avi_user=admin
```
- VM template configured in V-center:
```
- ubuntu-bionic-18.04-cloudimg-template
- controller-20.1.1-9071-template
```
- SSH key configured

## Environment:

Terraform Plan has/have been tested against:

### terraform

```
Terraform v0.12.29
+ provider.null v2.1.2
+ provider.template v2.1.2
+ provider.vsphere v1.15.0
```

### Avi version
```
Avi 20.1.3 with one controller node
```

### V-center version:
- VMware (V-center 6.7.0, ESXi, 6.7.0, 15160138)

## Input/Parameters:
1. All the paramaters/variables are stored in variables.tf

## Use the terraform plan to:
- Create a new folder within v-center
- Spin up n Avi Controller
- Spin up n backend VM(s) - count based on the length of var.backend.ipsData - with two interfaces: dhcp for mgmt, static for data traffic
- Spin up n web opencart VM(s) - count based on the length of var.opencart.ipsData - with two interfaces: dhcp for mgmt, static for data traffic
- Spin up n mysql server - count based on the length of var.mysql.ipsData - with two interfaces: dhcp for mgmt, static for web traffic
- Spin up n client server(s) - count based on the length of var.client.count - while true ; do ab -n 1000 -c 1000 https://100.64.133.51/ ; done - with two interfaces: dhcp for mgmt, dhcp for data traffic
- Spin up a jump server with ansible and the avisdk installed - userdata to install packages
- Create a yaml variable file - in the jump server
- Call ansible to run the opencart config (git clone)
- Call ansible to do the Avi configuration (git clone)

## Run the terraform:
```
cd ~ ; git clone https://github.com/tacobayle/aviVmw ; cd aviVmw ; terraform init ; terraform apply -auto-approve
# the terraform will output the command to destroy the environment.
```
