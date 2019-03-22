provider "azurerm" {
  version = "~>1.6"
}

################################################################################
## Variables
################################################################################
variable "azure_client_id" {}
variable "azure_client_secret" {}

################################################################################
## Outputs
################################################################################
output "acme_resource_group" {
  value = "${azurerm_resource_group.demo.name}"
}

output "acme_cluster_name" {
  value = "${azurerm_kubernetes_cluster.demo.name}"
}

output "acme_cluster_kubeconfig" {
  value = "${azurerm_kubernetes_cluster.demo.kube_config_raw}"
}

################################################################################
## Resources
################################################################################
resource "azurerm_resource_group" "demo" {
  name     = "acme-rg"
  location = "UK South"
}

resource "azurerm_kubernetes_cluster" "demo" {
  name                = "acme-demo"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  dns_prefix          = "anvil"

  kubernetes_version = "1.11.7"

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "${file("id_rsa_acme_k8s_demo.pub")}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "1"
    vm_size         = "Standard_F2s"
    os_type         = "Linux"
    os_disk_size_gb = "30"
  }

  service_principal {
    client_id     = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
  }

  tags {
    environment = "Global"
  }
}
