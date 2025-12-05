Function Add-AzDoProjectPermission{
<#
	.SYNOPSIS
		Adds permissions for a user or group to an Azure DevOps project.

	.DESCRIPTION
		Adds permissions for a user or group to an Azure DevOps project.
		This function uses the Azure DevOps Security API to grant project-level permissions
		such as Reader, Contributor, Project Administrator, etc.

	.EXAMPLE
		Add-AzDoProjectPermission -Project "TeamDevOps" -UserEmail "user@company.com" -Role "Contributor"

		This will add Contributor permissions for the specified user to the TeamDevOps project.

	.EXAMPLE
		Add-AzDoProjectPermission -Project "TeamDevOps" -GroupName "DevTeam" -Role "Reader"

		This will add Reader permissions for the specified group to the TeamDevOps project.

	.EXAMPLE
		$Splat = @{
			Project = "TeamDevOps"
			UserEmail = "user@company.com"
			Role = "ProjectAdministrator"
		}
		Add-AzDoProjectPermission @Splat

		This will add Project Administrator permissions using splatting.

	.PARAMETER Project
		The name of your Azure DevOps Project or Team.

	.PARAMETER UserEmail
		The email address of the user to grant permissions to.
		Either UserEmail or GroupName must be specified.

	.PARAMETER GroupName
		The name of the group to grant permissions to.
		Either UserEmail or GroupName must be specified.

	.PARAMETER Role
		The role to assign. Valid values are:
		- Reader
		- Contributor
		- ProjectAdministrator
		- BuildAdministrator

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		Returns the result of the permission assignment.

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

		[Parameter(Mandatory)]
		[ValidateSet('Reader', 'Contributor', 'ProjectAdministrator', 'BuildAdministrator')]
		[string]$Role
	)

	BEGIN{
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"

		#Validate that either UserEmail or GroupName is specified
		IF (-not $UserEmail -and -not $GroupName) {
			Write-Error "You must specify either a UserEmail or a GroupName."
			return
		}

		#Get Project ID
		$ProjectInfo = Get-AzDOProjects | Where-Object {$_.name -eq $Project}
		IF (-not $ProjectInfo) {
			Write-Error "Project '$Project' not found."
			return
		}
		$ProjectId = $ProjectInfo.id
		Write-Verbose "Project ID: $ProjectId"

		#Map Role to Azure DevOps group name
		$RoleGroupMap = @{
			'Reader'               = 'Readers'
			'Contributor'          = 'Contributors'
			'ProjectAdministrator' = 'Project Administrators'
			'BuildAdministrator'   = 'Build Administrators'
		}
		$TargetGroupName = $RoleGroupMap[$Role]
		Write-Verbose "Target Group: $TargetGroupName"
	}

	PROCESS{
		Write-Verbose "Processing $($MyInvocation.Mycommand)"

		#Get the project's security group descriptor
		$GroupsUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/groups?scopeDescriptor=scp.$ProjectId&api-version=7.0-preview.1"
		Write-Verbose "Groups URI: $GroupsUri"

		TRY {
			$Groups = Invoke-RestMethod -Uri $GroupsUri -Method GET -Headers $Header
			$TargetGroup = $Groups.value | Where-Object {$_.displayName -eq $TargetGroupName}

			IF (-not $TargetGroup) {
				Write-Error "Could not find group '$TargetGroupName' in project '$Project'."
				return
			}
			Write-Verbose "Found target group: $($TargetGroup.displayName)"
			$GroupDescriptor = $TargetGroup.descriptor
		}
		CATCH {
			Write-Error "Failed to get project groups: $_"
			return
		}

		#Resolve the user or group to add
		IF ($UserEmail) {
			#Get user descriptor by email
			$UserSearchUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/users?api-version=7.0-preview.1"
			Write-Verbose "User Search URI: $UserSearchUri"

			TRY {
				$Users = Invoke-RestMethod -Uri $UserSearchUri -Method GET -Headers $Header
				$User = $Users.value | Where-Object {$_.mailAddress -eq $UserEmail}

				IF (-not $User) {
					Write-Error "User with email '$UserEmail' not found in organisation."
					return
				}
				Write-Verbose "Found user: $($User.displayName)"
				$MemberDescriptor = $User.descriptor
			}
			CATCH {
				Write-Error "Failed to find user: $_"
				return
			}
		}
		ELSEIF ($GroupName) {
			#Get group descriptor by name
			$AllGroupsUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/groups?api-version=7.0-preview.1"
			Write-Verbose "All Groups URI: $AllGroupsUri"

			TRY {
				$AllGroups = Invoke-RestMethod -Uri $AllGroupsUri -Method GET -Headers $Header
				$SourceGroup = $AllGroups.value | Where-Object {$_.displayName -eq $GroupName}

				IF (-not $SourceGroup) {
					Write-Error "Group '$GroupName' not found in organisation."
					return
				}
				Write-Verbose "Found group: $($SourceGroup.displayName)"
				$MemberDescriptor = $SourceGroup.descriptor
			}
			CATCH {
				Write-Error "Failed to find group: $_"
				return
			}
		}

		#Add member to the target group
		$AddMemberUri = "https://vssps.dev.azure.com/$Script:Organisation/_apis/graph/memberships/$MemberDescriptor/$GroupDescriptor`?api-version=7.0-preview.1"
		Write-Verbose "Add Member URI: $AddMemberUri"

		TRY {
			$Result = Invoke-RestMethod -Uri $AddMemberUri -Method PUT -Headers $Header -ContentType $JsonContentType
		}
		CATCH {
			Write-Error "Failed to add membership: $_"
			return
		}
	}
	END{
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
		IF ($Result) {
			IF ($UserEmail) {
				Write-Output "Successfully added '$UserEmail' to '$TargetGroupName' in project '$Project'."
			}
			ELSE {
				Write-Output "Successfully added group '$GroupName' to '$TargetGroupName' in project '$Project'."
			}
			$Result
		}
	}
}

