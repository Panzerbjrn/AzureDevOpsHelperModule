Function Add-AzDoProject{
<#
	.SYNOPSIS
		Creates a new project in an Azure DevOps organisation.

	.DESCRIPTION
		Creates a new Azure DevOps project in the connected organisation.

	.EXAMPLE
		Add-AzDoProject -ProjectName NewCoolProject

	.PARAMETER ProjectName
		The name of the new Azure DevOps project.

	.PARAMETER Description
		An optional description for the new project.

	.PARAMETER Visibility
		The visibility of the new project. Valid values are private or public.

	.PARAMETER SourceControlType
		The source control type for the new project. Valid values are Git or Tfvc.

	.PARAMETER ProcessTemplateId
		The process template ID to use for the new project.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		Returns the project operation response.

	.NOTES
		Author:			Lars Panzerbjørn
		Creation Date:	2026.09.25
#>
	[CmdletBinding(PositionalBinding=$False)]
	param(
		[Parameter(Mandatory)]
		[string]$ProjectName,

		[Parameter()]
		[string]$Description,

		[Parameter()]
		[ValidateSet('private','public')]
		[string]$Visibility = 'private',

		[Parameter()]
		[ValidateSet('Git','Tfvc')]
		[string]$SourceControlType = 'Git',

		[Parameter()]
		[string]$ProcessTemplateId = '6b724908-ef14-45cf-84f8-768b5384da45'
	)

	BEGIN{
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"
		$Uri = $BaseUri + "_apis/projects?api-version=7.0"
	}

	PROCESS{
		Write-Verbose "Processing $($MyInvocation.Mycommand)"

		$Body = @{
			name = $ProjectName
			description = $Description
			visibility = $Visibility
			capabilities = @{
				versioncontrol = @{
					sourceControlType = $SourceControlType
				}
				processTemplate = @{
					templateTypeId = $ProcessTemplateId
				}
			}
		} | ConvertTo-Json -Depth 10

		Write-Verbose $Uri
		Write-Verbose $Body
		$Result = Invoke-RestMethod -Uri $Uri -Method POST -Headers $Header -ContentType "application/json" -Body $Body
	}
	END{
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
		if ($Result.name -eq $ProjectName -or $Result.url) {
			$Result
		} else {
			Write-Output "Failed to create project. Response:"
			Write-Output $Result
		}
	}
}
