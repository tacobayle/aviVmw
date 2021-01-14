resource "vsphere_tag" "ansible_group_backend_vmw" {
  name             = "backend_vmw"
  category_id      = vsphere_tag_category.ansible_group_backend_vmw.id
}

data "template_file" "backend_vmw_userdata" {
  count = length(var.backend_vmw.ipsData)
  template = file("${path.module}/userdata/backend_vmw.userdata")
  vars = {
    username     = var.backend_vmw.username
    pubkey       = file(var.jump["public_key_path"])
    netplanFile  = var.backend_vmw["netplanFile"]
    maskData = var.backend_vmw.maskData
    ipData      = element(var.backend_vmw.ipsData, count.index)
  }
}

data "vsphere_virtual_machine" "backend_vmw" {
  name          = var.backend_vmw["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "backend_vmw" {
  count = length(var.backend_vmw.ipsData)
  name             = "backend_vmw-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path

  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  network_interface {
                      network_id = data.vsphere_network.networkBackendVmw.id
  }

  num_cpus = var.backend_vmw["cpu"]
  memory = var.backend_vmw["memory"]
  wait_for_guest_net_timeout = var.backend_vmw["wait_for_guest_net_timeout"]
  #wait_for_guest_net_routable = var.backend_vmw["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.backend_vmw.guest_id
  scsi_type = data.vsphere_virtual_machine.backend_vmw.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.backend_vmw.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.backend_vmw.scsi_controller_scan_count

  disk {
    size             = var.backend_vmw["disk"]
    label            = "backend_vmw-${count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.backend_vmw.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.backend_vmw.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.backend_vmw.id
  }

  tags = [
        vsphere_tag.ansible_group_backend.id,
  ]

  vapp {
    properties = {
     hostname    = "backend_vmw-${count.index}"
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.backend_vmw_userdata[count.index].rendered)
   }
 }

  connection {
    host        = self.default_ip_address
    type        = "ssh"
    agent       = false
    user        = var.backend_vmw.username
    private_key = file(var.jump["private_key_path"])
    }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }
}
