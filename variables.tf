#
# Environment Variables
#
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "avi_password" {}
variable "avi_user" {}
variable "avi_vsphere_user" {}
variable "avi_vsphere_password" {}
variable "avi_vsphere_server" {}
#
# Other Variables
#
variable "vcenter" {
  type = map
  default = {
    dc = "sof2-01-vc08"
    cluster = "sof2-01-vc08c01"
    datastore = "sof2-01-vc08c01-vsan"
    resource_pool = "sof2-01-vc08c01/Resources"
    folder = "NicTfVmw"
    networkMgmt = "vxw-dvs-34-virtualwire-3-sid-1080002-sof2-01-vc08-avi-mgmt"
  }
}

variable "controller" {
  default = {
    cpu = 16
    memory = 32768
    disk = 256
    count = "1"
    version = "20.1.3-9085"
    floatingIp = "10.41.134.130"
    wait_for_guest_net_timeout = 4
    private_key_path = "~/.ssh/cloudKey"
    environment = "VMWARE"
    dns =  ["10.23.108.1", "10.23.108.2"]
    ntp = ["95.81.173.155", "188.165.236.162"]
    from_email = "avicontroller@avidemo.fr"
    se_in_provider_context = "true" # true is required for LSC Cloud
    tenant_access_to_provider_se = "true"
    tenant_vrf = "false"
    aviCredsJsonFile = "~/.avicreds.json"
    public_key_path = "~/.ssh/cloudKey.pub"
  }
}

variable "jump" {
  type = map
  default = {
    name = "jump"
    cpu = 2
    memory = 4096
    disk = 20
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
    aviPbAbsentTag = "v1.43"
    aviConfigureUrl = "https://github.com/tacobayle/aviConfigure"
    aviConfigureTag = "v3.51"
    version = "2.9.12"
    opencartInstallUrl = "https://github.com/tacobayle/ansibleOpencartInstall"
    opencartInstallTag = "v1.19"
    directory = "ansible"
    jsonFile = "~/fromTf.json"
    yamlFile = "~/fromTf.yml"
  }
}

variable "backend_vmw" {
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    username = "ubuntu"
    network = "vxw-dvs-34-virtualwire-117-sid-1080116-sof2-01-vc08-avi-dev113"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    ipsData = ["100.64.130.203", "100.64.130.204"]
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    maskData = "/24"
  }
}

variable "backend_lsc" {
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    username = "ubuntu"
    network = "vxw-dvs-34-virtualwire-117-sid-1080116-sof2-01-vc08-avi-dev113"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    ipsData = ["100.64.130.205", "100.64.130.206"]
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    maskData = "/24"
  }
}

variable "opencart" {
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    username = "ubuntu"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    opencartDownloadUrl = "https://github.com/opencart/opencart/releases/download/3.0.3.5/opencart-3.0.3.5.zip"
    ipsData = ["100.64.130.201", "100.64.130.202"]
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    maskData = "/24"
    network = "vxw-dvs-34-virtualwire-117-sid-1080116-sof2-01-vc08-avi-dev113"
  }
}

variable "mysql" {
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    username = "ubuntu"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    ipsData = ["100.64.130.200"]
    maskData = "/24"
    network = "vxw-dvs-34-virtualwire-117-sid-1080116-sof2-01-vc08-avi-dev113"
     }
}

variable "client" {
  type = map
  default = {
    cpu = 2
    count = 2
    memory = 4096
    disk = 20
    username = "ubuntu"
    network = "vxw-dvs-34-virtualwire-118-sid-1080117-sof2-01-vc08-avi-dev114"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
  }
}

variable "domain" {
  type = map
  default = {
    name = "vmw.avidemo.fr"
  }
}

variable "vmw" {
  default = {
    name = "cloudVmw"
    datacenter = "sof2-01-vc08"
    dhcp_enabled = "true"
    management_network = {
      name = "vxw-dvs-34-virtualwire-3-sid-1080002-sof2-01-vc08-avi-mgmt"
      dhcp_enabled = "true"
      exclude_discovered_subnets = "true"
      vcenter_dvs = "true"
    }
    network_vip = {
      name = "vxw-dvs-34-virtualwire-118-sid-1080117-sof2-01-vc08-avi-dev114"
      ipStartPool = "50"
      ipEndPool = "99"
      cidr = "100.64.131.0/24"
      type = "V4"
      exclude_discovered_subnets = "true"
      vcenter_dvs = "true"
      dhcp_enabled = "no"
    }
    network_backend = {
      name = "vxw-dvs-34-virtualwire-117-sid-1080116-sof2-01-vc08-avi-dev113"
      cidr = "100.64.130.0/24"
      type = "V4"
      exclude_discovered_subnets = "true"
      vcenter_dvs = "true"
      dhcp_enabled = "yes"
    }
    serviceEngineGroup = [
      {
        name = "Default-Group"
        ha_mode = "HA_MODE_SHARED"
        min_scaleout_per_vs = 2
        buffer_se = 1
        extra_shared_config_memory = 0
        vcenter_folder = "NicTfVmw"
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
        ha_mode = "HA_MODE_SHARED"
        min_scaleout_per_vs = 1
        buffer_se = 2
        extra_shared_config_memory = 0
        vcenter_folder = "NicTfVmw"
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
        ha_mode = "HA_MODE_SHARED"
        min_scaleout_per_vs = 1
        buffer_se = 0
        extra_shared_config_memory = 2000
        vcenter_folder = "NicTfVmw"
        vcpus_per_se = 2
        memory_per_se = 8192
        disk_per_se = 25
        realtime_se_metrics = {
          enabled = true
          duration = 0
        }
      }
    ]
    pool = {
      name = "pool1-vmw"
      lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
    }
    pool_opencart = {
      name = "pool-opencart-vmw"
      lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
      application_persistence_profile_ref = "System-Persistence-Client-IP"
    }
    virtualservices = {
      http = [
        {
          name = "app1"
          pool_ref = "pool1-vmw"
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
          pool_ref = "pool1-vmw"
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
          pool_ref = "pool-opencart-vmw"
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
          services: [
            {
              port = 53
            }
          ]
        },
        {
          name = "app4-gslb"
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
}

variable "lsc" {
  default = {
    name = "cloudLsc"
    network_vip = {
      name = "net-lsc-vip"
      ipStartPool = "100"
      ipEndPool = "110"
      cidr = "100.64.131.0/24"
      type = "V4"
    }
    serviceEngineGroup = {
      name = "Default-Group"
      cloud_ref = "cloudLsc"
      vcpus_per_se = 2
      kernel_version = "4.4.0-72-generic"
      memory_per_se = 4096
      disk_per_se = 25
      SE_INBAND_MGMT = "False"
      DPDK = "Yes"
      count = 4
      networks = [
        {
          name = "vxw-dvs-34-virtualwire-3-sid-1080002-sof2-01-vc08-avi-mgmt"
        },
        {
          name = "vxw-dvs-34-virtualwire-117-sid-1080116-sof2-01-vc08-avi-dev113"
        },
        {
          name = "vxw-dvs-34-virtualwire-118-sid-1080117-sof2-01-vc08-avi-dev114"
        },
      ]
      username = "ubuntu"
      templateName = "ubuntu-xenial-16.04-cloudimg-template"
      folder = "NicTfVmw"
      public_key_path = "~/.ssh/cloudKey.pub"
      private_key_path = "~/.ssh/cloudKey"
    }
    pool = {
        name = "pool9-lsc"
        lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
    }
    virtualservices = {
      http = [
        {
          name = "app9-lsc"
          pool_ref = "pool9-lsc"
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
          services: [
            {
              port = 53
            }
          ]
        }
      ]
    }
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