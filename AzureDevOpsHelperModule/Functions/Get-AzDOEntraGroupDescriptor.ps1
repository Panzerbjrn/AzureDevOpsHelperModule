Function Get-AzDOEntraGroupDescriptor {
<#
	.SYNOPSIS
		Gets the Azure DevOps descriptor for a materialized Entra ID group.

	.DESCRIPTION
		Gets the Azure DevOps descriptor for a materialized Entra ID group by
		listing all groups and filtering by the group's Entra Object ID (originId).

	.EXAMPLE
		Get-AzDOEntraGroupDescriptor -EntraObjectId "d1cb703e-b4d0-4978-9664-80cd935462ec"

	.PARAMETER EntraObjectId
		The Object ID (GUID) of the Entra ID group from the Azure portal.

	.PARAMETER Organisation
		The name of your Azure DevOps organization.
	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		Returns the group object with descriptor.
	.NOTES
		Author:			Lars Panzerbjørn
		Creation Date:		2025.05.20
#>
	[CmdletBinding(PositionalBinding=$False)]
	param(
		[Parameter(Mandatory)]
		[string]$EntraObjectId,

		[Parameter()]
		[string]$Organisation = $Script:Organisation
	)

	BEGIN{
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"
		$ApiVersion = "7.1-preview.1"
	}

	PROCESS{
		Write-Verbose "Processing $($MyInvocation.Mycommand)"
		Write-Verbose "Looking up descriptor for Entra Object ID: $EntraObjectId"
		Write-Verbose "Base URI: $BaseUri"

		# List all groups in the organization
		$Uri = "https://vssps.dev.azure.com/$Organisation/_apis/graph/groups?api-version=$ApiVersion"
		# $Uri = $BaseUri + "_apis/graph/groups?api-version=$ApiVersion"
		# $Uri = $BaseUri + "_apis/projects?api-version=7.0"
		Write-Verbose "Calling: $Uri"

		$Response = Invoke-RestMethod -Uri $Uri -Method GET -Headers $Header

		# Find the group matching the Entra Object ID
		$Group = $Response.value | Where-Object { $_.originId -eq $EntraObjectId }

		if ($Group) {
			Write-Verbose "Found group: $($Group.displayName)"
			Write-Verbose "Descriptor: $($Group.descriptor)"
			$Group
		}
		else {
			Write-Error "No group found with Origin ID: $EntraObjectId"
		}
	}

	END{
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
	}
}
