# no-cost-multi-cloud-k8s-control-plane
k8s control plane using free tier cloud providers VMs. Built using Terraform and Terraform modules and levergaing Azure and AWS.
List of content 
- https://registry.terraform.io/modules/Azure/compute/azurerm/latest
- https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
- https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

## VM/EC2 ssh logging
SSH key is configured to use `~/.ssh/id_rsa.pub` as default, but it can be overriden if nessecary.

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