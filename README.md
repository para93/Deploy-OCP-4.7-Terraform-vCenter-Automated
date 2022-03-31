# Deploy-OCP-4.7-Terraform-vCenter-Automated
Deploy OCP 4.7 UPI - Terraform - vCenter 6.7

### Hardware Components:
    3 x ESXi Hosts

### Software:
    1. Ubuntu Bastion/Jump Station 20.04
    2. Terraform v1.1.7
    3. vCenter 6.7U3
    4. GOVC
    5. OCP 4.7.4
    6. OCP Client and Installation tools
    7. Windows 2019 DNS Server

### Preparation of Environment:

### DNS Prep:
1. Add your cluster domain, ex "demo" as a sub-domain to your base-domain. Base domain would be yourdomain.com. With cluster domain, it would be demo.yourdomain.com

2. Add DNS A and PTR records for the bootstrap, 3 control planes and 3 worker nodes to your demo sub-domain. 
![dns](https://user-images.githubusercontent.com/92060430/159207593-45a59c6f-1419-4825-aee5-432a15b8c37b.JPG)

3. Add DNS A record only for the 3 etcd database, no PTR is required.
![dns1](https://user-images.githubusercontent.com/92060430/159207627-438e6ef0-2a0e-48c2-ac39-eee4daf76d0e.JPG)
![dns2](https://user-images.githubusercontent.com/92060430/159207635-7b25c7df-e7c8-4906-9dff-8be48389c272.JPG)


### Bastion/Jump Station Prep:
1. Install and update an Ubuntu 20.04 LTS bastion host that you will use for deploying and managing the cluster
2. Create a folder which we will use for the terraform files and the openshift install files, etc
3. mkdir ocp4
4. cd ocp4
5. Download the following to this directory;
   \
   wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.7/openshift-client-linux.tar.gz
   \
   wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.7/openshift-install-linux.tar.gz
   \
   wget https://github.com/vmware/govmomi/releases/download/v0.24.0/govc_linux_amd64.gz
   \
   tar zxvf openshift-client-linux.tar.gz
   \
   tar zxvf openshift-install-linux.tar.gz
   \
   mv openshift-install /usr/local/bin
   \
   gunzip govc_linux_amd64.gz
   \
   mv govc /usr/local/bin
   \
   chmod 777 /usr/local/bin/govc #you might run into permission denied
   
### Apt users can add the repository with:
   
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   \
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   
### Install Terraform
    
    #apt install terraform -y
   
### Install, Configure HAProxy and Apache2
    
    #apt install haproxy
    Because HAPrpxy will bind to multiple ports for Frontend services, we need to install SELinus policy and change SElinux to disable
    #apt-get install policycoreutils
    #vi /etc/selinux/config
    #sestatus #should be disabled
    #systemctl status haproxy #should show active
    
    #apt install apache2
    Change default listening port on Apache2 from 80 to 8080 because HAProxy is already listening on port 80
    #vi /etc/apache2/ports.conf
    #systemctl restart apache2
    #systemctl status apache2 #should show active
    #mkdir -p  /var/www/html/ignition
    
    Note: you can disable Ubuntu firewall service
    #ufw disable
    #ufw status
    
    Check to see that Ubuntu is listening on TCP ports 6443, 22623, 443, 80 and 8080
    #netstat -nltupe
    
 ### Generate SSH keys and configure Ubuntu to trust vCenter certificate
 
    Generate SSH keys and add to agent for passwordless login
    #ssh-keygen #accept the default name and location
    #eval "$(ssh-agent -s)"
    #ssh-add ~/.ssh/id_rsa
    
    Certificate # https://kb.vmware.com/s/article/2108294 #
    The installation program requires access to your vCenter’s API, you must add your vCenter’s trusted root CA certificates to your system trust before you install an OpenShift Container Platform cluster.
    1. From vCenter, download the root certificate, unzip and change the cert with .0 file extension to .crt
    2. #mkdir /usr/share/ca-certificates/extra
    3. copy the .crt to /usr/share/ca-certificates/extra using WINSCP
    4. #dpkg-reconfigure ca-certificates #select the cert you just copied and follow the wizard to approve
    
 ### OCP Pull Secret
 
    1. Logon to console.redhat.com with your account and copy the pull secret from the Infrastructure Provider page
    https://console.redhat.com/openshift/install/vsphere/user-provisioned
    2. copy the pull secret as a json file to the ocp4 directory you created earlier.
    
 ### Recap before we start the preparation of Automation using Terraform
 
    1. Connfigure DNS
    2. Download and extract OCP Client and Installer tools to ocp4 drirectory
    3. Add GOVC and repo for Ubuntu APT users from Hashicorp
    4. Install latest Terraform
    4. Install and configure HAProxy and Apache2
    5. Generate SSH keys and vCenter root CA
    6. Copy Pull Secret from Redhat
    
 ### Automating with Terraform
 
    We need to export the environment variables as per the included file in the file directory
    
    Customize the following as per your environment, install-config.yaml, variables.tf and main.tf
    
    Copy main.tf and variables.tf to ocp4 directory you created earlier
    
    mkdir ${MYPATH}/openshift-install
    mkdir ~/.kube
    cp install-config.yaml ${MYPATH}/openshift-install/install-config.yaml
    
    #### Creating boostrap ignition file ####
    cat > ${MYPATH}/openshift-install/bootstrap-append.ign <<EOF
    {
       "ignition": {
         "config": {
           "merge": [
           {
             "source": "http://${HTTP_SERVER}:8080/ignition/bootstrap.ign"
           }
           ]
         },
       "version": "3.1.0"
      }
    }
    EOF
    
    #### Creating master and worker ignition files ####
    openshift-install create ignition-configs --dir  openshift-install --log-level debug
    cp ${MYPATH}/openshift-install/*.ign /var/www/html/ignition/
    chmod o+r /var/www/html/ignition/*.ign
    restorecon -vR /var/www/html/
    cp ${MYPATH}/openshift-install/auth/kubeconfig ~/.kube/config
    
    TEST Access to the bootrap ignition file in the ignition directory
    http://192.168.20.112:8080/ignition/bootstrap.ign
    
 ### Creating the cluster
 
    From the ocp4 directory
    
    terraform init
    terraform plan
    terraform apply -auto-approve
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
 
    
    
    
    
   



