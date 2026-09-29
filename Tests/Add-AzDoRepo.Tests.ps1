$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoRepo" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoRepo function" {
			Get-Command -Name Add-AzDoRepo -Module $ModuleName | Should -Not -BeNullOrEmpty
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Project parameter" {
			(Get-Command Add-AzDoRepo).Parameters.Keys | Should -Contain 'Project'
		}
	}

	It "Should create a repository with the requested name" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ name = 'ExampleRepo' } } -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/git/repositories?api-version=7.0' -and
				$Method -eq 'POST' -and ($Body | ConvertFrom-Json).name -eq 'ExampleRepo'
			}

			$result = Add-AzDoRepo -Project 'TestProject' -RepositoryName 'ExampleRepo'

			$result.name | Should -Be 'ExampleRepo'
			Should -Invoke Invoke-RestMethod -Exactly -Times 1
		}
	}
}
