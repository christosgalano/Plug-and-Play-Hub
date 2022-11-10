// Parameters

@description('Name of the Firewall')
param name string

@description('Location of the Firewall')
param location string

// @allowed([
//   'AZFW_Hub'
//   'AZFW_VNet'
// ])
// @description('SKU name of the Firewall')
// param sku_name string

@allowed([
  'Basic'
  'Premium'
  'Standard'
])
@description('SKU name of the Firewall')
param sku_tier string

@allowed([
  'Off'
  'Deny'
  'Alert'
])
@description('The operation mode for Threat Intelligence')
param threat_intel_mode string

@description('A list of availability zones denoting the IP allocated for the resource needs to come from')
param availability_zones array

@description('The ID of the subnet the Firewall will be deployed into')
param snet_id string

@description('The ID of the public ip to be used for the Firewall')
param pip_id string

@description('The ID of the workspace to be used for the Firewall diagnostic settings')
param log_workspace_id string

@description('Enable diagnostic settings for this resource')
param diagnostics_settings_enabled bool

// Resources

resource firewall 'Microsoft.Network/azureFirewalls@2022-05-01' = {
  name: name
  location: location
  zones: ((length(availability_zones) == 0) ? json('null') : availability_zones)
  properties: {
    sku: {
      tier: sku_tier
    }
    threatIntelMode: threat_intel_mode
    ipConfigurations: [
      {
        name: 'firewall-ip-configuration'
        properties: {
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

resource firewall_diagnostic_settings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (diagnostics_settings_enabled) {
  name: '${name}-ds'
  scope: firewall
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

// Outputs

output firewall_id string = firewall.id
