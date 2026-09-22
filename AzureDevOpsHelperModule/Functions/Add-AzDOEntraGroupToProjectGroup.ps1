Function Add-AzDOEntraGroupToProjectGroup {
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
