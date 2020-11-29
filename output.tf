# Outputs for Terraform

output "jump" {
  value = vsphere_virtual_machine.jump.default_ip_address
}

output "controllers" {
  value = vsphere_virtual_machine.controller.*.default_ip_address
}

output "backend" {
  value = var.backendIpsMgt.*
}

output "client" {
  value = var.clientIpsMgt.*
}

output "loadcommand" {
  value = "while true ; do ab -n 50 -c 50 https://100.64.133.53/ ; done"
}

output "destroy" {
  value = "ssh -o StrictHostKeyChecking=no -i ~/.ssh/${basename(var.jump.private_key_path)} -t ubuntu@${vsphere_virtual_machine.jump.default_ip_address} 'git clone ${var.ansible.aviPbAbsentUrl} --branch ${var.ansible.aviPbAbsentTag} ; cd ${split("/", var.ansible.aviPbAbsentUrl)[4]} ; ansible-playbook local.yml --extra-vars @${var.controller.aviCredsJsonFile} --extra-vars @${var.ansible.jsonFile} --extra-vars @${var.ansible.yamlFile}' ; sleep 20 ; terraform destroy -auto-approve"
  description = "command to destroy the infra"
}
