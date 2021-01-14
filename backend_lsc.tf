resource "vsphere_tag" "ansible_group_backend" {
  name             = "backend_lsc"
  category_id      = vsphere_tag_category.ansible_group_backend_lsc.id
}

data "template_file" "backend_lsc_userdata" {
  count = length(var.backend_lsc.ipsData)
  template = file("${path.module}/userdata/backend_lsc.userdata")
  vars = {
    username     = var.backend_lsc.username
    pubkey       = file(var.jump["public_key_path"])
    netplanFile  = var.backend_lsc["netplanFile"]
    maskData = var.backend_lsc.maskData
    ipData      = element(var.backend_lsc.ipsData, count.index)
  }
}

data "vsphere_virtual_machine" "backend_lsc" {
  name          = var.backend_lsc["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "backend_lsc" {
  count = length(var.backend_lsc.ipsData)
  name             = "backend_lsc-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path

  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  network_interface {
                      network_id = data.vsphere_network.networkBackendLsc.id
  }

  num_cpus = var.backend_lsc["cpu"]
  memory = var.backend_lsc["memory"]
  wait_for_guest_net_timeout = var.backend_lsc["wait_for_guest_net_timeout"]
  #wait_for_guest_net_routable = var.backend_lsc["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.backend_lsc.guest_id
  scsi_type = data.vsphere_virtual_machine.backend_lsc.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.backend_lsc.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.backend_lsc.scsi_controller_scan_count

  disk {
    size             = var.backend_lsc["disk"]
    label            = "backend_lsc-${count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.backend_lsc.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.backend_lsc.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.backend_lsc.id
  }

  tags = [
        vsphere_tag.ansible_group_backend.id,
  ]

  vapp {
    properties = {
     hostname    = "backend_lsc-${count.index}"
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.backend_lsc_userdata[count.index].rendered)
   }
 }

  connection {
    host        = self.default_ip_address
    type        = "ssh"
    agent       = false
    user        = var.backend_lsc.username
    private_key = file(var.jump["private_key_path"])
    }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }
}
