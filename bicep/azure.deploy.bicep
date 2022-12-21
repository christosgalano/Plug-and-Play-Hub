targetScope = 'subscription'

/// Parameters ///

@description('Azure region used for the deployment of all resources')
param location string

@description('Name of the workload that will be deployed')
param workload string

@description('Name of the workloads environment')
param environment string

@description('Tags to be applied on the resource group')
param rg_tags object = {}

@description('Availability zone numbers e.g. 1,2,3.')
param availability_zones array = [
  '1'
  '2'
  '3'
]

/// Variables ///

var tags = union({
    workload: workload
    environment: environment
  }, rg_tags)

/// Modules & Resources ///

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${workload}-${environment}'
  location: location
  tags: tags
}

// AzNames module deployment - this will generate all the names of the resources at deployment time.
module aznames 'modules/aznames.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'aznames-deployment'
  params: {
    suffixes: [
      workload
      environment
    ]
    uniquifierLength: 3
    uniquifier: rg.id
    useDashes: true
  }
}

// Main module deployment
module main 'main.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'workload-deployment'
  params: {
    aznames: aznames.outputs.names
    location: location
    rg_name: rg.name
    workload: workload
    environment: environment
    availability_zones: availability_zones
    // tags: tags
  }
}

/// Outputs ///
