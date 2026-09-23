Function Get-AzDORepo{
<#
	.SYNOPSIS
		Gets details for a repository in an Azure DevOps project.

	.DESCRIPTION
		Gets details for one or more Git repositories in an Azure DevOps project.

	.EXAMPLE
		This example will RETURN details for all repos in the current project.
		If you have set the $Project variable, you can omit the Project parameter.
		Get-AzDORepo

	.EXAMPLE
		This example will RETURN details for all repos in the project "Alpha Devs".
		Get-AzDORepo -Project "Alpha Devs"

	.EXAMPLE
		This example will RETURN details for the repo named "CoolRepo" in the project "Alpha Devs".
		Get-AzDORepo -Project "Alpha Devs -RepositoryName "CoolRepo"

	.EXAMPLE
		This example will RETURN details for the repo named "CoolRepo" in the current project.
		Get-AzDORepo -RepositoryName "CoolRepo"

	.PARAMETER RepositoryName
		The name of your Azure Devops Repo. If Omitted, all repos are RETURNed.

	.PARAMETER Project
		The name of your Azure Devops project. Is also often a team name.

	.INPUTS
		Input is from command line or called from a script.

	.OUTPUTS
		This will output a details for the repo.

	.NOTES
		Author:				Lars Panzerbjørn
		Creation Date:		2024.11.11
#>
	[CmdletBinding(PositionalBinding=$False)]
	param(
		[Parameter()]
		[Alias('RepoName')]
		[string]$RepositoryName,

		[Parameter()]
		[Alias('TeamName')]
		[string]$Project = $Script:Project
	)

	BEGIN{
		Write-Verbose "Beginning $($MyInvocation.Mycommand)"
	}

	PROCESS{
        IF($RepositoryName){
			$Uri = $BaseUri + "$Project/_apis/git/repositories/$RepositoryName`?api-version=7.0"
		}
		ELSE{
			$Uri = $BaseUri + "$Project/_apis/git/repositories?api-version=7.0"
		}
		Write-Verbose "Processing $($MyInvocation.Mycommand)"
		Write-Verbose "$Uri"

		$Response = Invoke-RestMethod -Uri $Uri -Method get -Headers $Header

		#MarkdownBadge: Currently WIP
		#$MDBadge = "[![Build Status]($($BaseUri)$Project/_apis/build/status/$($RepositoryName)`?branchName=$Branch)]($($BaseUri)$Project/_apis/build/latest?definitionId={definitionId}&branchName=$Branch)"
	}
	END{
		Write-Verbose "Ending $($MyInvocation.Mycommand)"
			$Response
			#$Person | Add-Member -MemberType NoteProperty -Name "Country" -Value "Spain"
	}
}
