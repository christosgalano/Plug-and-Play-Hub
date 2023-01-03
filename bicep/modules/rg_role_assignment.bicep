/// Parameters ///

@description('The principal ID assigned to the role')
param principal_id string

@description('The role definition ID used in the role assignment')
param role_definition_id string

/// Resources ///

resource role_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principal_id, role_definition_id)
  properties: {
    principalId: principal_id
    roleDefinitionId: role_definition_id
  }
}
