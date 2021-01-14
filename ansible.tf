resource "null_resource" "foo7" {
  depends_on = [vsphere_virtual_machine.jump]
  connection {
    host = vsphere_virtual_machine.jump.default_ip_address
    type = "ssh"
    agent = false
    user = var.jump.username
    private_key = file(var.jump.private_key_path)
  }

  provisioner "file" {
    content = <<EOF
---
mysql_db_hostname: ${var.mysql.ipsData[0]}

controller:
  environment: ${var.controller.environment}
  username: ${var.avi_user}
  version: ${split("-", var.controller.version)[0]}
  password: ${var.avi_password}
  floatingIp: ${var.controller.floatingIp}
  count: ${var.controller.count}
  from_email: ${var.controller.from_email}
  se_in_provider_context: ${var.controller.se_in_provider_context}
  tenant_access_to_provider_se: ${var.controller.tenant_access_to_provider_se}
  tenant_vrf: ${var.controller.tenant_vrf}
  aviCredsJsonFile: ${var.controller.aviCredsJsonFile}
  private_key_path: ${var.controller.private_key_path}

controllerPrivateIps:
${yamlencode(vsphere_virtual_machine.controller.*.default_ip_address)}

ntpServers:
${yamlencode(var.controller.ntp.*)}

dnsServers:
${yamlencode(var.controller.dns.*)}

vmw:
  name: &cloud0 ${var.avi_cloud.name}
  network: ${var.avi_cloud.network}
  networkDhcpEnabled: ${var.avi_cloud.networkDhcpEnabled}
  networkExcludeDiscoveredSubnets: ${var.avi_cloud.networkExcludeDiscoveredSubnets}
  networkVcenterDvs: ${var.avi_cloud.networkVcenterDvs}
  dhcp_enabled: ${var.avi_cloud.dhcp_enabled}
  vcenter_configuration:
    username: ${var.vsphere_user}
    password: ${var.vsphere_password}
    vcenter_url: ${var.vsphere_server}
    privilege: WRITE_ACCESS
    datacenter: ${var.vcenter.dc}
    management_network: "/api/vimgrnwruntime/?name=${var.avi_cloud.network}"

avi_applicationprofile:
  http:
    - name: &appProfile0 applicationProfileOpencart

# don't change the above variable name
avi_servers:
${yamlencode(var.backend.ipsData)}

avi_servers_open_cart:
${yamlencode(var.opencart.ipsData)}

avi_pool:
  name: ${var.avi_pool.name}
  lb_algorithm: ${var.avi_pool.lb_algorithm}
  cloud_ref: ${var.avi_cloud.name}

avi_pool_open_cart:
  application_persistence_profile_ref: ${var.avi_pool_opencart.application_persistence_profile_ref}
  name: ${var.avi_pool_opencart.name}
  lb_algorithm: ${var.avi_pool_opencart.lb_algorithm}
  cloud_ref: ${var.avi_cloud.name}

avi_gslb:
  dns_configs:
    - domain_name: ${var.avi_gslb.domain}
  sites:
    - username:  ${var.avi_user}
      password: ${var.avi_password}
      cluster_uuid: "{{ outputCluster.obj.uuid | default('Null') }}"
      member_type: ${var.avi_gslb.primaryType}
      name: ${var.avi_gslb.primaryName}
      ip_addresses:
        - type: "V4"
          addr: "{{ avi_credentials.controller | default('Null') }}"
      dns_vses:
      - domain_names:
        - ${var.avi_gslb.domain}
        dns_vs_uuid: "{{ outputVsDns.results.1.obj.uuid | default('Null') }}"
    - cluster_uuid: "{{ gslbsiteopsOutput.obj.rx_uuid | default('Null') }}"
      name: ${var.avi_gslb.secondaryName}
      ip_addresses:
      - addr: "{{ lookup('dig', '${var.avi_gslb.secondaryFqdn}' ) | default('Null') }}"
        type: "V4"
      username: ${var.avi_user}
      password: ${var.avi_password}
      member_type: ${var.avi_gslb.secondaryType}

avi_gslbgeodbprofile:
  - name: ${var.gslbProfile.name}
    entries:
      - priority: 10
        file:
          format: ${var.gslbProfile.fileFormat}
          filename: ${var.gslbProfile.fileName}

avi_gslbservice:
  name: ${var.avi_gslbservice.name}
  site_persistence_enabled: ${var.avi_gslbservice.site_persistence_enabled}
  min_members: ${var.avi_gslbservice.min_members}
  health_monitor_scope: ${var.avi_gslbservice.health_monitor_scope}
  pool_algorithm: ${var.avi_gslbservice.pool_algorithm}
  localPoolPriority: ${var.avi_gslbservice.localPoolPriority}
  localPoolAlgorithm: ${var.avi_gslbservice.localPoolAlgorithm}
  remotePoolPriority: ${var.avi_gslbservice.remotePoolPriority}
  remotePoolAlgorithm: ${var.avi_gslbservice.remotePoolAlgorithm}

EOF
    destination = var.ansible.yamlFile
  }

  provisioner "file" {
    content = <<EOF
{"serviceEngineGroup": ${jsonencode(var.serviceEngineGroup)}, "avi_virtualservice": ${jsonencode(var.avi_virtualservice)}, "avi_network_vip": ${jsonencode(var.avi_network_vip)}, "avi_network_backend": ${jsonencode(var.avi_network_backend)}, "lsc": ${jsonencode(var.lsc)}, "seLsc": ${jsonencode(vsphere_virtual_machine.se.*.default_ip_address)}, "domain": ${jsonencode(var.domain)}}
EOF
    destination = var.ansible.jsonFile
  }


  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/${basename(var.jump.private_key_path)}",
      "cd ~/ansible ; git clone ${var.ansible.opencartInstallUrl} --branch ${var.ansible.opencartInstallTag} ; cd ${split("/", var.ansible.opencartInstallUrl)[4]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml local.yml --extra-vars @${var.ansible.jsonFile} --extra-vars @${var.ansible.yamlFile}",
      "cd ~/ansible ; git clone ${var.ansible.aviConfigureUrl} --branch ${var.ansible.aviConfigureTag} ; cd ${split("/", var.ansible.aviConfigureUrl)[4]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml local.yml --extra-vars @${var.ansible.jsonFile} --extra-vars @${var.ansible.yamlFile}",
    ]
  }
}