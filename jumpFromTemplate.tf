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

# Ansible hosts file creation (continuing)

resource "null_resource" "foo4" {
  depends_on = [null_resource.foo3]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
    backend:
      hosts:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo5" {
  depends_on = [null_resource.foo4]
  count = length(var.backendIpsMgt)
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
        ${split("/", element(var.backendIpsMgt, count.index))[0]}:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo6" {
  depends_on = [null_resource.foo5]
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

# Ansible hosts file creation (continuing)

resource "null_resource" "foo7" {
  depends_on = [null_resource.foo6]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
    opencart:
      hosts:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo8" {
  depends_on = [null_resource.foo7]
  count = length(var.opencartbackendIpsMgt)
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
        ${vsphere_virtual_machine.opencartbackend[count.index].default_ip_address}:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo9" {
  depends_on = [null_resource.foo8]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
      vars:
        ansible_user: ubuntu
        ansible_ssh_private_key_file: '~/.ssh/${basename(var.jump["private_key_path"])}'
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo10" {
  depends_on = [null_resource.foo9]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
    mysql:
      hosts:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo11" {
  depends_on = [null_resource.foo10]
  count = length(var.mysqlIpsMgt)
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
        ${vsphere_virtual_machine.mysql[count.index].default_ip_address}:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo12" {
  depends_on = [null_resource.foo11]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
      vars:
        ansible_user: ubuntu
        ansible_ssh_private_key_file: '~/.ssh/${basename(var.jump["private_key_path"])}'
EOF
EOD
  }
}

# Ansible host file creation (finishing)

resource "null_resource" "foo13" {
  depends_on = [null_resource.foo12]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
  vars:
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF
EOD
  }
}


data "template_file" "jumpbox_userdata" {
  template = file("${path.module}/userdata/jump.userdata")
  vars = {
    password      = var.jump["password"]
    pubkey        = file(var.jump["public_key_path"])
    avisdkVersion = var.jump["avisdkVersion"]
  }
}
#
data "vsphere_virtual_machine" "jump" {
  name          = var.jump["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
resource "vsphere_virtual_machine" "jump" {
  name             = var.jump["name"]
  depends_on = [null_resource.foo13]
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path
  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  num_cpus = var.jump["cpu"]
  memory = var.jump["memory"]
  wait_for_guest_net_timeout = var.jump["wait_for_guest_net_timeout"]
  guest_id = data.vsphere_virtual_machine.jump.guest_id
  scsi_type = data.vsphere_virtual_machine.jump.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.jump.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.jump.scsi_controller_scan_count

  disk {
    size             = var.jump["disk"]
    label            = "jump.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.jump.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.jump.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.jump.id
  }

  vapp {
    properties = {
     hostname    = "jump"
     password    = var.jump["password"]
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.jumpbox_userdata.rendered)
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

  provisioner "file" {
  source      = var.jump["private_key_path"]
  destination = "~/.ssh/${basename(var.jump["private_key_path"])}"
  }

  provisioner "file" {
  source      = var.ansibleDirectory
  destination = "~/ansible"
  }

  provisioner "file" {
  content      = <<EOF
---
mysql_db_hostname: ${var.mysqlIpsMgt[0]}

controller:
  environment: ${var.controller["environment"]}
  username: ${var.avi_user}
  version: ${split("-", var.controller["version"])[0]}
  password: ${var.avi_password}
  floatingIp: ${var.controller["floatingIp"]}
  count: ${var.controller["count"]}

avi_systemconfiguration:
  global_tenant_config:
    se_in_provider_context: false
    tenant_access_to_provider_se: true
    tenant_vrf: false
  welcome_workflow_complete: true
  ntp_configuration:
    ntp_servers:
      - server:
          type: V4
          addr: ${var.controller["ntpMain"]}
  dns_configuration:
    search_domain: ''
    server_list:
      - type: V4
        addr: ${var.controller["dnsMain"]}
  email_configuration:
    from_email: test@avicontroller.net
    smtp_type: SMTP_LOCAL_HOST

avi_cloud:
  name: ${var.avi_cloud["name"]}
  vtype: ${var.avi_cloud["vtype"]}
  network: ${var.avi_cloud["network"]}
  networkDhcpEnabled: ${var.avi_cloud["networkDhcpEnabled"]}
  networkExcludeDiscoveredSubnets: ${var.avi_cloud["networkExcludeDiscoveredSubnets"]}
  networkVcenterDvs: ${var.avi_cloud["networkVcenterDvs"]}
  dhcp_enabled: ${var.avi_cloud["dhcp_enabled"]}
  vcenter_configuration:
    username: ${var.vsphere_user}
    password: ${var.vsphere_password}
    vcenter_url: ${var.vsphere_server}
    privilege: WRITE_ACCESS
    datacenter: ${var.dc}
    management_network: "/api/vimgrnwruntime/?name=${var.avi_cloud["network"]}"

avi_cloud_second:
  name: ${var.avi_cloud_second["name"]}
  vtype: ${var.avi_cloud_second["vtype"]}
  aws_configuration:
    region: ${var.regionAws}
    secret_access_key: ${var.secretKeyAws}
    access_key_id: ${var.accessKeyAws}
    route53_integration: true
    asg_poll_interval: 60
    vpc_id: ${aws_vpc.vpc[0].id}
    zones:
      - mgmt_network_uuid: ${aws_subnet.subnetAviSeMgt[0].id}
        availability_zone: ${data.aws_availability_zones.available.names[0]}
        mgmt_network_name: ${element(var.cidrSubnetAviSeMgt, 0)}
      - mgmt_network_uuid: ${aws_subnet.subnetAviSeMgt[1].id}
        availability_zone: ${data.aws_availability_zones.available.names[1]}
        mgmt_network_name: ${element(var.cidrSubnetAviSeMgt, 1)}

serviceEngineGroup:
  - name: &segroup0 Default-Group
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 2
    buffer_se: 1
    extra_shared_config_memory: 0
    vcenter_folder: ${var.folder}
    vcpus_per_se: 2
    memory_per_se: 4096
    disk_per_se: 25
    realtime_se_metrics:
      enabled: true
      duration: 0
  - name: &segroup1 seGroupCpuAutoScale
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 1
    buffer_se: 2
    extra_shared_config_memory: 0
    vcenter_folder: ${var.folder}
    vcpus_per_se: 1
    memory_per_se: 2048
    disk_per_se: 25
    auto_rebalance: true
    auto_rebalance_interval: 30
    auto_rebalance_criteria:
    - SE_AUTO_REBALANCE_CPU
    realtime_se_metrics:
      enabled: true
      duration: 0
  - name: &segroup2 seGroupGslb
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 1
    buffer_se: 0
    extra_shared_config_memory: 2000
    vcenter_folder: ${var.folder}
    vcpus_per_se: 2
    memory_per_se: 8192
    disk_per_se: 25
    realtime_se_metrics:
      enabled: true
      duration: 0

domain:
  name: ${var.domain["name"]}

avi_network_vip:
  name: ${var.avi_network_vip["name"]}
  dhcp_enabled: ${var.avi_network_vip["dhcp_enabled"]}
  exclude_discovered_subnets: ${var.avi_network_vip["exclude_discovered_subnets"]}
  vcenter_dvs: ${var.avi_network_vip["vcenter_dvs"]}
  subnet:
    - prefix:
        mask: "${element(split("/", var.avi_network_vip["subnet"]),1)}"
        ip_addr:
          type: "${var.avi_network_vip["type"]}"
          addr: "${element(split("/", var.avi_network_vip["subnet"]),0)}"
      static_ranges:
        - begin:
            type: "${var.avi_network_vip["type"]}"
            addr: "${var.avi_network_vip["begin"]}"
          end:
            type: "${var.avi_network_vip["type"]}"
            addr: "${var.avi_network_vip["end"]}"

avi_network_backend:
  name: ${var.backend["network"]}
  dhcp_enabled: ${var.avi_network_backend["dhcp_enabled"]}
  exclude_discovered_subnets: ${var.avi_network_backend["exclude_discovered_subnets"]}
  vcenter_dvs: ${var.avi_network_backend["vcenter_dvs"]}
  subnet:
    - prefix:
        mask: "${element(split("/", var.avi_network_backend["subnet"]),1)}"
        ip_addr:
          type: "${var.avi_network_backend["type"]}"
          addr: "${element(split("/", var.avi_network_backend["subnet"]),0)}"

avi_applicationprofile:
  http:
    - name: &appProfile0 applicationProfileOpencart

avi_servers:
${yamlencode(vsphere_virtual_machine.backend.*.guest_ip_addresses)}

avi_servers_open_cart:
${yamlencode(var.opencartbackendIpsMgt)}

avi_healthmonitor:
  - name: &hm0 hm1
    receive_timeout: 1
    failed_checks: 2
    send_interval: 1
    successful_checks: 2
    type: HEALTH_MONITOR_HTTP
    http_request: "HEAD / HTTP/1.0"
    http_response_code:
      - HTTP_2XX
      - HTTP_3XX
      - HTTP_5XX

avi_pool:
  name: &pool0 pool1
  lb_algorithm: LB_ALGORITHM_ROUND_ROBIN
  health_monitor_refs: *hm0

avi_pool_open_cart:
  name: &pool1 poolOpencart
  lb_algorithm: LB_ALGORITHM_ROUND_ROBIN
  health_monitor_refs: *hm0
  application_persistence_profile_ref: System-Persistence-Client-IP

avi_virtualservice:
  http:
    - name: &vs0 app1
      services:
        - port: 80
          enable_ssl: false
        - port: 443
          enable_ssl: true
      pool_ref: *pool0
      enable_rhi: false
    - name: &vs1 app2-se-cpu-auto-scale-out
      services:
        - port: 443
          enable_ssl: true
      pool_ref: pool1
      enable_rhi: false
      se_group_ref: *segroup1
    - name: &vs2 opencart
      services:
        - port: 80
          enable_ssl: false
        - port: 443
          enable_ssl: true
      pool_ref: *pool1
      enable_rhi: false
      application_profile_ref: *appProfile0
  dns:
    - name: app3-dns
      services:
        - port: 53
    - name: app4-gslb
      services:
        - port: 53
      se_group_ref: *segroup2

avi_gslb:
  dns_configs:
    - domain_name: ${var.avi_gslb["domain"]}
  sites:
    - username:  ${var.avi_user}
      password: ${var.avi_password}
      cluster_uuid: "{{ outputCluster.obj.uuid | default('Null') }}"
      member_type: ${var.avi_gslb["primaryType"]}
      name: ${var.avi_gslb["primaryName"]}
      ip_addresses:
        - type: "V4"
          addr: "{{ avi_credentials.controller | default('Null') }}"
      dns_vses:
      - domain_names:
        - ${var.avi_gslb["domain"]}
        dns_vs_uuid: "{{ outputVsDns.results.1.obj.uuid | default('Null') }}"
    - cluster_uuid: "{{ gslbsiteopsOutput.obj.rx_uuid | default('Null') }}"
      name: ${var.avi_gslb["secondaryName"]}
      ip_addresses:
      - addr: "{{ lookup('dig', '${var.avi_gslb["secondaryFqdn"]}' ) | default('Null') }}"
        type: "V4"
      username: ${var.avi_user}
      password: ${var.avi_password}
      member_type: ${var.avi_gslb["secondaryType"]}

avi_gslbgeodbprofile:
  - name: ${var.gslbProfile["name"]}
    entries:
      - priority: 10
        file:
          format: ${var.gslbProfile["fileFormat"]}
          filename: ${var.gslbProfile["fileName"]}

avi_gslbservice:
  name: ${var.avi_gslbservice["name"]}
  site_persistence_enabled: ${var.avi_gslbservice["site_persistence_enabled"]}
  min_members: ${var.avi_gslbservice["min_members"]}
  health_monitor_scope: ${var.avi_gslbservice["health_monitor_scope"]}
  pool_algorithm: ${var.avi_gslbservice["pool_algorithm"]}
  localPoolPriority: ${var.avi_gslbservice["localPoolPriority"]}
  localPoolAlgorithm: ${var.avi_gslbservice["localPoolAlgorithm"]}
  remotePoolPriority: ${var.avi_gslbservice["remotePoolPriority"]}
  remotePoolAlgorithm: ${var.avi_gslbservice["remotePoolAlgorithm"]}

EOF
  destination = "~/ansible/vars/fromTerraform.yml"
  }

  provisioner "remote-exec" {
    inline      = [
      "chmod 600 ~/.ssh/${basename(var.jump["private_key_path"])}",
      "cd ~/ansible ; git clone https://github.com/tacobayle/ansibleOpencartInstall ; ansible-playbook -i hosts ansibleOpencartInstall/local.yml --extra-vars @vars/fromTerraform.yml",
      "cd ~/ansible ; git clone https://github.com/tacobayle/aviConfigure ; ansible-playbook -i hosts aviConfigure/local.yml --extra-vars @vars/fromTerraform.yml",
    ]
  }

}
