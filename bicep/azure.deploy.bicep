targetScope = 'subscription'

param location string
param application_name string
param environment string
param tags object = {}

// Resource group where the workload will be deployed

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${application_name}-${environment}'
  location: location
  tags: tags
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
    availability_zones: []
    // tags: tags
  }
}

// Outputs
