$ResourceGroup = "Your Resource Group Name"
$OrganizationLongName = "Your company and identifier (No spaces)"
$FunctionAppNameReceiver = "WorkflowScheduler"
$FunctionAppNameProcessor = "WorkflowSchedulerProcessor"
$FunctionAppNameExecutor = "WorkflowSchedulerExecutor"
$Location = "Your region name i.e. eastus"
$StorageAccount = "Your storage account name"
$QueueAccessPolicyReceiver = "Provided by Donostek LLC"
$ReceiverQueueString = "Provided by Donostek LLC"
$ExecutorQueueString = "Provided by Donostek LLC"
$QueueName = "Your Organization ID"
$ZipFileNameReceiver = "DonostekWorkflowSchedulerAzure_021222.zip"
$ZipFileNameProcessor = "DonostekWorkflowSchedulerProcessor_021522.zip"
$ZipFileNameExecutor = "DonostekWorkflowSchedulerExecutor_021222.zip"
$DynamicsConnection = "Your connection string to Dynamics 365"


Write-Host "****************************"
Write-Host "* DSCHEDULER INSTALLATION  *"
Write-Host "****************************"

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path dschedulerlog.txt -append

Write-Host "*************"
Write-Host "* RECEIVER  *"
Write-Host "*************"

az functionapp create --consumption-plan-location "$Location" --name "$OrganizationLongName$FunctionAppNameReceiver" --os-type Windows --resource-group "$ResourceGroup" --runtime dotnet --storage-account "$StorageAccount"
Write-Host "Function created."

az functionapp deployment source config-zip -g "$ResourceGroup" -n "$OrganizationLongName$FunctionAppNameReceiver" --src "$ZipFileNameReceiver"
Write-Host "Function deployed."

Start-Sleep -s 15
Write-Host "15 secs added receiver"

az functionapp config appsettings set --name "$OrganizationLongName$FunctionAppNameReceiver" --resource-group "$ResourceGroup" --settings "FUNCTIONS_EXTENSION_VERSION=~1"
Write-Host "Function Version set to 1"


Write-Host "*************"
Write-Host "* PROCESSOR *"
Write-Host "*************"

az functionapp create --consumption-plan-location "$Location" --name "$OrganizationLongName$FunctionAppNameProcessor" --os-type Windows --resource-group "$ResourceGroup" --runtime dotnet --storage-account "$StorageAccount"
Write-Host "Function created."

az functionapp deployment source config-zip -g "$ResourceGroup" -n "$OrganizationLongName$FunctionAppNameProcessor" --src "$ZipFileNameProcessor"
Write-Host "Function deployed."

Start-Sleep -s 15
Write-Host "15 secs added processor"

az webapp config connection-string set -g "$ResourceGroup" -n "$OrganizationLongName$FunctionAppNameProcessor" -t custom --settings DScheduler="$ReceiverQueueString"
Write-Host "Function service bus connection created."

az functionapp config appsettings set --name "$OrganizationLongName$FunctionAppNameProcessor" --resource-group "$ResourceGroup" --settings "FUNCTIONS_EXTENSION_VERSION=~1"
Write-Host "Function Version set to 1"

az functionapp config appsettings set --name "$OrganizationLongName$FunctionAppNameProcessor" --resource-group "$ResourceGroup" --settings "connectionString=$DynamicsConnection"
Write-Host "Function connected to Dynamics."

az functionapp config appsettings set --name "$OrganizationLongName$FunctionAppNameProcessor" --resource-group "$ResourceGroup" --settings "QueueName=$QueueName"
Write-Host "Queue name set"

az functionapp config appsettings set --name "$OrganizationLongName$FunctionAppNameProcessor" --resource-group "$ResourceGroup" --settings "ExecutionQueueAccessPolicy=$QueueAccessPolicyReceiver"
Write-Host "Function connected to queue."


Write-Host "*************"
Write-Host "* EXECUTOR  *"
Write-Host "*************"

az functionapp create --consumption-plan-location "$Location" --name "$OrganizationLongName$FunctionAppNameExecutor" --os-type Windows --resource-group "$ResourceGroup" --runtime dotnet --storage-account "$StorageAccount"
Write-Host "Function created."

az functionapp deployment source config-zip -g "$ResourceGroup" -n "$OrganizationLongName$FunctionAppNameExecutor" --src "$ZipFileNameExecutor"
Write-Host "Function deployed."

Start-Sleep -s 15
Write-Host "15 secs added executor"

az functionapp config appsettings set --name "$OrganizationLongName$FunctionAppNameExecutor" --resource-group "$ResourceGroup" --settings "FUNCTIONS_EXTENSION_VERSION=~1"
Write-Host "Function Version set to 1"

az functionapp config appsettings set --name "$OrganizationLongName$FunctionAppNameExecutor" --resource-group "$ResourceGroup" --settings "QueueName=$QueueName"
Write-Host "App Setting: QueueName created"

az functionapp config appsettings set --name "$OrganizationLongName$FunctionAppNameExecutor" --resource-group "$ResourceGroup" --settings "connectionString=$DynamicsConnection"
Write-Host "App Setting: connectionString created"

az webapp config connection-string set -g "$ResourceGroup" -n "$OrganizationLongName$FunctionAppNameExecutor" -t custom --settings "DSchedulerExecutor=$ExecutorQueueString"
Write-Host "Connection Setting: QueueName created"

Write-Host "*************"
Write-Host "*  D O N E  *"
Write-Host "*************"

Stop-Transcript
