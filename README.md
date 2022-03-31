# Deploy-OCP-4.7-Terraform-vCenter-Automated
Deploy OCP 4.7 UPI - Terraform - vCenter 6.7

Hardware Components:
3 x ESXi Hosts

Software:
1. Ubuntu Bastion/Jump Station 20.04
2. Terraform v1.1.7
3. vCenter 6.7U3
4. GOVC
5. OCP 4.7.4
6. OCP Client and Installation tools
7. Windows 2019 DNS Server

Preparation of Environment:

DNS Prep:
1. Add your cluster domain, ex "demo" as a sub-domain to your base-domain. Base domain would be yourdomain.com. With cluster domain, it would be demo.yourdomain.com

2. Add DNS A and PTR records for the bootstrap, 3 control planes and 3 worker nodes to your demo sub-domain. 
![dns](https://user-images.githubusercontent.com/92060430/159207593-45a59c6f-1419-4825-aee5-432a15b8c37b.JPG)

3. Add DNS A record only for the 3 etcd database, no PTR is required.
![dns1](https://user-images.githubusercontent.com/92060430/159207627-438e6ef0-2a0e-48c2-ac39-eee4daf76d0e.JPG)
![dns2](https://user-images.githubusercontent.com/92060430/159207635-7b25c7df-e7c8-4906-9dff-8be48389c272.JPG)


Bastion/Jump Station Prep:
1. Install and update an Ubuntu 20.04 LTS bastion host that you will use for deploying and managing the cluster
2. Create a folder which we will use for the terraform files and the openshift install files, etc
3. mkdir ocp4
4. cd ocp4
5. Download the following to this directory;
   wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.7/openshift-client-linux.tar.gz;
   wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.7/openshift-install-linux.tar.gz;
   wget https://github.com/vmware/govmomi/releases/download/v0.24.0/govc_linux_amd64.gz;
   tar zxvf openshift-client-linux.tar.gz
   tar zxvf openshift-install-linux.tar.gz
   gunzip govc_linux_amd64.gz
   




