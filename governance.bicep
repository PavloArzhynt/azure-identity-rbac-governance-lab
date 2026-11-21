targetScope = 'resourceGroup'

@description('Azure region for governance audit resources (EU data residency compliance)')
param location string = 'germanywestcentral'

@description('Environment tag (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environment string = 'prod'

@description('Storage account name for central Entra ID & Activity audit logs')
param auditStorageName string = 'staudit${uniqueString(resourceGroup().id)}'

// 1. Storage Account for Governance & Entra ID Audit Logs (HTTPS-only, TLS 1.2)
resource auditStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: auditStorageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: {
    Environment: environment
    ManagedBy: 'Bicep-Governance-Lab'
    Compliance: 'GDPR-EU'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

// 2. Resource Lock (CanNotDelete) protecting critical audit infrastructure
resource governanceLock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'lock-prevent-audit-deletion'
  scope: auditStorage
  properties: {
    level: 'CanNotDelete'
    notes: 'Protects compliance and Entra ID audit log storage from accidental deletion.'
  }
}

output auditStorageId string = auditStorage.id
output appliedLockName string = governanceLock.name
