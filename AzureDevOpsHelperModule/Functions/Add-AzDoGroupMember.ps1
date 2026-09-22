Function Add-AzDoGroupMember {
<#
	.SYNOPSIS
		Adds an Azure Entra ID group or user to an Azure DevOps project group.

	.DESCRIPTION
		Adds an Azure Entra ID group or user to a project group (e.g., Contributors, Readers) in Azure DevOps.
		This function uses the Graph API Memberships endpoint to create the membership link.

	.EXAMPLE
		Add-AzDoGroupMember -MemberOriginId "11111111-2222-3333-4444-555555555555" -ContainerDescriptor "vssgp..." -Organization "MyOrg"

	.EXAMPLE
		Add-AzDoGroupMember -MemberPrincipalName "user@domain.com" -Project "MyProject" -GroupName "Contributors"

	.PARAMETER MemberDescriptor
		The descriptor of the Azure Entra ID group or user to add.
		You can get this from Graph API's Groups/Users endpoint.

	.PARAMETER MemberOriginId
		The Origin ID (Object ID) of the Azure Entra ID group to add.
		This is the most reliable method for mail-disabled security groups.

	.PARAMETER MemberPrincipalName
		The principal name (email) of the user or group to add.
		This will be used to look up the descriptor if MemberDescriptor is not provided.
		Note: This may not work for mail-disabled security groups.

	.PARAMETER ContainerDescriptor
		The descriptor of the Azure DevOps project group to add the member to.
		This is typically the target group like "Contributors" or "Project Administrators".

	.PARAMETER ContainerName
		The name of the project group (e.g., "Contributors").
		This will be used with Project to look up the descriptor if ContainerDescriptor is not provided.

	.PARAMETER Project
		The name of the Azure DevOps project where the group exists.

	.PARAMETER Organization
		The name of your Azure DevOps organization.

	.INPUTS
		Input is from command line or called from a script.

	.NOTES
		Author:			Lars Panzerbjørn
		Creation Date:	2025.05.20
		Purpose/Change: Initial script development
#>
	[CmdletBinding(DefaultParameterSetName = 'ByDescriptor')]
	param(
		[Parameter(ParameterSetName = 'ByDescriptor', Mandatory)]
		[string]$MemberDescriptor,

		[Parameter(ParameterSetName = 'ByOriginId', Mandatory)]
		[string]$MemberOriginId,

		[Parameter(ParameterSetName = 'ByName', Mandatory)]
		[string]$MemberPrincipalName,

		[Parameter(ParameterSetName = 'ByDescriptor', Mandatory)]
		[Parameter(ParameterSetName = 'ByOriginId', Mandatory)]
		[string]$ContainerDescriptor,

		[Parameter(ParameterSetName = 'ByName', Mandatory)]
		[string]$ContainerName,

		[Parameter(ParameterSetName = 'ByName', Mandatory)]
		[string]$Project,

		[Parameter()]
		[string]$Organization = $Script:Organization
	)

	BEGIN {
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"
		$ApiVersion = "7.1-preview.1"
	}

	PROCESS {
		Write-Verbose "Processing $($MyInvocation.Mycommand)"

		# Resolve Member Descriptor if Origin ID is provided
		if ($PSCmdlet.ParameterSetName -eq 'ByOriginId') {
			Write-Verbose "Looking up descriptor for member Origin ID: $MemberOriginId"
			# Use the Users endpoint with a filter or the Groups endpoint
			# The Graph API can search by originId using the subjectTypes parameter
			$MemberUri = "https://vssps.dev.azure.com/$Organization/_apis/graph/groups?api-version=$ApiVersion&subjectTypes=group"
			$Groups = Invoke-RestMethod -Uri $MemberUri -Method GET -Headers $Header
			$Group = $Groups.value | Where-Object { $_.originId -eq $MemberOriginId }

			if (-not $Group) {
				# Try as a user instead
				$MemberUri = "https://vssps.dev.azure.com/$Organization/_apis/graph/users?api-version=$ApiVersion"
				$Users = Invoke-RestMethod -Uri $MemberUri -Method GET -Headers $Header
				$Group = $Users.value | Where-Object { $_.originId -eq $MemberOriginId }
			}

			if (-not $Group) {
				Write-Error "Could not find member with Origin ID: $MemberOriginId"
				RETURN
			}
			$MemberDescriptor = $Group.descriptor
			Write-Verbose "Found Member Descriptor: $MemberDescriptor"
		}

		# Resolve Member Descriptor if Principal Name is provided (may not work for mail-disabled groups)
		if ($PSCmdlet.ParameterSetName -eq 'ByName') {
			Write-Verbose "Looking up descriptor for member: $MemberPrincipalName"
			$MemberUri = "https://vssps.dev.azure.com/$Organization/_apis/graph/users?api-version=$ApiVersion"
			$Members = Invoke-RestMethod -Uri $MemberUri -Method GET -Headers $Header
			$Member = $Members.value | Where-Object { $_.principalName -eq $MemberPrincipalName -or $_.displayName -eq $MemberPrincipalName }

			if (-not $Member) {
				Write-Error "Could not find member: $MemberPrincipalName"
				RETURN
			}
			$MemberDescriptor = $Member.descriptor
			Write-Verbose "Found Member Descriptor: $MemberDescriptor"
		}

		# Resolve Container Descriptor if not provided
		if ($PSCmdlet.ParameterSetName -eq 'ByName') {
			Write-Verbose "Looking up descriptor for group: $ContainerName in project: $Project"
			$GroupUri = "https://vssps.dev.azure.com/$Organization/_apis/graph/groups?api-version=$ApiVersion&scopeDescriptor=$Project"
			$Groups = Invoke-RestMethod -Uri $GroupUri -Method GET -Headers $Header
			$Group = $Groups.value | Where-Object { $_.displayName -eq $ContainerName }

			if (-not $Group) {
				Write-Error "Could not find group: $ContainerName in project: $Project"
				RETURN
			}
			$ContainerDescriptor = $Group.descriptor
			Write-Verbose "Found Container Descriptor: $ContainerDescriptor"
		}

		# Build URI for adding membership
		$Uri = "https://vssps.dev.azure.com/$Organization/_apis/graph/memberships/$MemberDescriptor/$ContainerDescriptor?api-version=$ApiVersion"
		Write-Verbose "Membership URI: $Uri"

		# The API expects a PUT request with no body
		$Result = Invoke-RestMethod -Uri $Uri -Method PUT -Headers $Header -ContentType "application/json"

		Write-Verbose "Successfully added member to group."
	}
	END {
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
		$Result
	}
}
