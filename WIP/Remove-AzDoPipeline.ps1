Function Remove-AzDoPipeline {
<#
    .SYNOPSIS
        Deletes an Azure DevOps pipeline.

    .DESCRIPTION
        Deletes an Azure DevOps pipeline by using its pipeline ID or name.

    .EXAMPLE
        Remove-AzDoPipeline -PipelineId 1234

    .EXAMPLE
        Remove-AzDoPipeline -PipelineId 1234 -Project CoolProjectName

    .PARAMETER PipelineId
        The ID of the pipeline to be deleted.

    .PARAMETER ProjectName
        The name of the Azure DevOps project containing the pipeline.

    .PARAMETER PersonalAccessToken
        The personal access token to authenticate with Azure DevOps.
#>

    [CmdletBinding(PositionalBinding=$False)]
    Param(
        [Parameter(Mandatory)]
        [string]$PipelineId,

        [Parameter()]
        [string]$Project = $Script:Project
    )

	BEGIN{
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"
		$Uri = $BaseUri + "$Project/_apis/pipelines/$PipelineId`?api-version=7.0"
		Write-Verbose "$Uri"
	}


	PROCESS{
		Write-Verbose "Processing $($MyInvocation.Mycommand)"
        TRY{
            $Response = Invoke-RestMethod -Uri $Uri -Method Delete -Headers $Header
        } CATCH{
            Write-Error "Failed to delete pipeline. Error: $_"
        }
    }

    END{
        if ($Response -eq $Null) {
            Write-Output "Pipeline with ID $PipelineId has been successfully deleted from project $ProjectName."
        } else {
            Write-Output "Unexpected response received: $($Response | ConvertTo-Json -Depth 10)"
        }
    }

}
