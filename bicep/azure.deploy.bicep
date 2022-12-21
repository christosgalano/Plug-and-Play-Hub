targetScope = 'subscription'

/// Parameters ///

param location string
param application_name string
param environment string
param tags object = {}

@description('Availability zone numbers e.g. 1,2,3.')
param availability_zones array = [
  '1'
  '2'
  '3'
]

/// Variables ///

var defaultTags = union({
    applicationName: application_name
    environment: environment
  }, tags)

/// Modules & Resources ///

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${application_name}-${environment}'
  location: location
  tags: defaultTags
}

// AzNames module deployment - this will generate all the names of the resources at deployment time.
module aznames 'modules/aznames.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'az-names'
  params: {
    suffixes: [
      application_name
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
    application_name: application_name
    environment: environment
    availability_zones: availability_zones
    // tags: tags
  }
}

/// Outputs ///
