$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Get-AzDORepo" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDORepo function" {
			Get-Command -Name Get-AzDORepo -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have RepositoryName parameter" {
			(Get-Command Get-AzDORepo).Parameters.Keys | Should -Contain 'RepositoryName'
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Project parameter" {
			(Get-Command Get-AzDORepo).Parameters.Keys | Should -Contain 'Project'
		}

		It "Should have RepoName alias" {
			$Param = (Get-Command Get-AzDORepo).Parameters['RepositoryName']
			$Param.Aliases | Should -Contain 'RepoName'
		}
	}
}
