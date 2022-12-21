/// Parameters ///

@description('Name of the Network Security Group')
param name string

@description('Location of the Network Security Group')
param location string

@description('Security rules of the Network Security Group')
param security_rules array

@description('The ID of the workspace to be used for the Keyvault diagnostic settings')
param log_workspace_id string

@description('Enable diagnostic settings for this resource')
param diagnostics_settings_enabled bool

/// Resources ///

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: name
  location: location
  properties: {
    securityRules: security_rules
  }
}

resource nsg_diagnostic_settings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (diagnostics_settings_enabled) {
  name: '${name}-ds'
  scope: nsg
  properties: {
    workspaceId: log_workspace_id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

/// Outputs ///

output nsg_id string = nsg.id
