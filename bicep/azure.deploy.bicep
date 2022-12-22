targetScope = 'subscription'

/// Parameters ///

@description('Azure region used for the deployment of all resources')
param location string

@description('Abbreviation fo the location')
param location_abbreviation string

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
  name: 'rg-${workload}-${environment}-${location_abbreviation}'
  location: location
  tags: tags
}

// Azure Naming module deployment - this will generate all the names of the resources at deployment time.
module naming 'modules/naming.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'azure-naming-deployment'
  params: {
    location: location
    suffix: [
      workload
      environment
      '**location**' // azure-naming location/region placeholder, it will be replaced with its abbreviation
    ]
    uniqueLength: 5
    uniqueSeed: rg.id
    useDashes: true
    useLowerCase: true
  }
}

// Main module deployment
module main 'main.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'workload-deployment'
  params: {
    naming: naming.outputs.names
    rg_name: rg.name

    location: location
    location_abbreviation: location_abbreviation

    workload: workload
    environment: environment

    availability_zones: availability_zones
  }
}
