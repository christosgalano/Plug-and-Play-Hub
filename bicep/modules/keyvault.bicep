/// Parameters ///

@minLength(3)
@maxLength(24)
@description('Name of the Key Vault')
param name string

@description('Location of the Key Vault')
param location string

@allowed([
  'premium'
  'standard'
])
@description('SKU name of the Key Vault')
param sku_name string

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from this Key Vault')
param enabled_for_template_deployment bool

@description('Specifies whether Purge Protection is enabled for this Key Vault')
param purge_protection_enabled bool

@description('Property to specify whether the soft delete functionality is enabled for this Key Vault')
param soft_delete_enabled bool

@description('The ID of the workspace to be used for the Keyvault diagnostic settings')
param log_workspace_id string

@description('Enable diagnostic settings for this resource')
param diagnostics_settings_enabled bool

/// Resources ///

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: sku_name
    }
    tenantId: subscription().tenantId

    enabledForTemplateDeployment: enabled_for_template_deployment
    enablePurgeProtection: purge_protection_enabled ? true : null

    enableSoftDelete: soft_delete_enabled

    networkAcls: {
      bypass: enabled_for_template_deployment ? 'AzureServices' : 'None'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }

    accessPolicies: []
  }
}

resource keyvault_diagnostic_settings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (diagnostics_settings_enabled) {
  name: '${name}-ds'
  scope: keyvault
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

output keyvault_id string = keyvault.id
