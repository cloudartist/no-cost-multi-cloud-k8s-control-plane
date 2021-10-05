output "azure_public_ip" {
  value = module.linuxservers.public_ip_address[0]
}

output "azure_public_ip_dns_name" {
  value = module.linuxservers.public_ip_dns_name[0]
}

output "aws_public_ip" {
  value = module.ec2_instance.public_ip
}
