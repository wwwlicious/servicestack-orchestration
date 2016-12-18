Param(
  [string]$runOption
)

$azure_client_name=""     # Application name
$azure_client_secret=""   # Application password
$azure_group_name=""
$azure_storage_name=""
$azure_subscription_id="" # Derived from the account after login
$azure_tenant_id=""       # Derived from the account after login
$location=""
$azure_object_id=""

function ShowHelp() {
	echo "azure-setup"
	echo ""
	echo "  azure-setup helps you generate Terraform credentials for Azure"
	echo ""
	echo "  The script application"
	echo "  (client), service principal, and permissions and displays a snippet"
	echo "  for use in your Terraform templates."
	echo ""
	echo "  For simplicity we make a lot of assumptions and choose reasonable"
	echo "  defaults. If you want more control over what happens, please use"
	echo "  the Azure Powershell directly."
	echo ""
	echo "  Note that you must already have an Azure account, username,"
	echo "  password, and subscription. You can create those here:"
	echo ""
	echo "  - https://account.windowsazure.com/"
	echo ""
	echo "REQUIREMENTS"
	echo ""
	echo "  - Azure PowerShell"
	echo "  - jq"
	echo ""
	echo "  Use the requirements command (below) for more info."
	echo ""
	echo "USAGE"
	echo ""
	echo "  ./azure-setup.ps1 requirements"
	echo "  ./azure-setup.ps1 setup"
	echo ""
}

function Requirements() {
	$found=0

	$azureversion = (Get-Module -ListAvailable -Name Azure -Refresh)
	If ($azureversion.Version.Major -gt 0) 
	{
		$found=$found + 1
		echo "Found Azure PowerShell version: $($azureversion.Version.Major).$($azureversion.Version.Minor)"
	}
	Else
	{
		echo "Azure PowerShell is missing. Please download and install Azure PowerShell from"
		echo "http://aka.ms/webpi-azps"		
	}

	return $found
}

function AskSubscription() {
	$azuresubscription = Add-AzureRmAccount
	Get-AzureSubscription | out-gridview -PassThru -Title "Select your subscription" | select-azuresubscription 
	$script:azure_subscription_id = $azuresubscription.Context.Subscription.SubscriptionId
	$script:azure_tenant_id = $azuresubscription.Context.Subscription.TenantId		
}

Function RandomComplexPassword ()
{
	param ( [int]$Length = 8 )
 	#Usage: RandomComplexPassword 12
 	$Assembly = Add-Type -AssemblyName System.Web
 	$RandomComplexPassword = [System.Web.Security.Membership]::GeneratePassword($Length,2)
 	return $RandomComplexPassword
}

function AskName() {
	echo ""
	echo "Choose a name for your client."
	echo "This is mandatory - do not leave blank."
	echo "ALPHANUMERIC ONLY. Ex: mytfdeployment."
	echo -n "> "
	$script:meta_name = Read-Host
}

function AskSecret() {
	echo ""
	echo "Enter a secret for your application. We recommend generating one with"
	echo "openssl rand -base64 24. If you leave this blank we will attempt to"
	echo "generate one for you using .Net Security Framework. THIS WILL BE SHOWN IN PLAINTEXT."
	echo "Ex: myterraformsecret8734"
	echo -n "> "
	$script:azure_client_secret = Read-Host
	if ($script:azure_client_secret -eq "")
	{
		$script:azure_client_secret = RandomComplexPassword(43)
	}	
	echo "Client_secret: $script:azure_client_secret"
}

function CreateServicePrinciple() {
	echo "==> Creating service principal"
	$app = New-AzureRmADApplication -DisplayName $meta_name -HomePage "https://$script:meta_name" -IdentifierUris "https://$script:meta_name" -Password $script:azure_client_secret
 	New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId
	
	#sleep 10 seconds to allow resource creation to converge
	Start-Sleep -s 10
 	New-AzureRmRoleAssignment -RoleDefinitionName Owner -ServicePrincipalName $app.ApplicationId.Guid
	
	$script:azure_client_id = $app.ApplicationId
	$script:azure_object_id = $app.ObjectId

	if ($error.Count > 0)
	{
		echo "Error creating service principal: $azure_client_id"
		exit
	}
}

function GetTools() {
	$toolDir = ".tools"
	$arch = If ([System.Environment]::Is64BitOperatingSystem) {"amd64"} Else {"386"} 
	$version = "0.8.1"
	$terraformUrl = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_windows_${arch}.zip"
	$terraformExePath = $pwd.Path + "\$toolDir\terraform.exe" 
	$zipFile = $pwd.Path + "\$toolDir\tf.zip"
	if(!(Test-Path -Path $toolDir )) {
		echo ""
		echo "Creating .tools dir"
		echo ""
		New-Item -ItemType directory -Path $toolDir | out-null
	}

	if(!(Test-Path -Path $terraformExePath)){
		$webclient = New-Object System.Net.WebClient
		echo "downloading terraform from $terraformUrl"

		$webclient.DownloadFile($terraformUrl, $zipFile)
		Expand-Archive $zipFile $toolDir
		Remove-Item $zipFile
		New-Alias tf $(resolve-path $terraformExePath)
	}
}

function ShowConfigs() {
	$azureConnectionfileName = "azure-connection.tf"
	$config = 
@" 
{
	"client_id": "$azure_client_id",
	"client_secret": "$azure_client_secret",
	"subscription_id": "$azure_subscription_id",
	"tenant_id": "$azure_tenant_id"
} 
"@

	echo ""
	echo "the following configuration for your Terraform scripts is being written to $(Get-Location)\${azureConnectionfileName}:"
	echo ""
	echo $config
	$config | Out-File $azureConnectionfileName
}

function Setup() {
	$reqs = Requirements
	
	if($reqs -gt 0)
	{
		#AskSubscription
		#AskName
		#AskSecret

		#CreateServicePrinciple

		#ShowConfigs
		GetTools
	}
}

switch ($runOption)
    {
        "requirements" { Requirements }
        "setup" { Setup }
        default { ShowHelp }
    }
