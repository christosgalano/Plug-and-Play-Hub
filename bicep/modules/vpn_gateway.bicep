/// Parameters ///

@description('Name of the Virtual Network Gateway')
param name string

@description('Location of the Virtual Network Gateway')
param location string

@description('SKU name of the Virtual Network Gateway')
param sku_name string

@description('SKU tier of the Virtual Network Gateway')
param sku_tier string

@description('The type of this Virtual Network Gateway')
@allowed([
  'Vpn'
])
param gateway_type string

@description('The type of this Virtual Network Gateway')
@allowed([
  'RouteBased'
  'PolicyBased'
])
param vpn_type string

@description('The generation for this Virtual Network Gateway')
@allowed([
  'Generation1'
  'Generation2'
])
param vpn_gateway_generation string

@allowed([
  'Static'
  'Dynamic'
])
@description('Allocation method of the private ip')
param private_ip_allocation_method string

@description('The ID of the subnet the Virtual Network Gateway will be deployed into')
param snet_id string

@description('The ID of the public ip to be used for the Virtual Network Gateway')
param pip_id string

@description('ActiveActive flag.')
param active_active bool

@description('The ID of the workspace to be used for the Virtual Network Gateway diagnostic settings')
param log_workspace_id string

@description('Enable diagnostic settings for this resource')
param diagnostics_settings_enabled bool

/// Resources ///

resource vpn_gateway 'Microsoft.Network/virtualNetworkGateways@2022-05-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: sku_name
      tier: sku_tier
    }
    gatewayType: gateway_type
    vpnType: vpn_type
    vpnGatewayGeneration: vpn_gateway_generation
    activeActive: active_active
    ipConfigurations: [
      {
        name: 'vpn-gateway-ip-configuration'
        properties: {
          privateIPAllocationMethod: private_ip_allocation_method
          subnet: {
            id: snet_id
          }
          publicIPAddress: {
            id: pip_id
          }
        }
      }
    ]
  }
}

resource vpn_gateway_diagnostic_settings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (diagnostics_settings_enabled) {
  name: '${name}-ds'
  scope: vpn_gateway
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

output vpn_gateway_id string = vpn_gateway.id
