/// Parameters ///

@description('Name of the virtual network')
param vnet_name string

@description('Location of the virtual network')
param vnet_location string

@description('Address space of the virtual network')
param vnet_address_space array

@allowed([
  'AzureBastionSubnet'
])
@description('Name of the subnet where the Bastion will reside')
param snet_bastion_name string

@description('Address space of the subnet where the Bastion will reside')
param snet_bastion_address_prefix string

@allowed([
  'AzureFirewallSubnet'
])
@description('Name of the subnet where the Firewall will reside')
param snet_firewall_name string

@description('Address space of the subnet where the Firewall will reside')
param snet_firewall_address_prefix string

@allowed([
  'GatewaySubnet'
])
@description('Name of the subnet where the Virtual Network Gateway will reside')
param snet_gateway_name string

@description('Address space of the subnet where the Virtual Network Gateway will reside')
param snet_gateway_address_prefix string

@description('Name of the inbound endpoint subnet')
param snet_inbound_endpoint_name string

@description('Address space of the inbound endpoint subnet')
param snet_inbound_endpoint_address_prefix string

@description('Name of the outbound endpoint subnet')
param snet_outbound_endpoint_name string

@description('Address space of the outbound endpoint subnet')
param snet_outbound_endpoint_address_prefix string

@description('Name of the subnet where the shared services will reside')
param snet_shared_name string

@description('Address space of the subnet where the shared services will reside')
param snet_shared_address_prefix string

@description('The ID of the workspace to be used for the NSG diagnostic settings')
param log_workspace_id string

@description('Enable diagnostic settings for this resource')
param diagnostics_settings_enabled bool

/// Resources ///

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: vnet_name
  location: vnet_location
  properties: {
    addressSpace: {
      addressPrefixes: vnet_address_space
    }
    subnets: [
      {
        name: snet_bastion_name
        properties: {
          addressPrefix: snet_bastion_address_prefix
        }
      }
      {
        name: snet_firewall_name
        properties: {
          addressPrefix: snet_firewall_address_prefix
        }
      }
      {
        name: snet_gateway_name
        properties: {
          addressPrefix: snet_gateway_address_prefix
        }
      }
      {
        name: snet_inbound_endpoint_name
        properties: {
          addressPrefix: snet_inbound_endpoint_address_prefix
        }
      }
      {
        name: snet_outbound_endpoint_name
        properties: {
          addressPrefix: snet_outbound_endpoint_address_prefix
        }
      }
      {
        name: snet_shared_name
        properties: {
          addressPrefix: snet_shared_address_prefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource vnet_diagnostics_settings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (diagnostics_settings_enabled) {
  name: '${vnet_name}-ds'
  scope: vnet
  properties: {
    workspaceId: log_workspace_id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

/// Outputs ///

output vnet_id string = vnet.id
output vnet_name string = vnet.name
output snet_bastion_id string = vnet.properties.subnets[0].id
output snet_firewall_id string = vnet.properties.subnets[1].id
output snet_gateway_id string = vnet.properties.subnets[2].id
output snet_inbound_id string = vnet.properties.subnets[3].id
output snet_outbound_id string = vnet.properties.subnets[4].id
output snet_shared_id string = vnet.properties.subnets[5].id
