# Outputs for Terraform

output "jump" {
  value = vsphere_virtual_machine.jump.default_ip_address
}

output "controllers" {
  value = vsphere_virtual_machine.controller.*.default_ip_address
}

output "backend" {
  value = vsphere_virtual_machine.backend.*.guest_ip_addresses
}

output "destroy" {
  value = "ssh -o StrictHostKeyChecking=no -i ~/.ssh/${basename(var.jump["private_key_path"])} -t ubuntu@${vsphere_virtual_machine.jump.default_ip_address} 'ansible-pull --url ${var.ansibleAviPbAbsent} --extra-vars @~/ansible/vars/fromTerraform.yml --extra-vars @~/ansible/vars/creds.json' ; sleep 20 ; terraform destroy -auto-approve"
  description = "command to destroy the infra"
}
