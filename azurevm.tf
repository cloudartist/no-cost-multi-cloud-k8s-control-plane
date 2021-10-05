resource "azurerm_resource_group" "k8s" {
  name     = "k8s-control-plane"
  location = "West Europe"
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.k8s.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["subnet1"]

  depends_on = [azurerm_resource_group.k8s]
}

module "linuxservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.k8s.name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["k8s-control-plane-dev"] // change to a unique name per datacenter region
  vnet_subnet_id      = module.network.vnet_subnets[0]
  vm_size             = "Standard_B1s"

  remote_port             = "22"
  source_address_prefixes = ["${data.external.myipaddr.result.ip}/32"]
  enable_ssh_key          = true

  custom_data = filebase64("${path.module}/files/k8s-cluster-install.sh")

  depends_on = [azurerm_resource_group.k8s]
}


