Function Get-AzDOPipelineStatus {
<#
	.SYNOPSIS
		Gets the status of a pipeline run.

	.DESCRIPTION
		Retrieves the status and details of a specified pipeline run.

	.EXAMPLE
		Get-AzDOPipelineStatus -Project "Alpha Devs" -PipelineId 12 -RunID 1

	.PARAMETER Project
		The name of your Azure DevOps project.

	.PARAMETER PipelineId
		The ID of your pipeline.

	.PARAMETER RunID
		The ID of the pipeline run.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		Returns the pipeline run status object.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2020.07.31
#>
    param (
        [string]$Project = $Script:Project,
        [string]$PipelineId,
        [string]$RunID
    )

    $Uri = $BaseUri + "$Project/_apis/pipelines/$PipelineId/runs/$RunID`?api-version=7.0"
    $Response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Header
    RETURN $Response
}
