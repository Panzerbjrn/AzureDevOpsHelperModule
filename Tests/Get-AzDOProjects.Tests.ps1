$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOProjects" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOProjects function" {
			Get-Command -Name Get-AzDOProjects -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have Organisation parameter" {
			(Get-Command Get-AzDOProjects).Parameters.Keys | Should -Contain 'Organisation'
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Company alias for Organisation" {
			$Param = (Get-Command Get-AzDOProjects).Parameters['Organisation']
			$Param.Aliases | Should -Contain 'Company'
		}
	}

	It "Should return the projects from the REST response" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			$Script:Header = @{ Authorization = 'Basic test' }
			Mock Invoke-RestMethod { @{ value = @(@{ name = 'TestProject' }) } }

			$result = Get-AzDOProjects -Organisation 'TestOrg'

			$result.name | Should -Be 'TestProject'
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/_apis/projects?api-version=7.0' -and $Method -eq 'get'
			}
		}
	}
}
