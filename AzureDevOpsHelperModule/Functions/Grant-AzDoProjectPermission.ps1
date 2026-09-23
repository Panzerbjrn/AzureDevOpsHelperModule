Function Grant-AzDoProjectPermission {
<#
	.SYNOPSIS
		Adds a user (or group) to a project-level Azure DevOps group (eg. Contributors, Project Administrators) or team.

	.DESCRIPTION
		This helper will try a few heuristics to find the project-scoped target group/team and the user principal
		then create a Graph membership to grant the membership (which effectively gives the permissions of that group).

	.PARAMETER Project
		The project name. Defaults to the script-scoped $Project if present.

	.PARAMETER User
		The user to add. Can be email, display name or part thereof.

	.PARAMETER Group
		The project-level group or team to add the user to. Common values: "Contributors", "Project Administrators", "Readers".

	.PARAMETER WhatIf
		If set, the function will only show the actions it would take without performing the membership change.

	.EXAMPLE
		Grant-AzDoProjectPermission -Project "MyProject" -User "alice@contoso.com" -Group "Contributors"

	.NOTES
		Author:			Lars Panzerbjørn
		Creation Date:		2024.12.05
#>
	[CmdletBinding(PositionalBinding=$False)]
	param(
		[Parameter()]
		[Alias('TeamName')]
		[string]$Project = $Script:Project,

		[Parameter(Mandatory)]
		[string]$User,

		[Parameter(Mandatory)]
		[string]$Group,

		[switch]$WhatIf
	)

	BEGIN {
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"

		IF (-not $Header) {
			THROW "Authorization header not available. Run Get-AzDoAccessToken first."
		}

		IF (-not $BaseUri) {
			THROW "BaseUri not found. Run Get-AzDoAccessToken first."
		}

		# Derive organization from BaseUri (assumes format https://dev.azure.com/{org}/ )
		$Org = $null
		IF ($BaseUri -match 'https?://dev.azure.com/([^/]+)/?') { $Org = $Matches[1] }
		ELSEIF ($BaseUri -match 'https?://([^/.]+)\.visualstudio\.com/?') { $Org = $Matches[1] }
		ELSE { Write-Verbose "Could not reliably parse organization from BaseUri: $BaseUri" }

		Write-Verbose "Organization determined as: $Org"
	}

	PROCESS {
		Write-Verbose "Processing $($MyInvocation.Mycommand)"

		# Get project details (to obtain id)
		$projUri = "$BaseUri$Project/_apis/projects/$Project`?api-version=7.0"
		Write-Verbose "Getting project details from $projUri"
		TRY{
			$proj = Invoke-RestMethod -Uri $projUri -Method GET -Headers $Header -ErrorAction Stop
		}
		CATCH{
			THROW "Failed to get project $Project - $_"
		}
		$projectId = $proj.id
		Write-Verbose "ProjectId: $projectId"

		# Attempt 1: list graph groups and try to match common project group names.
		$groupsUri = "https://vssps.dev.azure.com/$Org/_apis/graph/groups?api-version=7.0-preview.1"
		Write-Verbose "Retrieving graph groups from $groupsUri"
		TRY{
			$allGroups = Invoke-RestMethod -Uri $groupsUri -Method GET -Headers $Header -ErrorAction Stop
		}
		CATCH{
			THROW "Failed retrieving graph groups - $_"
		}

		# Heuristics to find group descriptor: try exact project-prefixed name, then simple name, then contains.
		$candidates = @()
		$projPrefixed = "$Project $Group"
		FOREACH ($g in $allGroups.value) {
			$candidates += [pscustomobject]@{
				displayName = $g.displayName
				descriptor  = $g.descriptor
				origin      = $g.origin
				subjectKind = $g.subjectKind
			}
		}

		$match = $candidates | Where-Object { $_.displayName -eq $projPrefixed } | Select-Object -First 1
		IF (-not $match) { $match = $candidates | Where-Object { $_.displayName -eq $Group } | Select-Object -First 1 }
		IF (-not $match) { $match = $candidates | Where-Object { $_.displayName -match [regex]::Escape($Group) } | Select-Object -First 1 }

		IF ($match) {
			Write-Verbose "Found group: $($match.displayName) (descriptor: $($match.descriptor))"
			$groupDescriptor = $match.descriptor
		}
		ELSE {
			Write-Verbose "No graph group matched by heuristics. Will also try project teams."
			# fallback: try project teams API (teams are also containers for membership in many scenarios)
			$teamsUri = "$BaseUri$Project/_apis/teams?api-version=7.0"
			Write-Verbose "Getting project teams: $teamsUri"
			TRY{
				$teams = Invoke-RestMethod -Uri $teamsUri -Method GET -Headers $Header -ErrorAction Stop
			}
			CATCH{
				$teams = $null
			}
			$teamMatch = $null
			IF ($teams) {
				$teamMatch = $teams.value | Where-Object { $_.name -eq $Group -or $_.name -match [regex]::Escape($Group) } | Select-Object -First 1
			}
			IF ($teamMatch) {
				Write-Verbose "Found team: $($teamMatch.name) (id: $($teamMatch.id))"
				# Need to resolve team to graph descriptor by querying graph groups where originId equals team id
				$groupByOrigin = $candidates | Where-Object { $_.displayName -eq $teamMatch.name -or $_.displayName -match [regex]::Escape($teamMatch.name) } | Select-Object -First 1
				IF ($groupByOrigin) {
					$groupDescriptor = $groupByOrigin.descriptor
					$match = $groupByOrigin
				}
			}
		}

		IF (-not $groupDescriptor) {
			THROW "Unable to find group or team descriptor for group '$Group' in project '$Project'. Ensure you have rights to read graph groups."
		}

		# Find the user principal (graph user descriptor)
		Write-Verbose "Searching for user principal matching '$User'"
		$usersUri = "https://vssps.dev.azure.com/$Org/_apis/graph/users?api-version=7.0-preview.1"
		TRY{
			$allUsers = Invoke-RestMethod -Uri $usersUri -Method GET -Headers $Header -ErrorAction Stop
		}
		CATCH{
			THROW "Failed retrieving graph users - $_"
		}
		$userMatch = $allUsers.value | Where-Object {
			($_.principalName -and ($_.principalName -ieq $User -or $_.principalName -like "*$User*")) -or
			($_.mailAddress -and ($_.mailAddress -ieq $User -or $_.mailAddress -like "*$User*")) -or
			($_.displayName -and ($_.displayName -like "*$User*"))
		} | Select-Object -First 1

		IF (-not $userMatch) {
			THROW "Unable to find a graph user matching '$User'. Ensure the user exists in the organization."
		}
		Write-Verbose "Found user: $($userMatch.displayName) (descriptor: $($userMatch.descriptor))"
		$userDescriptor = $userMatch.descriptor

		# Build membership URL and perform the membership create (PUT)
		$membershipUri = "https://vssps.dev.azure.com/$Org/_apis/graph/memberships/$userDescriptor/$groupDescriptor`?api-version=7.0-preview.1"
		Write-Verbose "Membership URI: $membershipUri"

		IF ($WhatIf) {
			Write-Output "WhatIf: would create membership: user '$($userMatch.displayName)' -> group '$Group' (descriptor: $groupDescriptor)"
			RETURN
		}

		Write-Verbose "Creating membership..."
		TRY{
			$res = Invoke-RestMethod -Uri $membershipUri -Method PUT -Headers $Header -ErrorAction Stop -ContentType 'application/json' -Body $null
			$MatchedGroupName = IF ($match) { $match.displayName } ELSE { $Group }
			Write-Output "User '$($userMatch.displayName)' added to group '$MatchedGroupName'."
			RETURN $res
		}
		CATCH{
			THROW "Failed to add membership - $_"
		}
	}

	END {
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
	}
}
