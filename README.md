## Azure FrontDoor with CDN and WebApp

This repo contains a demo for an Azure App Service WebApp, Storage Account and Azure Front Door with CDN, allowing to showcase the caching functionality by displaying Seattle scenery images and showing the loading time for different back-ends. This scenario can be deployed to Azure using the [Azure Developer CLI - AZD](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview). 

💪 This template scenario is part of the larger **[Microsoft Trainer Demo Deploy Catalog](https://aka.ms/trainer-demo-deploy)**.

## ⬇️ Installation
- [Azure Developer CLI - AZD](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
    - When installing AZD, the above the following tools will be installed on your machine as well, if not already installed:
        - [GitHub CLI](https://cli.github.com)
        - [Bicep CLI](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
    - You need Owner or Contributor access permissions to an Azure Subscription to  deploy the scenario.

## 🚀 Deploying the scenario in 4 steps:

1. Create a new folder on your machine.
```
mkdir -p petender/azd-fdcdn
```
2. Next, navigate to the new folder.
```
cd petender/azd-fdcdn
```
3. Next, run `azd init` to initialize the deployment.
```
azd init -t petender/azd-fdcdn
```
4. Last, run `azd up` to trigger an actual deployment.
```
azd up
```

⏩ Note: you can delete the deployed scenario from the Azure Portal, or by running ```azd down``` from within the initiated folder.

## What is the demo scenario about?

- Use the [demo guide]([insert raw link to the demoguide within your repo](https://github.com/petender/azd-fdcdn/blob/main/Demoguides/fdcdn.md)) for inspiration for your demo

## 💭 Feedback and Contributing
Feel free to create issues for bugs, suggestions or Fork and create a PR with new demo scenarios or optimizations to the templates. 
If you like the scenario, consider giving a GitHub ⭐
 


