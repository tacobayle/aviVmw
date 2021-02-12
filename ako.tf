data "template_file" "values" {
  count = length(var.vmw.kubernetes.clusters)
  template = file("template/values.yml.template")
  vars = {
    disableStaticRouteSync = var.vmw.kubernetes.clusters[count.index].arePodsReachable
    clusterName  = var.vmw.kubernetes.clusters[count.index].name
    cniPlugin    = var.vmw.kubernetes.clusters[count.index].cni.name
    subnetIP     = split("/", var.vmw.network_vip.cidr)[0]
    subnetPrefix = split("/", var.vmw.network_vip.cidr)[1]
    networkName = var.vmw.network_vip.name
    serviceType = var.vmw.kubernetes.clusters[count.index].service.type
    serviceEngineGroupName = var.vmw.kubernetes.clusters[count.index].serviceEngineGroup.name
    controllerVersion = split("-", var.controller.version)[0]
    cloudName = var.vmw.name
    controllerHost = "1.1.1.1"
  }
}

resource "null_resource" "ako" {
  depends_on = [null_resource.ansible_bootstrap]
  count = length(var.vmw.kubernetes.clusters)
  connection {
    host = vsphere_virtual_machine.master[count.index].default_ip_address
    type = "ssh"
    agent = false
    user = var.vmw.kubernetes.clusters[count.index].username
    private_key = file(var.jump.private_key_path)
  }

  provisioner "local-exec" {
    command = "cat > values-cluster-${count.index} <<EOL\n${data.template_file.values[count.index].rendered}\nEOL"
  }

  provisioner "file" {
    source = "values-cluster-${count.index}"
    destination = "values.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "helm repo add ako ${var.vmw.kubernetes.ako.helm.url}",
      "kubectl create ns ${var.vmw.kubernetes.clusters[count.index].ako.namespace}",
    ]
  }
}
