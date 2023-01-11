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

var rg_name = 'rg-${workload}-${environment}-${location_abbreviation}'

var rg_tags_final = union({
    workload: workload
    environment: environment
  }, rg_tags)

/// Modules & Resources ///

// Resource Group
module rg 'modules/resource_group.bicep' = {
  name: 'rg-${workload}-${environment}-deployment'
  params: {
    name: rg_name
    location: location
    tags: rg_tags_final
  }
}

// Main module deployment
module main 'main.bicep' = {
  scope: resourceGroup(rg_name)
  name: 'main-${workload}-${environment}-deployment'
  params: {
    location: location
    location_abbreviation: location_abbreviation
    workload: workload
    environment: environment
    availability_zones: availability_zones
  }
  dependsOn: [
    rg
  ]
}

/// Outputs ///

output resource_groups array = [ rg_name ]
