/// Parameters ///

@description('Name of the Private DNS Zone')
param private_dns_zone_name string

@description('IDs of the virtual networks to be linked with this Private DNS Zone')
param vnet_ids array

@description('Names of the virtual networks to be linked with this Private DNS Zone')
param vnet_names array

/// Resources ///

resource private_dns_zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: private_dns_zone_name
  location: 'global'
}

resource private_dns_zone_vnet_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for i in range(0, length(vnet_ids)): {
  parent: private_dns_zone
  name: 'private-dns-vnet-link-${vnet_names[i]}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet_ids[i]
    }
  }
}]

/// Outputs ///

output zone_id string = private_dns_zone.id
