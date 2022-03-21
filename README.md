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

2. Add DNS A and PTR records for the bootstrap, 3 control planes and 3 worker nodes to your demo sub-domain. See screen shot

3. Add DNS A record only for the 3 etcd database, no PTR is required. See screen shot

Bastion/Jump Station Prep:
1. Install and update an Ubuntu 20.04 LTS bastion host that you will use for deploying and managing the cluster
2. sudo mkdir ocp4 # we will use this for the terraform folder and the openshift install files, etc
   chmod 777 ocp4
3. cd ocp4
4. 



