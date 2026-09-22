Function Register-AzDOEntraGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$EntraObjectId,

        [Parameter()]
        [string]$Organisation = $Script:Organisation
    )

    BEGIN {
        Write-Verbose "Beginning $($MyInvocation.Mycommand)"
        # This specific preview API version supports materializing AAD groups
        $ApiVersion = "7.1-preview.1"
    }

    PROCESS {
        Write-Verbose "Materializing Entra group with Origin ID: $EntraObjectId"

        # The endpoint for creating (materializing) a group
        $Uri = "https://vssps.dev.azure.com/$Organisation/_apis/graph/groups?api-version=$ApiVersion"

        # The body uses GraphGroupOriginIdCreationContext
        $Body = @{
            originId = $EntraObjectId
        } | ConvertTo-Json

        Write-Verbose "Calling: $Uri"
        Write-Verbose "Body: $Body"

        try {
            $Result = Invoke-RestMethod -Uri $Uri -Method POST -Headers $Header -ContentType "application/json" -Body $Body
            Write-Verbose "Successfully materialized group: $($Result.displayName)"
            Write-Verbose "Descriptor: $($Result.descriptor)"

            # Return the materialized group object so it can be used immediately
            $Result
        }
        catch {
            Write-Error "Failed to materialize group. Error: $_"
        }
    }

    END {
        Write-Verbose "Ending $($MyInvocation.Mycommand)"
    }
}
