# Register-GuardDutySentinelConnector.ps1

# Replace these values with your actual configuration
$workspaceResourceId = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"
$connectorName = "<connector-name>"  # e.g., AWS-S3-GuardDuty
$roleArn = "arn:aws:iam::<account-id>:role/<sentinel-role-name>"
$destinationTable = "<destination-table>"  # e.g., AWSGuardDuty
$kind = "AmazonWebServicesS3"
$sqsUrl = "https://sqs.<region>.amazonaws.com/<account-id>/<queue-name>"

$properties = @{
    roleArn = $roleArn
    destinationTable = $destinationTable
    sqsUrls = @($sqsUrl)
    dataTypes = @{
        logs = @{
            state = "Enabled"
        }
    }
    connectorDefinitionName = ""
    dcrConfig = $null
}

New-AzResource -ResourceId "$workspaceResourceId/providers/Microsoft.SecurityInsights/dataConnectors/$connectorName" `
    -Properties $properties `
    -Force `
    -ApiVersion "2022-12-01-preview" `
    -Kind $kind
