/// Parameters ///

@description('Name of the Network Security Group')
param name string

@description('Location of the Network Security Group')
param location string

@description('Security rules of the Network Security Group')
param security_rules array

/// Resources ///

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: name
  location: location
  properties: {
    securityRules: security_rules
  }
}

/// Outputs ///

output nsg_id string = nsg.id
