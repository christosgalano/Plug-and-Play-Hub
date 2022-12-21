/// Parameters ///

@description('Name of the public ip')
param name string

@description('Location of the public ip')
param location string

@allowed([
  'Basic'
  'Standard'
])
@description('SKU name of the public ip')
param sku_name string

@allowed([
  'Static'
  'Dynamic'
])
@description('Allocation method of the public ip')
param allocation_method string

@description('A list of availability zones denoting the IP allocated for the resource needs to come from')
param availability_zones array

@description('The ID of the workspace to be used for the public ip diagnostic settings')
param log_workspace_id string

@description('Enable diagnostic settings for this resource')
param diagnostics_settings_enabled bool

/// Resources ///

resource pip 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: name
  location: location
  sku: {
    name: sku_name
  }
  properties: {
    publicIPAllocationMethod: allocation_method
  }
  zones: ((length(availability_zones) == 0) ? json('null') : availability_zones)
}

resource pip_diagnostics_settings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (diagnostics_settings_enabled) {
  name: '${name}-ds'
  scope: pip
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

output pip_id string = pip.id
output ip_address string = pip.properties.ipAddress
