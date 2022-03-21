provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}


# Data Sources
data "vsphere_datacenter" "dc" {
  name = "Datacenter" #datacenter name in vCenter
}
data "vsphere_resource_pool" "pool" {
  # If you no defined resource pool, put "Resources" after vCenter cluster name
  name          = "vCenter Cluster Name/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore" "datastore" {
  name          = "your default datastore"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "vCenter Cluster Name"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name = var.vsphere_net
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# this is your esxi host in your cluster passed from variables
data "vsphere_host" "host" { 
  name          = var.vm_esxi_host
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "coreostemplate1" {
  depends_on    = [vsphere_virtual_machine.coreostemplate1]
  name          = "coreostemplate1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

 ###coreostemplate1###
 resource "vsphere_virtual_machine" "coreostemplate1" {
   name             = "coreostemplate1"
   resource_pool_id = data.vsphere_resource_pool.pool.id
   datastore_id     = data.vsphere_datastore.datastore.id
   datacenter_id    = data.vsphere_datacenter.dc.id
   host_system_id   = data.vsphere_host.host.id
   num_cpus = 2
   memory   = 4096
   guest_id = "coreos64Guest"
   wait_for_guest_net_timeout  = 0
   wait_for_guest_ip_timeout   = 0
   wait_for_guest_net_routable = false
   enable_disk_uuid  = true
   network_interface {
     network_id = data.vsphere_network.network.id
   }

   # you can use remote OVA url or upload from local, you need to comment out the one not in use
   ovf_deploy { 
     remote_ovf_url       = "https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.7/latest/rhcos-vmware.x86_64.ova"
     #local_ovf_path       = "rhcos-vmware.x86_64.ova"
     disk_provisioning    = "thin"
     ovf_network_map = {
       "VM Network" = data.vsphere_network.network.id
   }
  }

  #this will power off the coreostemplate to prevent it from creating a VM
  provisioner "local-exec" {
    command = "govc vm.power -off=true coreostemplate1 && sleep 10"

    environment = {
      GOVC_URL      = var.vsphere_server
      GOVC_USERNAME = var.vsphere_user
      GOVC_PASSWORD = var.vsphere_password
      GOVC_INSECURE = "true"
    }
  }
 }

data "local_file" "bootstrap_vm_ignition" {
  filename   = "/root/ocp4/openshift-install/bootstrap-append.ign"
}

resource "vsphere_virtual_machine" "bootstrapVM" {
  name             = "${var.boot_name}-0" #bootstrap name = bootstrap-0.demo.yourdomain.com
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus         = var.bootstrap_cpu_count
  memory           = var.bootstrap_memory_size
  guest_id         = "coreos64Guest"
  enable_disk_uuid = "true"

  wait_for_guest_net_timeout  = 0
  wait_for_guest_net_routable = false

  scsi_type = data.vsphere_virtual_machine.coreostemplate1.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.coreostemplate1.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.bootstrap_disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.coreostemplate1.disks.0.eagerly_scrub
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.coreostemplate1.id
  }

  extra_config = {
    "guestinfo.ignition.config.data"           = base64encode(data.local_file.bootstrap_vm_ignition.content)
    "guestinfo.ignition.config.data.encoding"  = "base64"
    "guestinfo.hostname"                       = "${var.boot_name}-0"
    "guestinfo.afterburn.initrd.network-kargs" = lookup(var.bootstrap_vm_network_config, "type") != "dhcp" ? "ip=${lookup(var.bootstrap_vm_network_config, "ip")}:${lookup(var.bootstrap_vm_network_config, "server_id")}:${lookup(var.bootstrap_vm_network_config, "gateway")}:${lookup(var.bootstrap_vm_network_config, "subnet")}:${var.boot_name}-0:${lookup(var.bootstrap_vm_network_config, "interface")}:off nameserver=${lookup(var.bootstrap_vm_network_config, "dns")}" : "ip=::::${var.boot_name}-0:ens192:on"
  }
}
####Masters###
data "local_file" "master_vm_ignition" {
  filename   = "/root/ocp4/openshift-install/master.ign"
}
resource "vsphere_virtual_machine" "masterVMs" {
  depends_on = [vsphere_virtual_machine.bootstrapVM]
  count      = var.master_count #number of masters from variable, in this case, 3, master0, master1, master2

  name             = "${var.cp_name}-master${count.index}" #the count starts at 0,so master0, master1, master2
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus         = var.master_cpu_count
  memory           = var.master_memory_size
  guest_id         = "coreos64Guest"
  enable_disk_uuid = "true"

  wait_for_guest_net_timeout  = 0
  wait_for_guest_net_routable = false

  scsi_type = data.vsphere_virtual_machine.coreostemplate1.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.coreostemplate1.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.master_disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.coreostemplate1.disks.0.eagerly_scrub
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.coreostemplate1.id
  }

  extra_config = {
    "guestinfo.ignition.config.data"           = base64encode(data.local_file.master_vm_ignition.content)
    "guestinfo.ignition.config.data.encoding"  = "base64"
    "guestinfo.hostname"                       = "${var.cp_name}-master${count.index}"
    "guestinfo.afterburn.initrd.network-kargs" = lookup(var.master_network_config, "master_${count.index}_type") != "dhcp" ? "ip=${lookup(var.master_network_config, "master_${count.index}_ip")}:${lookup(var.master_network_config, "master_${count.index}_server_id")}:${lookup(var.master_network_config, "master_${count.index}_gateway")}:${lookup(var.master_network_config, "master_${count.index}_subnet")}:${var.cp_name}-master${count.index}:${lookup(var.master_network_config, "master_${count.index}_interface")}:off nameserver=${lookup(var.bootstrap_vm_network_config, "dns")}" : "ip=::::${var.cp_name}-master${count.index}:ens192:on"
  }
}


####Workers###
data "local_file" "worker_vm_ignition" {
  filename   = "/root/ocp4/openshift-install/worker.ign"
}
resource "vsphere_virtual_machine" "workerVMs" {
  depends_on = [vsphere_virtual_machine.masterVMs]
  count      = var.worker_count #number of workers from variable, in this case, 3, work0, work1, work2

  name             = "${var.wrk_name}-worker${count.index}" #the count starts at 0,so work0, work1, work2
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus         = var.worker_cpu_count
  memory           = var.worker_memory_size
  guest_id         = "coreos64Guest"
  enable_disk_uuid = "true"

  wait_for_guest_net_timeout  = 0
  wait_for_guest_net_routable = false

  scsi_type = data.vsphere_virtual_machine.coreostemplate1.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.coreostemplate1.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.worker_disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.coreostemplate1.disks.0.eagerly_scrub
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.coreostemplate1.id
  }

  extra_config = {
    "guestinfo.ignition.config.data"           = base64encode(data.local_file.worker_vm_ignition.content)
    "guestinfo.ignition.config.data.encoding"  = "base64"
    "guestinfo.hostname"                       = "${var.wrk_name}-worker${count.index}"
    "guestinfo.afterburn.initrd.network-kargs" = lookup(var.worker_network_config, "${count.index}_type") != "dhcp" ? "ip=${lookup(var.worker_network_config, "worker_${count.index}_ip")}:${lookup(var.worker_network_config, "worker_${count.index}_server_id")}:${lookup(var.worker_network_config, "worker_${count.index}_gateway")}:${lookup(var.worker_network_config, "worker_${count.index}_subnet")}:${var.wrk_name}-worker${count.index}:${lookup(var.worker_network_config, "worker_${count.index}_interface")}:off nameserver=${lookup(var.bootstrap_vm_network_config, "dns")}" : "ip=::::${var.wrk_name}-work${count.index}:ens192:on"
  }
}