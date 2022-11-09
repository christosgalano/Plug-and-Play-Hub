// Parameters

@description('The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to')
param principal_id string

@description('The definition ID of the role to assign')
param role_definition_id string

// Resources

resource role_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principal_id, role_definition_id)
  properties: {
    principalId: principal_id
    roleDefinitionId: role_definition_id
  }
}
