Function Get-AzDoProjectPermission{
<#
	.SYNOPSIS
		Gets permissions for an Azure DevOps project.

	.DESCRIPTION
		Gets permissions for an Azure DevOps project. Can retrieve all permissions,
		or filter by a specific user email or group name.

	.EXAMPLE
		Get-AzDoProjectPermission -Project "TeamDevOps"

		This will get all permission groups and their members for the TeamDevOps project.

	.EXAMPLE
		Get-AzDoProjectPermission -Project "TeamDevOps" -UserEmail "user@company.com"

		This will get the permissions/group memberships for a specific user in the project.

	.EXAMPLE
		Get-AzDoProjectPermission -Project "TeamDevOps" -GroupName "Contributors"

		This will get all members of the Contributors group in the project.

	.EXAMPLE
		Get-AzDoProjectPermission -Project "TeamDevOps" -IncludeMembers

		This will get all permission groups and expand their members for the TeamDevOps project.

	.PARAMETER Project
		The name of your Azure DevOps Project or Team.

	.PARAMETER UserEmail
		Optional. The email address of a specific user to check permissions for.

	.PARAMETER GroupName
		Optional. The name of a specific group to get members for.
		Valid values include: Readers, Contributors, Project Administrators, Build Administrators, etc.

	.PARAMETER IncludeMembers
		Optional switch. When specified, includes the members of each group in the output.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		Returns permission groups and optionally their members.

	.NOTES
		Author:			Lars Panzerbjørn
		Creation Date:	2024.12.05
		Purpose/Change: Initial script development
#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[Alias('TeamName')]
		[string]$Project,

		[Parameter()]
		[string]$UserEmail,

		[Parameter()]
		[string]$GroupName,

		[Parameter()]
		[switch]$IncludeMembers
	)

	BEGIN{
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"

		#Get Project ID
		$ProjectInfo = Get-AzDOProjects | Where-Object {$_.name -eq $Project}
		IF (-not $ProjectInfo) {
			Write-Error "Project '$Project' not found."
			return
		}
		$ProjectId = $ProjectInfo.id
		Write-Verbose "Project ID: $ProjectId"
	}

	PROCESS{
		Write-Verbose "Processing $($MyInvocation.Mycommand)"

		#Get project security groups
		$GroupsUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/groups?scopeDescriptor=scp.$ProjectId&api-version=7.0-preview.1"
		Write-Verbose "Groups URI: $GroupsUri"

		TRY {
			$Groups = Invoke-RestMethod -Uri $GroupsUri -Method GET -Headers $Header
			Write-Verbose "Found $($Groups.count) groups in project"
		}
		CATCH {
			Write-Error "Failed to get project groups: $_"
			return
		}

		#If UserEmail specified, find user's group memberships
		IF ($UserEmail) {
			Write-Verbose "Filtering by user: $UserEmail"

			#Get user descriptor
			$UserSearchUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/users?api-version=7.0-preview.1"
			TRY {
				$Users = Invoke-RestMethod -Uri $UserSearchUri -Method GET -Headers $Header
				$User = $Users.value | Where-Object {$_.mailAddress -eq $UserEmail}

				IF (-not $User) {
					Write-Error "User with email '$UserEmail' not found in organisation."
					return
				}
				Write-Verbose "Found user: $($User.displayName)"
				$UserDescriptor = $User.descriptor
			}
			CATCH {
				Write-Error "Failed to find user: $_"
				return
			}

			#Get user's memberships
			$MembershipsUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/memberships/$UserDescriptor`?api-version=7.0-preview.1"
			Write-Verbose "Memberships URI: $MembershipsUri"

			TRY {
				$Memberships = Invoke-RestMethod -Uri $MembershipsUri -Method GET -Headers $Header
			}
			CATCH {
				Write-Error "Failed to get user memberships: $_"
				return
			}

			#Filter to only project groups
			$ProjectGroupDescriptors = $Groups.value.descriptor
			$UserProjectMemberships = $Memberships.value | Where-Object {$_.containerDescriptor -in $ProjectGroupDescriptors}

			#Build result with group details
			$Result = @()
			FOREACH ($Membership in $UserProjectMemberships) {
				$MatchingGroup = $Groups.value | Where-Object {$_.descriptor -eq $Membership.containerDescriptor}
				IF ($MatchingGroup) {
					$Result += [PSCustomObject]@{
						UserEmail    = $UserEmail
						UserName     = $User.displayName
						GroupName    = $MatchingGroup.displayName
						GroupType    = $MatchingGroup.origin
						Description  = $MatchingGroup.description
					}
				}
			}
		}
		#If GroupName specified, get members of that group
		ELSEIF ($GroupName) {
			Write-Verbose "Filtering by group: $GroupName"

			$TargetGroup = $Groups.value | Where-Object {$_.displayName -eq $GroupName}
			IF (-not $TargetGroup) {
				Write-Error "Group '$GroupName' not found in project '$Project'."
				return
			}

			#Get group members
			$MembersUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/memberships/$($TargetGroup.descriptor)?direction=down&api-version=7.0-preview.1"
			Write-Verbose "Members URI: $MembersUri"

			TRY {
				$Members = Invoke-RestMethod -Uri $MembersUri -Method GET -Headers $Header
			}
			CATCH {
				Write-Error "Failed to get group members: $_"
				return
			}

			#Resolve member details
			$Result = @()
			FOREACH ($Member in $Members.value) {
				$MemberDescriptor = $Member.memberDescriptor

				#Get member details
				$MemberUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/descriptors/$MemberDescriptor`?api-version=7.0-preview.1"

				#Try to get as user first
				$UserUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/users/$MemberDescriptor`?api-version=7.0-preview.1"
				$GroupUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/groups/$MemberDescriptor`?api-version=7.0-preview.1"

				TRY {
					$MemberDetails = Invoke-RestMethod -Uri $UserUri -Method GET -Headers $Header -ErrorAction SilentlyContinue
					$MemberType = "User"
				}
				CATCH {
					TRY {
						$MemberDetails = Invoke-RestMethod -Uri $GroupUri -Method GET -Headers $Header -ErrorAction SilentlyContinue
						$MemberType = "Group"
					}
					CATCH {
						$MemberDetails = $null
						$MemberType = "Unknown"
					}
				}

				IF ($MemberDetails) {
					$Result += [PSCustomObject]@{
						GroupName       = $GroupName
						MemberName      = $MemberDetails.displayName
						MemberEmail     = $MemberDetails.mailAddress
						MemberType      = $MemberType
						MemberOrigin    = $MemberDetails.origin
					}
				}
			}
		}
		#Otherwise, get all groups (optionally with members)
		ELSE {
			Write-Verbose "Getting all project groups"

			IF ($IncludeMembers) {
				$Result = @()
				FOREACH ($Group in $Groups.value) {
					Write-Verbose "Getting members for group: $($Group.displayName)"

					#Get group members
					$MembersUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/memberships/$($Group.descriptor)?direction=down&api-version=7.0-preview.1"

					TRY {
						$Members = Invoke-RestMethod -Uri $MembersUri -Method GET -Headers $Header

						IF ($Members.value.Count -eq 0) {
							$Result += [PSCustomObject]@{
								GroupName       = $Group.displayName
								GroupDescription = $Group.description
								MemberCount     = 0
								MemberName      = $null
								MemberEmail     = $null
								MemberType      = $null
							}
						}
						ELSE {
							FOREACH ($Member in $Members.value) {
								$MemberDescriptor = $Member.memberDescriptor

								#Try to get member details
								$UserUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/users/$MemberDescriptor`?api-version=7.0-preview.1"
								$GroupUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/groups/$MemberDescriptor`?api-version=7.0-preview.1"

								TRY {
									$MemberDetails = Invoke-RestMethod -Uri $UserUri -Method GET -Headers $Header -ErrorAction SilentlyContinue
									$MemberType = "User"
								}
								CATCH {
									TRY {
										$MemberDetails = Invoke-RestMethod -Uri $GroupUri -Method GET -Headers $Header -ErrorAction SilentlyContinue
										$MemberType = "Group"
									}
									CATCH {
										$MemberDetails = $null
										$MemberType = "Unknown"
									}
								}

								$Result += [PSCustomObject]@{
									GroupName        = $Group.displayName
									GroupDescription = $Group.description
									MemberCount      = $Members.value.Count
									MemberName       = $MemberDetails.displayName
									MemberEmail      = $MemberDetails.mailAddress
									MemberType       = $MemberType
								}
							}
						}
					}
					CATCH {
						Write-Warning "Failed to get members for group '$($Group.displayName)': $_"
						$Result += [PSCustomObject]@{
							GroupName        = $Group.displayName
							GroupDescription = $Group.description
							MemberCount      = "Error"
							MemberName       = $null
							MemberEmail      = $null
							MemberType       = $null
						}
					}
				}
			}
			ELSE {
				#Just return the groups without members
				$Result = $Groups.value | Select-Object @{N='GroupName';E={$_.displayName}},
					@{N='Description';E={$_.description}},
					@{N='Origin';E={$_.origin}},
					@{N='Descriptor';E={$_.descriptor}}
			}
		}
	}
	END{
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
		$Result
	}
}

