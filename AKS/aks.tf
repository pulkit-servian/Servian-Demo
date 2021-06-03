resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.halc_aks.location
  resource_group_name = azurerm_resource_group.halc_aks.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.halc_aks.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.1.240.0/23"]
}

#Creating a 2 node AKS cluster and an AKS managed identity inside the resource group  
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-cluster"
  location            = var.location
  resource_group_name = azurerm_resource_group.halc_aks.name
  dns_prefix          = var.dns_prefix

  network_profile {
    network_plugin = "azure"
  }

  default_node_pool {
    name           = "default"
    node_count     = var.agent_count
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Lab"
  }
}
