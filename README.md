# no-cost-multi-cloud-k8s-control-plane
This project is a fun try to get real value from free tiers available on most popular cloud provider platforms. The aim is to provision highly available k8s control plane using free tier cloud providers VMs. Following successful attempt, plan is to setup worker groups using Spot instances in both Azure in AWS.

Built using Terraform and Terraform modules and leveraging Azure and AWS. 
List of external content used within this project:
- https://registry.terraform.io/modules/Azure/compute/azurerm/latest
- https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
- https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

## VM/EC2 ssh logging
SSH key is configured to use `~/.ssh/id_rsa.pub` as default, but it can be overriden if nessecary.

For ease of use I'd recommend to update  `~/.ssh/config` with the following content (get your IPs by running `terraform output`)
```
Host azurevm
        HostName 137.117.136.xx
        User azureuser
        Port 22
        IdentityFile ~/.ssh/id_rsa

Host ec2vm
        HostName 52.214.202.xx
        User ubuntu
        Port 22
        IdentityFile ~/.ssh/id_rsa
```
and then ssh using `ssh azurevm` or `ssh ec2vm`

## Controle Plane setup
1. Ssh to Azure VM with `ssh azurevm`
2. Update hostname with `sudo hostname k8s-control-plane-dev.westeurope.cloudapp.azure.com` (to be added to to custom data with template_file)
3. Update kubelet cgroup driver to match docker (to be addedd to custom/user data)
```
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"
EOF
```
4. Initiate cluster with `kubeadm init`
```
sudo kubeadm init --control-plane-endpoint k8s-control-plane-dev.westeurope.cloudapp.azure.com \
 --ignore-preflight-errors=all \
 --upload-certs \
 --pod-network-cidr=10.0.1.0/24
```
5. Ssh onto another node with `ssh ec2vm` and pull down required certs
```
sudo kubeadm join phase control-plane-prepare download-certs <args from step 4. output>
```
6. Join new node to cluster control plane with command shown in output of step 4.
```
sudo kubeadm join k8s-control-plane-dev.westeurope.cloudapp.azure.com:6443 --token <args from step 4. output>
```

## Cloud authentication
### Azure

```
az login
az account list
# select id of subscription you want to use or if only single subscription exists then
az account set --subscription=$(az account list | jq -r '.[0].id')
```

### AWS
```
aws configure 
```

### Terraform deployment 
```
terraform init
terraform plan
terraform destroy
```

## Troubleshooting 

### Azure 
Custom data/cloud init logs
```
/var/log/cloud-init.log
```

### k8s
```
kubectl -n kube-system get cm kubeadm-config -o yaml
kubectl cluster-info dump
```