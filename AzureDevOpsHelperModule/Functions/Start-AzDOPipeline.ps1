Function Start-AzDOPipeline{
<#
	.SYNOPSIS
		This will run a pipeline.

	.DESCRIPTION
		This will run a pipeline in your organisation.

	.EXAMPLE
		# Runs with default branch
		Start-AzDOPipeline -Project "Ursus Devs"

    .EXAMPLE
		# Runs with the branch feature-321
        Start-AzDOPipeline -Project "Ursus Devs" -PipelineID "1" -BranchName "feature-321"

	.PARAMETER Project
		The name of your Azure Devops project. Is also often a team name.

	.PARAMETER PipelineID
		The ID of your pipeline.

    .PARAMETER BranchName
        The name of the branch to run the pipeline on. Defaults to the pipeline's default branch if not specified.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2020.07.31
#>
	[CmdletBinding()]
	param(
		[Parameter()]
		[Alias('TeamName')]
		[string]$Project = $Script:Project,

		[Parameter(Mandatory)]
		[string]$PipelineId,

        [Parameter()]
        [string]$BranchName,

		[Parameter()]
		[string[]]$StagesToSkip,

		[Parameter()]
        [hashtable]$TemplateParameters
	)

	BEGIN{
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"
        $Uri = $BaseUri + "$Project/_apis/pipelines/$PipelineId/runs?api-version=7.0"
		Write-verbose "URI: $Uri"
	}

	PROCESS{
		Write-Verbose "Processing $($MyInvocation.Mycommand)"

		#Creating JsonBody
		$JsonBody = @{}

        $RunParameters = @{
			repositories = @{
				self = @{
					refName = ""
				}
			}
        }

        IF($BranchName) {
            #$RunParameters.resources.repositories.self["refName"] = "$BranchName"
            #$RunParameters.resources.repositories.self.refName = $BranchName
            $RunParameters.repositories.self.refName = $BranchName
        }

		#$JsonBody.runParameters = $RunParameters  #This is the correct way to do it, but the API expects the parameters to be in the "resources" property, not in a "runParameters" property.
		$JsonBody.resources = $RunParameters

		IF($StagesToSkip) {
			$JsonBody.stagesToSkip = $StagesToSkip
		}

		IF($TemplateParameters) {
			$JsonBody.templateParameters = $TemplateParameters
		}

        #$JsonBody = $JsonBody | ConvertTo-Json
        $JsonBody = $JsonBody | ConvertTo-Json -Depth 10
		Write-Verbose "JsonBody: $JsonBody"

		$Run = Invoke-RestMethod -Uri $Uri -Method POST -Headers $Header -ContentType $JsonContentType -Body $JsonBody
	}
	END{
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
		$Run
	}
}

