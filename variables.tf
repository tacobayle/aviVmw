#
### VMware variables
#
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
#
#
variable "dc" {
  default     = "wdc-06-vc12"
}
#
variable "cluster" {
  default     = "wdc-06-vc12c01"
}
#
variable "datastore" {
  default     = "wdc-06-vc12c01-vsan"
}
#
variable "networkMgt" {
  default     = "vxw-dvs-34-virtualwire-3-sid-6120002-wdc-06-vc12-avi-mgmt"
}
#
variable "folder" {
  default     = "NicolasTf"
}
#
variable "resource_pool" {
  default     = "wdc-06-vc12c01/Resources"
}
#
variable "controller" {
  type = map
  default = {
    cpu = 8
    memory = 24768
    disk = 128
    count = "1"
    version = "20.1.1-9071"
    floatingIp = "10.206.112.58"
    wait_for_guest_net_timeout = 2
    private_key_path = "~/.ssh/cloudKey"
    environment = "VMWARE"
    dnsMain = "8.8.8.8"
    ntpMain = "95.81.173.155"
  }
}
#
variable "wait_for_guest_net_timeout" {
  default = "5"
}
#
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
  }
}
#
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
#
variable "opencartbackend" {
  type = map
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    password = "Avi_2020"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    opencartDownloadUrl = "https://github.com/opencart/opencart/releases/download/3.0.3.5/opencart-3.0.3.5.zip"
    subnetSecondary = "/24"
  }
}
#
variable "mysql" {
  type = map
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    password = "Avi_2020"
    wait_for_guest_net_timeout = 2
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    subnetSecondary = "/24"
  }
}
#

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
#
variable "backendIpsMgt" {
  type = list
  default = ["10.206.112.120/22", "10.206.112.123/22"]
}
#
variable "opencartbackendIpsMgt" {
  type = list
  default = ["100.64.129.201", "100.64.129.202"]
}
#
variable "mysqlIpsMgt" {
  type = list
  default = ["100.64.129.200"]
}
#
variable "clientIpsMgt" {
  type = list
  default = ["10.206.112.114/22"]
}
#
### Ansible variables
#
variable "ansibleHostFile" {
  default = "ansible/hosts"
}
#
variable "ansibleDirectory" {
  default = "ansible"
}
#
variable "avi_password" {}
variable "avi_user" {}
#
variable "avi_cloud" {
  type = map
  default = {
    name = "CloudVmw"
    vtype = "CLOUD_VCENTER"
    network = "vxw-dvs-34-virtualwire-3-sid-6120002-wdc-06-vc12-avi-mgmt"
    dhcp_enabled = "true"
    networkDhcpEnabled = "true"
    networkExcludeDiscoveredSubnets = "true"
    networkVcenterDvs= "true"
  }
}
#
variable "avi_network_vip" {
  type = map
  default = {
    name = "vxw-dvs-34-virtualwire-120-sid-6120119-wdc-06-vc12-avi-dev116"
    subnet = "100.64.133.0/24"
    begin = "100.64.133.50"
    end = "100.64.133.99"
    type = "V4"
    exclude_discovered_subnets = "true"
    vcenter_dvs = "true"
    dhcp_enabled = "no"
  }
}
#
variable "avi_network_backend" {
  type = map
  default = {
    subnet = "100.64.129.0/24"
    type = "V4"
    dhcp_enabled = "yes"
    exclude_discovered_subnets = "true"
    vcenter_dvs = "true"
  }
}
#
variable "domain" {
  type = map
  default = {
    name = "vmw.avidemo.fr"
  }
}
#
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
#
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
#
variable "ansibleAviPbAbsent" {
  default     = "https://github.com/tacobayle/ansiblePbAviAbsent"
}
