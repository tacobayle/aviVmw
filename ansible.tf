resource "null_resource" "foo7" {
  depends_on = [vsphere_virtual_machine.jump, vsphere_virtual_machine.master, vsphere_virtual_machine.worker]
  connection {
    host = vsphere_virtual_machine.jump.default_ip_address
    type = "ssh"
    agent = false
    user = var.jump.username
    private_key = file(var.jump.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/${basename(var.jump.private_key_path)}",
      "cd ~/ansible ; git clone ${var.ansible["k8sInstallUrl"]} --branch ${var.ansible["k8sInstallTag"]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml ansibleK8sInstall/main.yml --extra-vars '{\"kubernetes\": ${jsonencode(var.kubernetes)}}'",
      "cd ~/ansible ; git clone ${var.ansible.opencartInstallUrl} --branch ${var.ansible.opencartInstallTag} ; cd ${split("/", var.ansible.opencartInstallUrl)[4]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml local.yml --extra-vars '{\"mysql_db_hostname\": ${var.mysql.ipsData[0]}, \"domainName\": ${jsonencode(var.vmw.domains[0].name)}}'",
      "cd ~/ansible ; git clone ${var.ansible.aviConfigureUrl} --branch ${var.ansible.aviConfigureTag} ; cd ${split("/", var.ansible.aviConfigureUrl)[4]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml local.yml --extra-vars '{\"seLsc\": ${jsonencode(vsphere_virtual_machine.se.*.default_ip_address)}, \"lsc\": ${jsonencode(var.lsc)}, \"vmw\": ${jsonencode(var.vmw)}, \"avi_vsphere_password\": ${jsonencode(var.avi_vsphere_password)}, \"avi_vsphere_user\": ${jsonencode(var.avi_vsphere_user)}, \"avi_username\": ${jsonencode(var.avi_username)}, \"avi_password\": ${jsonencode(var.avi_password)}, \"avi_version\": ${split("-", var.controller.version)[0]}, \"controllerPrivateIps\": ${jsonencode(vsphere_virtual_machine.controller.*.default_ip_address)}, \"controller\": ${jsonencode(var.controller)}, \"avi_servers_vmw\": ${jsonencode(var.backend_vmw.ipsData)}, \"avi_servers_lsc\": ${jsonencode(var.backend_lsc.ipsData)}, \"avi_servers_opencart_vmw\": ${jsonencode(var.opencart.ipsData)}}'",
    ]
  }
}

//"cd ~/ansible ; git clone ${var.ansible["k8sInstallUrl"]} --branch ${var.ansible["k8sInstallTag"]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml ansibleK8sInstall/main.yml --extra-vars '{\"kubernetes\": ${jsonencode(var.kubernetes)}, \"docker_registry_username\": ${var.docker_registry_username}, \"docker_registry_password\": ${var.docker_registry_password}}'",
//"cd ~/ansible ; git clone ${var.ansible.opencartInstallUrl} --branch ${var.ansible.opencartInstallTag} ; cd ${split("/", var.ansible.opencartInstallUrl)[4]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml local.yml --extra-vars '{\"mysql_db_hostname\": ${var.mysql.ipsData[0]}, \"domainName\": ${jsonencode(var.vmw.domains[0].name)}}'",
//"cd ~/ansible ; git clone ${var.ansible.aviConfigureUrl} --branch ${var.ansible.aviConfigureTag} ; cd ${split("/", var.ansible.aviConfigureUrl)[4]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml local.yml --extra-vars '{\"seLsc\": ${jsonencode(vsphere_virtual_machine.se.*.default_ip_address)}, \"lsc\": ${jsonencode(var.lsc)}, \"vmw\": ${jsonencode(var.vmw)}, \"avi_vsphere_password\": ${jsonencode(var.avi_vsphere_password)}, \"avi_vsphere_user\": ${jsonencode(var.avi_vsphere_user)}, \"avi_username\": ${jsonencode(var.avi_username)}, \"avi_password\": ${jsonencode(var.avi_password)}, \"avi_version\": ${split("-", var.controller.version)[0]}, \"controllerPrivateIps\": ${jsonencode(vsphere_virtual_machine.controller.*.default_ip_address)}, \"controller\": ${jsonencode(var.controller)}, \"avi_servers_vmw\": ${jsonencode(var.backend_vmw.ipsData)}, \"avi_servers_lsc\": ${jsonencode(var.backend_lsc.ipsData)}, \"avi_servers_opencart_vmw\": ${jsonencode(var.opencart.ipsData)}}'",