/// Parameters ///

@description('Name of the storage account')
param name string

@description('Location of the storage account')
param location string

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])

@description('SKU of the storage account')
param sku string

@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
@description('Kind of the storage account')
param kind string

@allowed([
  'Hot'
  'Cool'
])
@description('Tier of the storage account')
param access_tier string

@description('Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key')
param allow_shared_key_access bool

@description('Specifies whether to allow or disallow public access to all blobs or containers in the storage account')
param allow_blob_public_access bool

@description('Specifies whether to enforce HTTPS')
param enable_https_traffic_only bool

@description('Specifies whether to allow or disallow cross AAD tenant object replication')
param allow_cross_tenant_replication bool

/// Variables ///

var name_cleaned = replace(name, '-', '')

/// Resources ///

resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: name_cleaned
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    accessTier: access_tier

    allowSharedKeyAccess: allow_shared_key_access
    allowBlobPublicAccess: allow_blob_public_access
    supportsHttpsTrafficOnly: enable_https_traffic_only
    allowCrossTenantReplication: allow_cross_tenant_replication

    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

/// Outputs ///

output storage_id string = storage.id
output storage_name string = storage.name
