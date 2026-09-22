Function Add-AzDoUserStoryComment{
<#
	.SYNOPSIS
		Adds a comment to a work item.

	.DESCRIPTION
		Adds a comment to an Azure DevOps work item.

	.EXAMPLE
		Add-AzDoUserStoryComment -Project "Alpha Devs" -WorkItemID 123 -Comment "This is my comment"

	.EXAMPLE
		Add-AzDoUserStoryComment -Organisation "MyOrg" -Project "Alpha Devs" -WorkItemID 123 -Comment "Updated status"

	.PARAMETER OrganizationName
		The name of your Azure Devops Organisation

	.PARAMETER Project
		The name of your Azure Devops Project or Team

	.PARAMETER Board
		Optional. The board name (currently not used in the comment operation).

	.PARAMETER Comment
		The comment text to add to the work item.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		Returns the updated work item with the comment added.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2020.07.31
#>
	[CmdletBinding()]
	param(
		[Parameter()]
		[Alias('Company')]
		[string]$Organisation = $Script:Organisation,

		[Parameter()]
		[Alias('TeamName')]
		[string]$Project = $Script:Project,

		[Parameter(Mandatory)]
		[Alias('WorkItem','ID')]
		[string]$WorkItemID,

		[Parameter()]
		[string]$Board,

		[Parameter(Mandatory)]
		[string]$Comment
	)

	BEGIN{
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"
		$Uri = $BaseUri + "$Project/_apis/wit/workitems/$WorkItemID`?api-version=7.0"
	}

	PROCESS{
		Write-Verbose "Processing $($MyInvocation.Mycommand)"

		$Body = @([pscustomobject]@{
			op = "add"
			path = '/fields/System.History'
			value = $Comment
		})
		$Body = ConvertTo-Json $Body
		$Body
		$Result = Invoke-RestMethod -Uri $Uri -Method PATCH -Headers $Header -ContentType "application/json-patch+json" -Body $Body
	}
	END{
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
		#$Body
		$Result
	}
}
