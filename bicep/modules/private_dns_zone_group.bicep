// Creates a Private DNS Zone Group

/// Parameters ///

@description('Name of the Private Endpoint')
param pep_name string

@description('ID of the Private DNS Zone')
param private_dns_zone_id string

@description('Name of the Private DNS Zone Group')
param private_dns_zone_group_name string

/// Resources ///

resource pep 'Microsoft.Network/privateEndpoints@2022-05-01' existing = {
  name: pep_name
}

resource private_dns_zone_group 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  parent: pep
  name: private_dns_zone_group_name
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${private_dns_zone_group_name}-config'
        properties: {
          privateDnsZoneId: private_dns_zone_id
        }
      }
    ]
  }
}
