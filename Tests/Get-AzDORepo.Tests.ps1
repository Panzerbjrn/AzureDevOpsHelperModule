$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

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

	It "Should return the requested repository" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			$Script:Header = @{ Authorization = 'Basic test' }
			Mock Invoke-RestMethod { @{ name = 'ExampleRepo' } }

			$result = Get-AzDORepo -Project 'TestProject' -RepositoryName 'ExampleRepo'

			$result.name | Should -Be 'ExampleRepo'
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/git/repositories/ExampleRepo?api-version=7.0' -and $Method -eq 'get'
			}
		}
	}
}
