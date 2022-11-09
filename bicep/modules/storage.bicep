// Parameters

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

@description('ID of the virtual network to which the private dns zone will be linked')
param vnet_id string

@description('Name of the storage account blob service private endpoint')
param ple_blob_name string

@description('Location of the storage account blob service private endpoint')
param ple_blob_location string

@description('ID of the subnet where the private endpoint will reside')
param ple_subnet_id string

// Variables

var name_cleaned = replace(name, '-', '')
var blob_private_dns_zone_name = 'privatelink.blob.core.windows.net'

// Resources

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

resource blob_private_dns_zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blob_private_dns_zone_name
  location: 'global'
}

resource private_dns_zone_vnet_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blob_private_dns_zone
  name: 'private-dns-zone-vnet-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet_id
    }
  }
}

resource ple_blob 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: ple_blob_name
  location: ple_blob_location
  properties: {
    privateLinkServiceConnections: [
      {
        name: ple_blob_name
        properties: {
          groupIds: [
            'blob'
          ]
          privateLinkServiceId: storage.id
        }
      }
    ]
    subnet: {
      id: ple_subnet_id
    }
  }
}

resource blob_private_dns_zone_group 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  parent: ple_blob
  name: 'st-blob-private-dns-zone-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'st-blob-private-dns-zone-config'
        properties: {
          privateDnsZoneId: blob_private_dns_zone.id
        }
      }
    ]
  }
}

// Outputs

output storage_id string = storage.id
output storage_name string = storage.name
