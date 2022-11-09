// Parameters

@description('Name of the log analytics workspace')
param name string

@description('Location of the log analytics workspace')
param location string

@description('SKU of the log analytics workspace')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param sku string

@description('The workspace data retention in days')
param retention_days int

@description('The workspace daily quota for ingestion')
param daily_quota_gb int

@description('Enable diagnostic settings for this resource')
param diagnostics_settings_enabled bool

// Resources

resource log_workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retention_days
    workspaceCapping: {
      dailyQuotaGb: daily_quota_gb
    }
  }
}

resource log_workspace_diagnostics_settings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (diagnostics_settings_enabled) {
  name: '${name}-ds'
  scope: log_workspace
  properties: {
    workspaceId: log_workspace.id
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

output log_workspace_id string = log_workspace.id
