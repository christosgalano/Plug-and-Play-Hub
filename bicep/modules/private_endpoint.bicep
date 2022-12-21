/// Parameters ///

@description('Name of the private endpoint')
param name string

@description('Location of the private endpoint')
param location string

@description('ID of the subnet where the private endpoint will reside')
param subnet_id string

@description('The ID(s) of the group(s) obtained from the remote resource that this private endpoint should connect to')
param group_ids array

@description('The resource id of private link service')
param private_link_service_id string

/// Resources ///

resource pep 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: name
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          groupIds: group_ids
          privateLinkServiceId: private_link_service_id
        }
      }
    ]
    subnet: {
      id: subnet_id
    }
  }
}

/// Outputs ///

output pep_id string = pep.id
output pep_name string = pep.name
