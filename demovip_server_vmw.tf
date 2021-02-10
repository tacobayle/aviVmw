resource "vsphere_tag" "ansible_group_demovip_server_vmw" {
  name             = "demovip_server_vmw"
  category_id      = vsphere_tag_category.ansible_group_demovip_server_vmw.id
}

data "template_file" "demovip_server_vmw_userdata" {
  count = length(var.demovip_server_vmw.ipsData)
  template = file("${path.module}/userdata/demovip_server_vmw.userdata")
  vars = {
    username     = var.demovip_server_vmw.username
    pubkey       = file(var.jump.public_key_path)
    netplanFile  = var.demovip_server_vmw.netplanFile
    maskData = var.demovip_server_vmw.maskData
    ipData      = element(var.demovip_server_vmw.ipsData, count.index)
    url_demovip_server = var.demovip_server_vmw.url_demovip_server
  }
}

data "vsphere_virtual_machine" "demovip_server_vmw" {
  name          = var.demovip_server_vmw.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "demovip_server_vmw" {
  count = length(var.demovip_server_vmw.ipsData)
  name             = "demovip_server_vmw-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path

  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  network_interface {
                      network_id = data.vsphere_network.networkDemoVipServerVmw.id
  }

  num_cpus = var.demovip_server_vmw.cpu
  memory = var.demovip_server_vmw.memory
  wait_for_guest_net_timeout = var.demovip_server_vmw.wait_for_guest_net_timeout
  #wait_for_guest_net_routable = var.demovip_server_vmw["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.demovip_server_vmw.guest_id
  scsi_type = data.vsphere_virtual_machine.demovip_server_vmw.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.demovip_server_vmw.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.demovip_server_vmw.scsi_controller_scan_count

  disk {
    size             = var.demovip_server_vmw.disk
    label            = "demovip_server_vmw-${count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.demovip_server_vmw.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.demovip_server_vmw.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.demovip_server_vmw.id
  }

  tags = [
        vsphere_tag.ansible_group_backend.id,
  ]

  vapp {
    properties = {
     hostname    = "demovip_server_vmw-${count.index}"
     public-keys = file(var.jump.public_key_path)
     user-data   = base64encode(data.template_file.demovip_server_vmw_userdata[count.index].rendered)
   }
 }

  connection {
    host        = self.default_ip_address
    type        = "ssh"
    agent       = false
    user        = var.demovip_server_vmw.username
    private_key = file(var.jump.private_key_path)
    }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }
}
