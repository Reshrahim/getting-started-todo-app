// Simplified environment for local development
extension radius

@description('The name of the Radius environment')
param environment string = 'todoapp'

resource env 'Applications.Core/environments@2023-10-01-preview' = {
  name: environment
  location: 'global'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: environment
    }
  }
}
