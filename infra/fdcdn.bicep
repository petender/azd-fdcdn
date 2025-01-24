@description('MTT Alias for unique resource names')
@maxLength(13)
param namingConvention string = ''
param tags object
param environmentName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Abbreviated Names of the Azure Services that can be used as part of naming resource convention')
var abbrs = loadJsonContent('./abbreviations.json')


@description('Describes plan\'s pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
param sku string = 'S1'

param copyImages bool = true
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))


var serverfarmName = '${abbrs.webServerFarms}${namingConvention}'
var cdnProfileName = '${abbrs.cdnProfiles}${namingConvention}'
var webSitesAppServiceName = '${abbrs.webSitesAppService}${namingConvention}'
var cdnProfileEndpointName = '${abbrs.cdnProfilesEndpoints}${namingConvention}'






resource serverfarm 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: serverfarmName
  location: location
  tags: tags
  sku: {
    name: sku
  }
}

resource cdnprofile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: cdnProfileName
  location: 'Global'
  tags: tags
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  kind: 'frontdoor'
  properties: {
    originResponseTimeoutSeconds: 60
    extendedProperties: {}
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.14.3' = {
  name: 'storageAccountDeployment'

  params: {
    name: '${abbrs.storageStorageAccounts}${resourceToken}'
    tags: tags
    allowBlobPublicAccess: true //is a false here needed?
    defaultToOAuthAuthentication: true // Default to Entra ID Authentication
    supportsHttpsTrafficOnly: true
    kind: 'StorageV2'
    location: location
    skuName: 'Standard_LRS'
    blobServices: {
      enabled: true
      containers: [
        {
          name: 'images'
          publicAccess: 'None'
        }
      ]
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    roleAssignments: [
      
      {
        principalId: blobUploadIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
    ]
    
  }
}

resource webSitesAppService 'Microsoft.Web/sites@2022-09-01' = {
  name: webSitesAppServiceName
  location: location
  tags: tags
  kind: 'app'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${webSitesAppServiceName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${webSitesAppServiceName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarm.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: true
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource cdnProfileEndpoint 'Microsoft.Cdn/profiles/afdendpoints@2022-11-01-preview' = {
  parent: cdnprofile
  name: cdnProfileEndpointName
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource cdnProfileOriginGroup 'Microsoft.Cdn/profiles/origingroups@2022-11-01-preview' = {
  parent: cdnprofile
  name: 'default-origin-group'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}



resource webSitesconfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: webSitesAppService
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v7.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: concat(webSitesAppServiceName)
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource webSitesBinding 'Microsoft.Web/sites/hostNameBindings@2022-09-01' = {
  parent: webSitesAppService
  name: '${webSitesAppServiceName}.azurewebsites.net'
  location: location
  properties: {
    siteName: '${webSitesAppServiceName}/${webSitesAppServiceName}.azurewebsites.net'
    hostNameType: 'Verified'
  }
}

resource cdnProfilesOriginGroupOrigins 'Microsoft.Cdn/profiles/origingroups/origins@2022-11-01-preview' = {
  parent: cdnProfileOriginGroup
  name: 'default-origin'
  properties: {
    hostName: '${webSitesAppServiceName}.azurewebsites.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: '${webSitesAppServiceName}.azurewebsites.net'
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
  dependsOn: [
    cdnprofile
  ]
}

resource cdnProfilesRoutes 'Microsoft.Cdn/profiles/afdendpoints/routes@2022-11-01-preview' = {
  parent: cdnProfileEndpoint
  name: 'default-route'
  properties: {
    cacheConfiguration: {
      compressionSettings: {
        isCompressionEnabled: false
        contentTypesToCompress: [
          'application/eot'
          'application/font'
          'application/font-sfnt'
          'application/javascript'
          'application/json'
          'application/opentype'
          'application/otf'
          'application/pkcs7-mime'
          'application/truetype'
          'application/ttf'
          'application/vnd.ms-fontobject'
          'application/xhtml+xml'
          'application/xml'
          'application/xml+rss'
          'application/x-font-opentype'
          'application/x-font-truetype'
          'application/x-font-ttf'
          'application/x-httpd-cgi'
          'application/x-javascript'
          'application/x-mpegurl'
          'application/x-opentype'
          'application/x-otf'
          'application/x-perl'
          'application/x-ttf'
          'font/eot'
          'font/ttf'
          'font/otf'
          'font/opentype'
          'image/svg+xml'
          'text/css'
          'text/csv'
          'text/html'
          'text/javascript'
          'text/js'
          'text/plain'
          'text/richtext'
          'text/tab-separated-values'
          'text/xml'
          'text/x-script'
          'text/x-component'
          'text/x-java-source'
        ]
      }
      queryStringCachingBehavior: 'IgnoreQueryString'
    }
    customDomains: []
    originGroup: {
      id: cdnProfileOriginGroup.id
    }
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}

module blobUploadIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  name: 'blobUploadIdentityDeployment'
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}upload-${resourceToken}'
    location: location
  }
}

  module uploadBlobsScript 'br/public:avm/res/resources/deployment-script:0.5.0' = if (copyImages) {
    name: 'uploadBlobsScriptDeployment'
    params: {
      kind: 'AzurePowerShell'
      name: 'pwscript-uploadBlobsScript'
      azPowerShellVersion: '12.3'
      location: location
      managedIdentities: {
        userAssignedResourceIds: [
          blobUploadIdentity.outputs.resourceId
        ]
      }
      cleanupPreference: 'OnSuccess'
      retentionInterval: 'P1D'
      enableTelemetry: true
      storageAccountResourceId: storageAccount.outputs.resourceId
      arguments: '-StorageAccountName ${storageAccount.outputs.name}' //multi line strings do not support interpolation in bicep yet
      scriptContent: '''
        param([string] $StorageAccountName)
  
  
        Invoke-WebRequest -Uri "https://github.com/rob-foulkrod/BadgeMaker/raw/3b91a9fa5a117bb79807c98bfb767c0d5e0e645e/sampleBadges/badge1.jpg" -OutFile badge1.jpg
        Invoke-WebRequest -Uri "https://github.com/rob-foulkrod/BadgeMaker/raw/3b91a9fa5a117bb79807c98bfb767c0d5e0e645e/sampleBadges/badge2.jpg" -OutFile badge2.jpg
  
        $context = New-AzStorageContext -StorageAccountName $StorageAccountName
  
        Set-AzStorageBlobContent -Context $context -Container "images" -File badge1.jpg -Blob badge1.jpg -Force
        Set-AzStorageBlobContent -Context $context -Container "images" -File badge2.jpg -Blob badge2.jpg -Force
        '''
    }
  }


