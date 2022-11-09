// Parameters

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

@description('ID of the virtual network to which the private dns zone will be linked')
param vnet_id string

@description('Name of the Key Vault private endpoint')
param ple_name string

@description('Location of the Key Vault private endpoint')
param ple_location string

@description('ID of the subnet where the private endpoint will reside')
param ple_subnet_id string

// Variables

var private_dns_zone_name = 'privatelink.vaultcore.azure.net'

// Resources

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
    enablePurgeProtection: purge_protection_enabled

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

resource private_dns_zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: private_dns_zone_name
  location: 'global'
}

resource private_dns_zone_vnet_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: private_dns_zone
  name: 'private-dns-zone-vnet-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet_id
    }
  }
}

resource ple_kv 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: ple_name
  location: ple_location
  properties: {
    privateLinkServiceConnections: [
      {
        name: ple_name
        properties: {
          groupIds: [
            'vault'
          ]
          privateLinkServiceId: keyvault.id
        }
      }
    ]
    subnet: {
      id: ple_subnet_id
    }
  }
}

resource private_dns_zone_group 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  parent: ple_kv
  name: 'vault-private-dns-zone-group'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'vault-private-dns-zone-config'
        properties: {
          privateDnsZoneId: private_dns_zone.id
        }
      }
    ]
  }
}

// Outputs

output keyvault_id string = keyvault.id
