resource "vsphere_tag" "ansible_group_worker" {
  name             = "workers"
  category_id      = vsphere_tag_category.ansible_group_worker.id
}

data "template_file" "worker_userdata" {
  count = var.worker["count"]
  template = file("${path.module}/userdata/worker.userdata")
  vars = {
    netplanFile  = var.worker["netplanFile"]
    pubkey       = file(var.jump["public_key_path"])
    dockerVersion = var.kubernetes.dockerVersion
    username = var.worker.username
    docker_registry_username = var.docker_registry_username
    docker_registry_password = var.docker_registry_password
  }
}

data "vsphere_virtual_machine" "worker" {
  name          = var.worker["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "worker" {
  count = var.worker["count"]
  name             = "worker-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path

  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  network_interface {
                      network_id = data.vsphere_network.networkWorker.id
  }

  num_cpus = var.worker["cpu"]
  memory = var.worker["memory"]
  #wait_for_guest_net_timeout = var.worker["wait_for_guest_net_timeout"]
  wait_for_guest_net_routable = var.worker["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.worker.guest_id
  scsi_type = data.vsphere_virtual_machine.worker.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.worker.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.worker.scsi_controller_scan_count

  disk {
    size             = var.worker["disk"]
    label            = "worker-${count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.worker.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.worker.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.worker.id
  }

  tags = [
        vsphere_tag.ansible_group_worker.id,
  ]

  vapp {
    properties = {
     hostname    = "worker-${count.index}"
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.worker_userdata[count.index].rendered)
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
