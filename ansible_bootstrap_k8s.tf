resource "null_resource" "ansible_hosts_cluster_master" {
  count            = length(var.vmw.kubernetes.clusters)
  provisioner "local-exec" {
    command = "echo '---' | tee hosts_cluster_${count.index} ; echo 'all:' | tee -a hosts_cluster_${count.index} ; echo '  children:' | tee -a hosts_cluster_${count.index}; echo '    master:' | tee -a hosts_cluster_${count.index}; echo '      hosts:' | tee -a hosts_cluster_${count.index} ; echo '        ${vsphere_virtual_machine.master[count.index].default_ip_address}:' | tee -a hosts_cluster_${count.index}"
  }
}

resource "null_resource" "ansible_hosts_cluster_static1" {
  depends_on = [null_resource.ansible_hosts_cluster_master]
  count            = length(var.vmw.kubernetes.clusters)
  provisioner "local-exec" {
    command = "echo '    workers:' | tee -a hosts_cluster_${count.index} ; echo '      hosts:' | tee -a hosts_cluster_${count.index}"
  }
}

resource "null_resource" "ansible_hosts_cluster_workers" {
  depends_on = [null_resource.ansible_hosts_cluster_static1]
  count            = length(var.vmw.kubernetes.clusters) * var.vmw.kubernetes.workers.count
  provisioner "local-exec" {
    command = "echo '        ${vsphere_virtual_machine.worker[count.index].default_ip_address}:' | tee -a hosts_cluster_${floor(count.index / var.vmw.kubernetes.workers.count)}"
  }
}

resource "null_resource" "ansible_hosts_cluster_static2" {
  depends_on = [null_resource.ansible_hosts_cluster_workers]
  count            = length(var.vmw.kubernetes.clusters)
  provisioner "local-exec" {
    command = "echo '  vars:' | tee -a hosts_cluster_${count.index} ; echo '    ansible_user: ${var.vmw.kubernetes.clusters[count.index].username}' | tee -a hosts_cluster_${count.index}"
  }
}


resource "null_resource" "ansible_bootstrap" {
  depends_on = [null_resource.ansible_hosts_cluster_static2, vsphere_virtual_machine.jump]
  count = length(var.vmw.kubernetes.clusters)
  connection {
    host = vsphere_virtual_machine.jump.default_ip_address
    type = "ssh"
    agent = false
    user = var.jump.username
    private_key = file(var.jump.private_key_path)
  }

  //  provisioner "file" {
  //    source      = var.jump.private_key_path
  //    destination = "~/.ssh/${basename(var.jump.private_key_path)}"
  //  }

  provisioner "remote-exec" {
    inline = [
      "git clone ${var.ansible.k8sInstallUrl} --branch ${var.ansible.k8sInstallTag} ansible_cluster_${count.index}",
      "echo '[defaults]' | tee ansible_cluster_${count.index}/ansible.cfg",
      "echo 'private_key_file = /home/${var.jump.username}/.ssh/${basename(var.jump.private_key_path)}' | tee -a ansible_cluster_${count.index}/ansible.cfg",
      "echo 'host_key_checking = False' | tee -a ansible_cluster_${count.index}/ansible.cfg",
      "echo 'host_key_auto_add = True' | tee -a ansible_cluster_${count.index}/ansible.cfg"
    ]
  }

  provisioner "file" {
    source = "hosts_cluster_${count.index}"
    destination = "ansible_cluster_${count.index}/hosts_cluster_${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "cd ansible_cluster_${count.index}; ansible-playbook -i hosts_cluster_${count.index} main.yml --extra-vars '{\"kubernetes\": ${jsonencode(var.vmw.kubernetes.clusters[count.index])}}'"
    ]
  }
}

//}
//
//resource "null_resource" "ansible_bootstrap" {
//  depends_on = [null_resource.ansible_keys]
//  count = length(var.vmw.kubernetes.clusters)
//  connection {
//    host = vsphere_virtual_machine.jump.default_ip_address
//    type = "ssh"
//    agent = false
//    user = var.jump.username
//    private_key = file(var.jump.private_key_path)
//  }
//
//  provisioner "file" {
//    source = "hosts_cluster_${count.index}"
//    destination = "${basename(var.ansible.k8sInstallUrl)}/hosts_cluster_${count.index}"
//  }
//
//  provisioner "remote-exec" {
//    inline = [
//      "cd ${basename(var.ansible.k8sInstallUrl)}; ansible-playbook -i hosts_cluster_${count.index} main.yml --extra-vars '{\"kubernetes\": ${jsonencode(var.vmw.kubernetes.clusters[count.index])}}'"
//    ]
//  }
//}