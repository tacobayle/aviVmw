


data "template_file" "opencartbackend_userdata" {
  count = length(var.opencartbackendIpsMgt)
  template = file("${path.module}/userdata/opencartbackend.userdata")
  vars = {
    password     = var.opencartbackend["password"]
    pubkey       = file(var.jump["public_key_path"])
    cidrMgt      = element(var.opencartbackendIpsMgt, count.index)
    opencartDownloadUrl = var.opencartbackend["opencartDownloadUrl"]
    domainName = var.avi_gslb["domain"]
    subnetSecondary = var.opencartbackend["subnetSecondary"]
  }
}
#
data "vsphere_virtual_machine" "opencartbackend" {
  name          = var.opencartbackend["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
resource "vsphere_virtual_machine" "opencartbackend" {
  count            = length(var.opencartbackendIpsMgt)
  name             = "opencartbackend-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path

  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  network_interface {
                      network_id = data.vsphere_network.networkBackend.id
  }


  num_cpus = var.opencartbackend["cpu"]
  memory = var.opencartbackend["memory"]
  wait_for_guest_net_timeout = var.opencartbackend["wait_for_guest_net_timeout"]
  #wait_for_guest_net_routable = var.opencartbackend["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.opencartbackend.guest_id
  scsi_type = data.vsphere_virtual_machine.opencartbackend.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.opencartbackend.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.opencartbackend.scsi_controller_scan_count

  disk {
    size             = var.opencartbackend["disk"]
    label            = "opencartbackend-${count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.opencartbackend.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.opencartbackend.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.opencartbackend.id
  }

  vapp {
    properties = {
     hostname    = "opencartbackend-${count.index}"
     password    = var.opencartbackend["password"]
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.opencartbackend_userdata[count.index].rendered)
   }
 }

  connection {
    host        = self.default_ip_address
    type        = "ssh"
    agent       = false
    user        = "ubuntu"
    private_key = file(var.jump["private_key_path"])
    }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }
}