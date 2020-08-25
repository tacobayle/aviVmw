# aviVmw

## Goals
Spin up a full VMware/Avi environment (through Terraform) with V-center integration without NSX-T integration

## Prerequisites:
1. Make sure terraform in installed in the orchestrator VM
2. Make sure VMware credential/details are configured as environment variable:
```
TF_VAR_vsphere_user=******
TF_VAR_vsphere_server=******
TF_VAR_vsphere_password=******
TF_VAR_avi_password=******
TF_VAR_avi_user=admin
```
3. Make sure you have VM template file in V-center:
- ubuntu-bionic-18.04-cloudimg-template
- controller-20.1.1-9071-template

## Environment:

Terraform Plan has/have been tested against:

### terraform

```
avi@ansible:~$ terraform -v
nic@jump:~/aviVmw$ terraform -v
Terraform v0.12.29
+ provider.null v2.1.2
+ provider.template v2.1.2
+ provider.vsphere v1.15.0
nic@jump:~/aviVmw$
```

### Avi version
```
Avi 20.1.1 with one controller node
```

### V-center version:
- VMware (V-center 6.7.0, ESXi, 6.7.0, 15160138)

## Input/Parameters:
1. All the paramaters/variables are stored in variables.tf

## Use the the terraform script to:
1. Create a new folder
2. Spin up n Avi Controller
3. Spin up n backend VM(s) - (count based on the length of var.backendIpsMgt)
4. Spin up n client server(s) - (count based on the length of var.clientIpsMgt) - while true ; do ab -n 1000 -c 1000 https://100.64.133.51/ ; done
5. Create an ansible hosts file including a group for avi controller(s), a group for backend server(s)
6. Spin up a jump server with ansible intalled - userdata to install package
7. Create an ansible hosts file - in the jump server
8. Create a yaml variable file - in the jump server

## Run the terraform:
```
terraform apply -auto-approve
# the terraform will output the command to destroy the environment.
```

## Improvement:

### future devlopment:
