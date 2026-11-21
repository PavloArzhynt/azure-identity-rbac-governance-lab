#!/usr/bin/env bash
set -euo pipefail

# Azure Entra ID & RBAC Least-Privilege Automation Script
# Author: Pavlo Arzhynt

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
RG_NAME="rg-governance-eu-prod"
LOCATION="germanywestcentral"

echo "1. Creating Governance Resource Group in $LOCATION..."
az group create --name "$RG_NAME" --location "$LOCATION" --tags Environment=Prod Owner=PavloArzhynt

echo "2. Creating Microsoft Entra ID Security Groups..."
DEV_GROUP_ID=$(az ad group create \
  --display-name "SG-Azure-Cloud-Engineers" \
  --mail-nickname "sg-azure-cloud-engineers" \
  --description "Cloud engineers with Contributor access scoped to workload RG" \
  --query id -o tsv)

SEC_GROUP_ID=$(az ad group create \
  --display-name "SG-Azure-Security-Auditors" \
  --mail-nickname "sg-azure-security-auditors" \
  --description "Security auditors with Reader access across governance scope" \
  --query id -o tsv)

echo "3. Assigning Least-Privilege Azure RBAC Roles..."
az role assignment create \
  --assignee-object-id "$DEV_GROUP_ID" \
  --assignee-principal-type Group \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME"

az role assignment create \
  --assignee-object-id "$SEC_GROUP_ID" \
  --assignee-principal-type Group \
  --role "Reader" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME"

echo "4. Deploying Bicep Governance Baseline & CanNotDelete Lock..."
az deployment group create \
  --resource-group "$RG_NAME" \
  --template-file governance.bicep \
  --parameters environment=prod location="$LOCATION"

echo "Governance & RBAC baseline deployed successfully."
