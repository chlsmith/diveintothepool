param
(
    $SqlServerName = 'chris-sql-server',
    $ResourceGroupName = 'chris-sql',
    $PoolName = 'chris-elasticpool',
    $NewDtu = 100,
    $NewStorageMb = 102400
)


# This is just copied/pasted from one of the sample runbooks that is created.   It uses the 'AzureRunAsConnection' that is 
# also created by default with the Azure Automation account
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

Import-Module Az.Accounts 
Import-Module Az.Sql

# Save the pool as a PowerShell object
$pool = Get-AzSqlElasticPool -ElasticPoolName $PoolName -ServerName $SqlServerName -ResourceGroupName $ResourceGroupName

# If using the DTU pricing model
$pool | Set-AzSqlElasticPool -Edition Standard -Dtu $NewDtu -StorageMB $NewStorageMb

# If using vCore pricing model
# $pool | Set-AzSqlElasticPool -ElasticPoolName chris-elasticpool -Edition GeneralPurpose -VCore 1 -StorageMB 250 -ComputeGeneration Gen5