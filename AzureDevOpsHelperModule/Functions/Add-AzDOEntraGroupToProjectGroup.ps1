Function Add-AzDOEntraGroupToProjectGroup {
    <#
        .SYNOPSIS
            Adds an Entra ID group to an Azure DevOps project group.

        .DESCRIPTION
            Adds an Entra ID group (materialized in DevOps) to an existing Azure DevOps project group.
            This function uses the Member Entitlement Management API to create the entitlement.

        .EXAMPLE
            Add-AzDOEntraGroupToProjectGroup -EntraObjectId "d1cb703e-b4d0-4978-9664-80cd935462ec" -ProjectGroupDescriptor "vssgp.Uy0xLTktMTU5Lg"

        .PARAMETER EntraObjectId
            The Entra ID Object ID (GUID) of the group to add.

        .PARAMETER ProjectGroupDescriptor
            The descriptor of the target Azure DevOps project group.

        .PARAMETER Organisation
            The name of your Azure DevOps organization.

        .INPUTS
            Input is from command line or called from a script.

        .OUTPUTS
            Returns the group entitlement object.

        .NOTES
            Author:             Lars Panzerbjørn
            Creation Date:      2025.05.20
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$EntraObjectId,

        [Parameter(Mandatory)]
        [string]$ProjectGroupDescriptor,

        [Parameter()]
        [string]$Organisation = $Script:Organisation
    )

    BEGIN {
        $ApiVersion = "7.1-preview.1"
    }

    PROCESS {
        # Endpoint for Group Entitlements (Member Entitlement Management API)
        $Uri = "https://vsaex.dev.azure.com/$Organisation/_apis/groupentitlements?api-version=$ApiVersion"

        # The body references the Entra group by its origin (aad) and originId
        $Body = @{
            origin = "aad"
            originId = $EntraObjectId
            # The groupAssignments section tells the API to add this entitlement
            # as a member of an existing project group.
            groupAssignments = @(
                @{
                    # The ID here is the descriptor of the target project group
                    id = $ProjectGroupDescriptor
                }
            )
        } | ConvertTo-Json -Depth 5

        Write-Verbose "Calling: $Uri"
        Write-Verbose "Body: $Body"

        $Result = Invoke-RestMethod -Uri $Uri -Method POST -Headers $Header -ContentType "application/json" -Body $Body

        $Result
    }
}
