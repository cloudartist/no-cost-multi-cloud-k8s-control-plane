# no-cost-multi-cloud-k8s-control-plane
k8s control plane using free tier cloud providers VMs

# Cloud auth
## Azure

```
az login
az account list
# or if only single subscription then
az account set --subscription=$(az account list | jq -r '.[0].id')
```

## AWS