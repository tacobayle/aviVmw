#
# Environment Variables
#
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
#
# Other Variables
#
variable "vcenter" {
  type = map
  default = {
    dc = "wdc-06-vc12"
    cluster = "wdc-06-vc12c01"
    datastore = "wdc-06-vc12c01-vsan"
    resource_pool = "wdc-06-vc12c01/Resources"
    folder = "NicTfVmw"
    networkMgmt = "vxw-dvs-34-virtualwire-3-sid-6120002-wdc-06-vc12-avi-mgmt"
  }
}

variable "controller" {
  default = {
    cpu = 8
    memory = 24768
    disk = 128
    count = "1"
    version = "20.1.1-9071"
    floatingIp = "10.41.134.130"
    wait_for_guest_net_timeout = 2
    private_key_path = "~/.ssh/cloudKey"
    environment = "VMWARE"
    dns =  ["8.8.8.8", "8.8.4.4"]
    ntp = ["95.81.173.155", "188.165.236.162"]
    floatingIp = "10.41.134.130"
    from_email = "avicontroller@avidemo.fr"
    se_in_provider_context = "false"
    tenant_access_to_provider_se = "true"
    tenant_vrf = "false"
    aviCredsJsonFile = "~/.avicreds.json"
  }
}

variable "wait_for_guest_net_timeout" {
  default = "5"
}

variable "jump" {
  type = map
  default = {
    name = "jump"
    cpu = 2
    memory = 4096
    disk = 20
    password = "Avi_2020"
    public_key_path = "~/.ssh/cloudKey.pub"
    private_key_path = "~/.ssh/cloudKey"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    avisdkVersion = "18.2.9"
    username = "ubuntu"
  }
}

variable "ansible" {
  type = map
  default = {
    aviPbAbsentUrl = "https://github.com/tacobayle/ansiblePbAviAbsent"
    aviPbAbsentTag = "v1.36"
    aviConfigureUrl = "https://github.com/tacobayle/aviConfigure"
    aviConfigureTag = "v2.98"
    version = "2.9.12"
    opencartInstallUrl = "https://github.com/tacobayle/ansibleOpencartInstall"
    opencartInstallTag = "v1.19"
    directory = "ansible"
    jsonFile = "~/fromTf.json"
    yamlFile = "~/fromTf.yml"
  }
}

variable "backend" {
  type = map
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    password = "Avi_2020"
    network = "vxw-dvs-34-virtualwire-116-sid-6120115-wdc-06-vc12-avi-dev112"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    defaultGwMgt = "10.206.112.1"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    dnsMain = "10.206.8.130"
    dnsSec = "10.206.8.131"
  }
}

variable "opencart" {
  type = map
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    password = "Avi_2020"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    opencartDownloadUrl = "https://github.com/opencart/opencart/releases/download/3.0.3.5/opencart-3.0.3.5.zip"
    subnetLastlength = "/24"
  }
}

variable "mysql" {
  type = map
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    password = "Avi_2020"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    subnetLastlength = "/24"
  }
}

variable "client" {
  type = map
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    password = "Avi_2020"
    network = "vxw-dvs-34-virtualwire-120-sid-6120119-wdc-06-vc12-avi-dev116"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    defaultGwMgt = "10.206.112.1"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    dnsMain = "10.206.8.130"
    dnsSec = "10.206.8.131"
  }
}

variable "backendIpsMgt" {
  type = list
  default = ["10.206.112.120/22", "10.206.112.123/22"]
}

variable "opencartIps" {
  type = list
  default = ["100.64.129.201", "100.64.129.202"]
}

variable "mysqlIps" {
  type = list
  default = ["100.64.129.200"]
}

variable "clientIpsMgt" {
  type = list
  default = ["10.206.112.114/22"]
}

variable "avi_password" {}
variable "avi_user" {}

variable "domain" {
  type = map
  default = {
    name = "vmw.avidemo.fr"
  }
}

variable "avi_cloud" {
  type = map
  default = {
    name = "CloudVmw" # don't change the value
    network = "vxw-dvs-34-virtualwire-3-sid-6120002-wdc-06-vc12-avi-mgmt"
    dhcp_enabled = "true"
    networkDhcpEnabled = "true"
    networkExcludeDiscoveredSubnets = "true"
    networkVcenterDvs= "true"
  }
}

variable "avi_network_vip" {
  type = map
  default = {
    name = "vxw-dvs-34-virtualwire-120-sid-6120119-wdc-06-vc12-avi-dev116"
    cidr = "100.64.133.0/24"
    begin = "50"
    end = "99"
    type = "V4"
    exclude_discovered_subnets = "true"
    vcenter_dvs = "true"
    dhcp_enabled = "no"
  }
}

variable "avi_network_backend" {
  type = map
  default = {
    cidr = "100.64.129.0/24"
    type = "V4"
    dhcp_enabled = "yes"
    exclude_discovered_subnets = "true"
    vcenter_dvs = "true"
  }
}

variable "serviceEngineGroup" {
  default = [
    {
      name = "Default-Group"
      cloud_ref = "CloudVmw"
      ha_mode = "HA_MODE_SHARED"
      min_scaleout_per_vs = 2
      buffer_se = 1
      extra_shared_config_memory = 0
      vcenter_folder = "NicAviVmw"
      vcpus_per_se = 2
      memory_per_se = 4096
      disk_per_se = 25
      realtime_se_metrics = {
        enabled = true
        duration = 0
      }
    },
    {
      name = "seGroupCpuAutoScale"
      cloud_ref = "CloudVmw"
      ha_mode = "HA_MODE_SHARED"
      min_scaleout_per_vs = 1
      buffer_se = 2
      extra_shared_config_memory = 0
      vcenter_folder = "NicAviVmw"
      vcpus_per_se = 1
      memory_per_se = 2048
      disk_per_se = 25
      auto_rebalance = true
      auto_rebalance_interval = 30
      auto_rebalance_criteria = [
        "SE_AUTO_REBALANCE_CPU"
              ]
      realtime_se_metrics = {
        enabled = true
        duration = 0
      }
    },
    {
      name = "seGroupGslb"
      cloud_ref = "CloudVmw"
      ha_mode = "HA_MODE_SHARED"
      min_scaleout_per_vs = 1
      buffer_se = 0
      extra_shared_config_memory = 2000
      vcenter_folder = "NicAviVmw"
      vcpus_per_se = 2
      memory_per_se = 8192
      disk_per_se = 25
      realtime_se_metrics = {
        enabled = true
        duration = 0
      }
    }
  ]
}

variable "avi_pool" {
  type = map
  default = {
    name = "pool1"
    lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
  }
}

variable "avi_pool_opencart" {
  type = map
  default = {
    name = "poolOpencart"
    lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
    application_persistence_profile_ref = "System-Persistence-Client-IP"
  }
}

variable "avi_virtualservice" {
  default = {
    http = [
      {
        name = "app1"
        pool_ref = "pool1"
        cloud_ref = "CloudVmw"
        services: [
          {
            port = 80
            enable_ssl = "false"
          },
          {
            port = 443
            enable_ssl = "true"
          }
        ]
      },
      {
        name = "app2-se-cpu-auto-scale"
        pool_ref = "pool2"
        cloud_ref = "CloudVmw"
        services: [
          {
            port = 80
            enable_ssl = "false"
          },
          {
            port = 443
            enable_ssl = "true"
          }
        ]
        se_group_ref: "seGroupCpuAutoScale"
      },
      {
        name = "opencart"
        pool_ref = "poolOpencart"
        cloud_ref = "CloudVmw"
        services: [
          {
            port = 80
            enable_ssl = "false"
          },
          {
            port = 443
            enable_ssl = "true"
          }
        ]
      }
    ]
    dns = [
      {
        name = "app3-dns"
        cloud_ref = "CloudVmw"
        services: [
          {
            port = 53
          }
        ]
      },
      {
        name = "app4-gslb"
        cloud_ref = "CloudVmw"
        services: [
          {
            port = 53
          }
        ]
        se_group_ref: "seGroupGslb"
      }
    ]
  }
}

variable "avi_gslb" {
  type = map
  default = {
    domain = "gslb.avidemo.fr"
    primaryName = "local_controller"
    primaryType = "GSLB_ACTIVE_MEMBER"
    secondaryName = "remote_controller"
    secondaryType = "GSLB_PASSIVE_MEMBER"
    secondaryFqdn = "controller.aws.avidemo.fr"
  }
}

variable "gslbProfile" {
  type = map
  default = {
    name = "geoProfile"
    fileFormat = "GSLB_GEODB_FILE_FORMAT_AVI"
    fileName = "AviGeoDb.txt.gz"
  }
}

variable "avi_gslbservice" {
  type = map
  default = {
    name = "opencart"
    site_persistence_enabled = "false"
    min_members = "1"
    health_monitor_scope = "GSLB_SERVICE_HEALTH_MONITOR_ALL_MEMBERS"
    pool_algorithm = "GSLB_SERVICE_ALGORITHM_PRIORITY"
    localPoolPriority = "20"
    localPoolAlgorithm = "GSLB_ALGORITHM_ROUND_ROBIN"
    remotePoolPriority = "10"
    remotePoolAlgorithm = "GSLB_ALGORITHM_ROUND_ROBIN"
  }
}
