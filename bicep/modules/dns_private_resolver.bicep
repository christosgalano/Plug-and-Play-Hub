// Parameters

@description('Name of the resolver')
param name string

@description('Location of the resolver')
param location string

@description('ID of the vnet')
param vnet_id string

@description('ID of the inbound endpoint subnet')
param inbound_snet_id string

@description('ID of the outbound endpoint subnet')
param outbound_snet_id string

@description('Name of the inbound endpoint')
param inbound_endpoint_name string

@description('Name of the outbound endpoint')
param outbound_endpoint_name string

@description('Name of the forwarding ruleset')
param forwarding_ruleset_name string

// Resources

resource resolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: name
  location: location
  properties: {
    virtualNetwork: {
      id: vnet_id
    }
  }
}

resource inbound_endpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  parent: resolver
  name: inbound_endpoint_name
  location: location
  properties: {
    ipConfigurations: [
      {
        privateIpAllocationMethod: 'Dynamic'
        subnet: {
          id: inbound_snet_id
        }
      }
    ]
  }
}

resource outbound_endpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2022-07-01' = {
  parent: resolver
  name: outbound_endpoint_name
  location: location
  properties: {
    subnet: {
      id: outbound_snet_id
    }
  }
}

resource forwarding_ruleset 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: forwarding_ruleset_name
  location: location
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: outbound_endpoint.id
      }
    ]
  }
}

resource resolver_vnet_link 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2022-07-01' = {
  parent: forwarding_ruleset
  name: 'dns-private-resolver-vnet-link'
  properties: {
    virtualNetwork: {
      id: vnet_id
    }
  }
}

// Outputs

output resolver_id string = resolver.id
