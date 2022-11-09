// Parameters

@description('Name of the Bastion')
param name string

@description('Location of the Bastion')
param location string

@allowed([
  'Basic'
  'Standard'
])
@description('SKU name of the Bastion')
param sku_name string

@allowed([
  'Static'
  'Dynamic'
])
@description('Allocation method of the private ip')
param private_ip_allocation_method string

@description('The ID of the subnet the Bastion will be deployed into')
param snet_id string

@description('The ID of the public ip to be used for the Bastion')
param pip_id string

@description('The ID of the workspace to be used for the Bastion diagnostic settings')
param log_workspace_id string

@description('Enable diagnostic settings for this resource')
param diagnostics_settings_enabled bool

// Resources

resource bastion 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: name
  location: location
  sku: {
    name: sku_name
  }
  properties: {
    ipConfigurations: [
      {
        name: 'bastion-ip-configuration'
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

resource bastion_diagnostic_settings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (diagnostics_settings_enabled) {
  name: '${name}-ds'
  scope: bastion
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

output bastion_id string = bastion.id
