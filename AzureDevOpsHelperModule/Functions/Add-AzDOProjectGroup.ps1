Function Add-AzDOProjectGroup {
<#
	.SYNOPSIS
		Creates a new security group in an Azure DevOps project.

	.DESCRIPTION
		Creates a new native Azure DevOps security group scoped to the specified project.

	.EXAMPLE
		Add-AzDOProjectGroup -GroupName "Project Developers" -Project "MyProject"

	.PARAMETER GroupName
		The display name of the new project security group.

	.PARAMETER Project
		The name of the Azure DevOps project where the group should be created.

	.PARAMETER Description
		An optional description for the new project security group.

	.PARAMETER Organisation
		The name of your Azure DevOps organisation.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		Returns the created graph group object.

	.NOTES
		Author:			Lars Panzerbjørn
		Creation Date:	2026.09.25
#>
	[CmdletBinding(PositionalBinding=$False)]
	param(
		[Parameter(Mandatory)]
		[string]$GroupName,

		[Parameter()]
		[Alias('TeamName')]
		[string]$Project = $Script:Project,

		[Parameter()]
		[string]$Description,

		[Parameter()]
		[Alias('Company')]
		[string]$Organisation = $Script:Organisation
	)

	BEGIN {
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"
		$ApiVersion = '7.1-preview.1'
	}

	PROCESS {
		Write-Verbose "Processing $($MyInvocation.Mycommand)"

		if (-not $Organisation -and $BaseUri -match '^https://dev\.azure\.com/([^/]+)/') {
			$Organisation = $Matches[1]
		}

		if (-not $Project) {
			Write-Error 'You must specify a Project or connect with a default project set.'
			return
		}

		if (-not $Organisation) {
			Write-Error 'You must specify an Organisation or connect with a default organisation set.'
			return
		}

		$ProjectUri = $BaseUri + "_apis/projects/$([uri]::EscapeDataString($Project))?api-version=7.0"
		Write-Verbose $ProjectUri
		$ProjectResponse = Invoke-RestMethod -Uri $ProjectUri -Method GET -Headers $Header

		$Uri = "https://vssps.dev.azure.com/$Organisation/_apis/graph/groups?scopeDescriptor=$($ProjectResponse.descriptor)&api-version=$ApiVersion"

		$Body = @{
			displayName = $GroupName
		}

		if ($Description) {
			$Body.description = $Description
		}

		$Body = $Body | ConvertTo-Json

		Write-Verbose $Uri
		Write-Verbose $Body
		$Result = Invoke-RestMethod -Uri $Uri -Method POST -Headers $Header -ContentType 'application/json' -Body $Body
	}
	END {
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
		if ($Result.displayName -eq $GroupName -or $Result.url) {
			$Result
		}
		else {
			Write-Output 'Failed to create project group. Response:'
			Write-Output $Result
		}
	}
}
