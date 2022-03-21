variable "vsphere_user" {
  type    = string
  default = "Administrator@vsphere.local"
}
variable "vsphere_password" {
  type    = string
  default = "password"
}
variable "vsphere_server" {
  type    = string
  default = "vCenter IP"
}
variable "vsphere_net" {
  type    = string
  default = "VM Network"
}
variable "vm_esxi_host" {
  type    = string
  default = "ESXi Host IP"
}

variable "generationDir" {
  type    = string
  default = "/root/ocp4/openshift-install"
}

## Cluster Details

variable "boot_name" {
  type    = string
  default = "bootstrap"
}

variable "cp_name" {
  type    = string
  default = "control-plane" #master names will become control-plane-master0, control-plane-master1, control-plane-master2
}

variable "wrk_name" {
  type    = string
  default = "compute" #worker names will become compute-worker0, compute-worker1, compute-worker2
}
variable "domain" {
  type    = string
  default = "domain.com"
}
## Cluster VM Counts

variable "master_count" {
  type    = string
  default = "3"
}

variable "worker_count" {
  type    = string
  default = "3"
}

#############################################################################
## Template VM

variable "template_vm_disk_size" {
  type    = string
  default = "120"
}
variable "template_vm_memory_size" {
  type    = string
  default = "24384"
}
variable "template_vm_cpu_count" {
  type    = string
  default = "8"
}

#############################################################################
## Bootstrap VM Configuration

variable "bootstrap_disk_size" {
  type    = string
  default = "120"
}
variable "bootstrap_memory_size" {
  type    = string
  default = "16384"
}
variable "bootstrap_cpu_count" {
  type    = string
  default = "4"
}

variable "bootstrap_vm_network_config" {
  type = map(any)
  default = {
    type      = "static"
    ip        = "192.168.20.118"
    subnet    = "255.255.255.0"
    gateway   = "192.168.20.254"
    interface = "ens192"
    dns       = "192.168.40.10"
    server_id = ""
  }
}

variable "master_cpu_count" {
  type    = string
  default = "4"
}
variable "master_memory_size" {
  type    = string
  default = "16384"
}
variable "master_disk_size" {
  type    = string
  default = "120"
}

variable "worker_cpu_count" {
  type    = string
  default = "4"
}
variable "worker_memory_size" {
  type    = string
  default = "16384"
}
variable "worker_disk_size" {
  type    = string
  default = "120"
}
#### Master Nodes - Network Options
variable "master_network_config" {
  type = map(any)
  default = {
    master_0_type      = "static"
    master_0_ip        = "192.168.20.113"
    master_0_subnet    = "255.255.255.0"
    master_0_gateway   = "192.168.20.254"
    master_0_interface = "ens192"
    dns                = "192.168.40.10"
    master_0_server_id = ""

    master_1_type      = "static"
    master_1_ip        = "192.168.20.114"
    master_1_subnet    = "255.255.255.0"
    master_1_gateway   = "192.168.20.254"
    master_1_interface = "ens192"
    dns                = "192.168.40.10"
    master_1_server_id = ""

    master_2_type      = "static"
    master_2_ip        = "192.168.20.115"
    master_2_subnet    = "255.255.255.0"
    master_2_gateway   = "192.168.20.254"
    master_2_interface = "ens192"
    dns                = "192.168.40.10"
    master_2_server_id = ""
  }
}
#### Worker Nodes - Network Options
variable "worker_network_config" {
  type = map(any)
  default = {
    worker_0_type      = "static"
    worker_0_ip        = "192.168.20.116"
    worker_0_subnet    = "255.255.255.0"
    worker_0_gateway   = "192.168.20.254"
    worker_0_interface = "ens192"
    dns                = "192.168.40.10"
    worker_0_server_id = ""

    worker_1_type      = "static"
    worker_1_ip        = "192.168.20.117"
    worker_1_subnet    = "255.255.255.0"
    worker_1_gateway   = "192.168.20.254"
    worker_1_interface = "ens192"
    dns                = "192.168.40.10"
    worker_1_server_id = ""

    worker_2_type      = "static"
    worker_2_ip        = "192.168.20.119"
    worker_2_subnet    = "255.255.255.0"
    worker_2_gateway   = "192.168.20.254"
    worker_2_interface = "ens192"
    dns                = "192.168.40.10"
    worker_2_server_id = ""
  }
}