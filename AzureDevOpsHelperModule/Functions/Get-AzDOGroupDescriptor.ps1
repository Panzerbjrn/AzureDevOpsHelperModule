Function Get-AzDOGroupDescriptor{
<#
	.SYNOPSIS
		This will get the descriptor for a group in your Azure DevOps Organisation.

	.DESCRIPTION
		This will get the descriptor for a group in your Azure DevOps Organisation.
		The descriptor can be used as the ContainerDescriptor when adding members to a group.

	.EXAMPLE
		This example will RETURN the descriptor for the group "Contributors" in the project "Alpha Devs".
		Get-AzDOGroupDescriptor -GroupName "Contributors" -Project "Alpha Devs"

	.EXAMPLE
		If you have set the $Project variable, you can omit the Project parameter.
		Get-AzDOGroupDescriptor -GroupName "Contributors"

	.EXAMPLE
		This example will RETURN all groups and their descriptors in the current project.
		Get-AzDOGroupDescriptor

	.PARAMETER GroupName
		The name of the Azure DevOps group. If omitted, all groups are RETURNed.

	.PARAMETER Project
		The name of your Azure Devops project. Is also often a team name.
		If omitted, the group is looked up at the Organisation level.

	.PARAMETER GroupOriginId
		The Origin ID (Object ID) of the group. If provided, this is used to look up
		the descriptor directly instead of searching by name.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output the descriptor for the group(s).

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2025.05.20
#>
	[CmdletBinding(DefaultParameterSetName = 'ByName')]
	param(
		[Parameter(ParameterSetName = 'ByName')]
		[string]$GroupName,

		[Parameter(ParameterSetName = 'ByOriginId', Mandatory)]
		[string]$GroupOriginId,

		[Parameter()]
		[Alias('TeamName')]
		[string]$Project
	)

	BEGIN{
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"
		$ApiVersion = "7.1-preview.1"
	}

PROCESS{
    Write-Verbose "Processing $($MyInvocation.Mycommand)"

    # If OriginId is provided, use the descriptors endpoint directly
    if ($PSCmdlet.ParameterSetName -eq 'ByOriginId') {
        $Uri = "https://vssps.dev.azure.com/$Organisation/_apis/graph/descriptors/$GroupOriginId?api-version=$ApiVersion"
        Write-Verbose "$Uri"
        $Response = Invoke-RestMethod -Uri $Uri -Method GET -Headers $Header
    }
    ELSE{
        # Build the scopeDescriptor for the project if provided
        $ScopeDescriptor = $null
        if ($Project) {
            Write-Verbose "Getting descriptor for project: $Project"
            $ProjectUri = $BaseUri + "_apis/projects/$([uri]::EscapeDataString($Project))?api-version=7.0"
            $ProjectResponse = Invoke-RestMethod -Uri $ProjectUri -Method GET -Headers $Header
            $ScopeDescriptor = $ProjectResponse.descriptor
            Write-Verbose "Found Project Descriptor: $ScopeDescriptor"
        }

        # Build base URI for groups
        if ($ScopeDescriptor) {
            $BaseGroupUri = "https://vssps.dev.azure.com/$Organisation/_apis/graph/groups?scopeDescriptor=$ScopeDescriptor&api-version=$ApiVersion"
        }
        ELSE{
            $BaseGroupUri = "https://vssps.dev.azure.com/$Organisation/_apis/graph/groups?api-version=$ApiVersion"
        }
        Write-Verbose "$BaseGroupUri"

        # --- PAGINATION LOOP ---
        $AllGroups = @()
        $ContinuationToken = $null

        do {
            if ($ContinuationToken) {
                $Uri = "$BaseGroupUri&continuationToken=$ContinuationToken"
            } else {
                $Uri = $BaseGroupUri
            }
            Write-Verbose "Fetching: $Uri"

            $PageResponse = Invoke-RestMethod -Uri $Uri -Method GET -Headers $Header -ResponseHeadersVariable ResponseHeaders

            $AllGroups += $PageResponse.value
            $ContinuationToken = $ResponseHeaders['X-MS-ContinuationToken']

        } while ($ContinuationToken)

        Write-Verbose "Retrieved $($AllGroups.Count) total groups."

        # Filter by name if provided
        if ($GroupName) {
            $Response = $AllGroups | Where-Object { $_.displayName -eq $GroupName }
        }
        ELSE{
            $Response = $AllGroups
        }
    }
}
	END{
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
		$Response
	}
}
