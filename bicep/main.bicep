/// Parameters ///

@description('Object of the Azure Names module')
param aznames object

@description('name of the resource group where the workload will be deployed')
param rg_name string

@description('Azure region used for the deployment of all resources')
param location string

param application_name string

param environment string

// @description('Default tags to apply to resources')
// param tags object = {}

@description('Availability zone numbers e.g. 1,2,3.')
param availability_zones array = [
  '1'
  '2'
  '3'
]

/// Modules ///

module log_workspace 'modules/log_workspace.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'log-workspace-deployment'
  params: {
    // name: 'log-${project_id}'
    name: aznames.logAnalyticsWorkspace.refName
    location: location
    sku: 'PerGB2018'
    retention_days: 30
    diagnostics_settings_enabled: true
  }
}

module nsg_bastion_subnet 'modules/nsg_bastion_subnet.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'nsg-bastion-subnet-deployment'
  params: {
    // name: 'nsg-bastion-subnet-${project_id}'
    name: aznames.networkSecurityGroup.refName
    location: location

    diagnostics_settings_enabled: true
    log_workspace_id: log_workspace.outputs.log_workspace_id
  }
}

module network 'modules/network.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'network-deployment'
  params: {
    // vnet_name: 'vnet-${project_id}'
    vnet_name: aznames.virtualNetwork.refName
    vnet_location: location
    vnet_address_space: [ '10.1.0.0/22' ]

    snet_bastion_name: 'AzureBastionSubnet'
    snet_bastion_address_prefix: '10.1.2.0/26'
    bastion_subnet_nsg_id: nsg_bastion_subnet.outputs.nsg_id

    snet_firewall_name: 'AzureFirewallSubnet'
    snet_firewall_address_prefix: '10.1.2.64/26'

    snet_gateway_name: 'GatewaySubnet'
    snet_gateway_address_prefix: '10.1.2.128/26'

    snet_inbound_endpoint_name: 'snet-inbound'
    snet_inbound_endpoint_address_prefix: '10.1.0.0/24'

    snet_outbound_endpoint_name: 'snet-outbound'
    snet_outbound_endpoint_address_prefix: '10.1.1.0/24'

    snet_shared_name: 'snet-shared'
    snet_shared_address_prefix: '10.1.2.192/26'

    diagnostics_settings_enabled: true
    log_workspace_id: log_workspace.outputs.log_workspace_id
  }
}

module bastion_pip 'modules/public_ip.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'pip-bastion-deployment'
  params: {
    // name: 'pip-bastion-${project_id}'
    name: aznames.publicIp.refName
    location: location

    sku_name: 'Standard'
    allocation_method: 'Static'

    availability_zones: availability_zones

    diagnostics_settings_enabled: true
    log_workspace_id: log_workspace.outputs.log_workspace_id
  }
}

module bastion 'modules/bastion.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'bastion-deployment'
  params: {
    // name: 'bas-${project_id}'
    name: aznames.bastionHost.refName
    location: location

    sku_name: 'Standard'
    pip_id: bastion_pip.outputs.pip_id

    private_ip_allocation_method: 'Dynamic'
    snet_id: network.outputs.snet_bastion_id

    diagnostics_settings_enabled: true
    log_workspace_id: log_workspace.outputs.log_workspace_id
  }
}

module firewall_pip 'modules/public_ip.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'pip-firewall-deployment'
  params: {
    // name: 'pip-firewall-${project_id}'
    name: aznames.publicIp.refName
    location: location

    sku_name: 'Standard'
    allocation_method: 'Static'

    availability_zones: availability_zones

    diagnostics_settings_enabled: true
    log_workspace_id: log_workspace.outputs.log_workspace_id
  }
}

module firewall 'modules/firewall.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'firewall-deployment'
  params: {
    // name: 'afw-${project_id}'
    name: aznames.firewall.refName
    location: location

    sku_tier: 'Premium'
    availability_zones: availability_zones

    threat_intel_mode: 'Alert'

    pip_id: firewall_pip.outputs.pip_id
    snet_id: network.outputs.snet_firewall_id

    diagnostics_settings_enabled: true
    log_workspace_id: log_workspace.outputs.log_workspace_id
  }
}

module vpn_gateway_pip 'modules/public_ip.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'pip-vpn-gateway-deployment'
  params: {
    // name: 'pip-vpn-gateway-${project_id}'
    name: aznames.publicIp.refName
    location: location

    sku_name: 'Standard'
    allocation_method: 'Static'

    availability_zones: availability_zones

    diagnostics_settings_enabled: true
    log_workspace_id: log_workspace.outputs.log_workspace_id
  }
}

module vpn_gateway 'modules/vpn_gateway.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'vpn-gateway-deployment'
  params: {
    // name: 'vpng-${project_id}'
    name: aznames.virtualNetworkGateway.refName
    location: location

    gateway_type: 'Vpn'

    vpn_type: 'RouteBased'
    vpn_gateway_generation: 'Generation2'

    sku_name: 'VpnGw2AZ'
    sku_tier: 'VpnGw2AZ'

    pip_id: vpn_gateway_pip.outputs.pip_id

    private_ip_allocation_method: 'Dynamic'
    snet_id: network.outputs.snet_gateway_id

    diagnostics_settings_enabled: true
    log_workspace_id: log_workspace.outputs.log_workspace_id
  }
}

module dns_private_resolver 'modules/dns_private_resolver.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'dns-private-resolver-deployment'
  params: {
    name: 'dpr-${application_name}-${environment}'
    location: location

    inbound_endpoint_name: 'inbound-endpoint-01'
    inbound_snet_id: network.outputs.snet_inbound_id

    outbound_endpoint_name: 'outbound-endpoint-01'
    outbound_snet_id: network.outputs.snet_outbound_id

    forwarding_ruleset_name: 'forwarding-ruleset-01'

    vnet_id: network.outputs.vnet_id
    vnet_name: network.outputs.vnet_name
  }
  dependsOn: [
    vpn_gateway
  ]
}

module keyvault 'modules/keyvault.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'keyvault-deployment'
  params: {
    // name: 'kv-${project_id}-cg'
    name: aznames.keyVault.refName
    location: location
    sku_name: 'standard'

    soft_delete_enabled: false
    purge_protection_enabled: false
    enabled_for_template_deployment: false

    pep_name: 'pep-kv-${application_name}-${environment}'
    pep_location: location
    pep_subnet_id: network.outputs.snet_shared_id

    vnet_id: network.outputs.vnet_id
    vnet_name: network.outputs.vnet_name
  }
}

module storage 'modules/storage.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'storage-deployment'
  params: {
    // name: 'st${project_id}${uniqueString(subscription().subscriptionId)}'
    name: aznames.storageAccount.uniName
    location: location

    kind: 'StorageV2'
    sku: 'Standard_ZRS'
    access_tier: 'Hot'

    allow_shared_key_access: true
    allow_blob_public_access: false
    enable_https_traffic_only: true
    allow_cross_tenant_replication: false

    pep_blob_name: 'pep-blob-${application_name}-${environment}'
    pep_blob_location: location
    pep_subnet_id: network.outputs.snet_shared_id

    vnet_id: network.outputs.vnet_id
    vnet_name: network.outputs.vnet_name
  }
}
