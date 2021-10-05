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
```
sudo kubeadm init  --ignore-preflight-errors=all  --pod-network-cidr=10.0.1.0/24
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

## Troubleshooting 

### Azure 
Custom data/cloud init logs
```
/var/log/cloud-init.log
```