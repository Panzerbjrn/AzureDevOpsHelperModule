Function Connect-AzDoItems{
<#
	.SYNOPSIS
		Links two Azure DevOps work items in a parent/child relationship.

	.DESCRIPTION
		Links two Azure DevOps work items in a parent/child relationship.

	.EXAMPLE
		Connect-AzDoItems -Project "Alpha Devs" -ParentItemID 123 -ChildItemID 456

	.PARAMETER Project
		The name of your Azure DevOps Project or Team

	.PARAMETER ParentItemID
		The ID of the parent work item.

	.PARAMETER ChildItemID
		The ID of the child work item to link.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		Returns the updated child work item with the parent link added.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2020.07.31
#>
	[CmdletBinding(PositionalBinding=$False)]
	param(
		[Parameter()]
		[Alias('TeamName')]
		[string]$Project = $Script:Project,

		[Parameter(Mandatory)][string]$ParentItemID,
		[Parameter(Mandatory)][string]$ChildItemID
	)

	BEGIN{
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"
		$Uri = $BaseUri + "$Project/_apis/wit/workitems/$ChildItemID`?api-version=7.0"
	}

	PROCESS{
		Write-Verbose "Processing $($MyInvocation.Mycommand)"
		$Value = @{
			rel = "System.LinkTypes.Hierarchy-Reverse"
			url = $BaseUri + "$Project/_apis/wit/workItems/$ParentItemID"
			}
		$Attributes = @{
			isLocked = $False
			name = "Parent"
		}


		$Body = @([pscustomobject]@{
				op = "add"
				path = '/relations/-'
				value = $Value
				Attributes = $Attributes
			}
		)

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
