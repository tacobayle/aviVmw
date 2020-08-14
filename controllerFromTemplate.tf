# Ansible host file creation

resource "null_resource" "foo1" {

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > ${var.ansibleHostFile}
---
all:
  children:
    controller:
      hosts:
EOF
EOD
  }
}


data "vsphere_virtual_machine" "controller_template" {
  name          = "controller-${var.controller["version"]}-template"
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
resource "vsphere_virtual_machine" "controller" {
  count            = var.controller["count"]
  name             = "controller-${var.controller["version"]}-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path
  network_interface {
    network_id = data.vsphere_network.networkMgt.id
  }

  num_cpus = var.controller["cpu"]
  memory = var.controller["memory"]
  wait_for_guest_net_timeout = var.controller["wait_for_guest_net_timeout"]

  guest_id = data.vsphere_virtual_machine.controller_template.guest_id
  scsi_type = data.vsphere_virtual_machine.controller_template.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.controller_template.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.controller_template.scsi_controller_scan_count

  disk {
    size             = var.controller["disk"]
    label            = "controller-${var.controller["version"]}-${count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.controller_template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.controller_template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.controller_template.id
  }

}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo2" {
  count = var.controller["count"]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
        ${vsphere_virtual_machine.controller[count.index].default_ip_address}:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo3" {
  depends_on = [null_resource.foo2]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
      vars:
        ansible_user: admin
        ansible_ssh_private_key_file: '~/.ssh/${basename(var.jump["private_key_path"])}'
EOF
EOD
  }
}

# Ansible host file creation (finishing)

resource "null_resource" "foo6" {
  depends_on = [null_resource.foo3]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
  vars:
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF
EOD
  }
}
