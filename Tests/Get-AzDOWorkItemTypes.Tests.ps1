$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOWorkItemTypes" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOWorkItemTypes function" {
			Get-Command -Name Get-AzDOWorkItemTypes -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have Project parameter" {
			(Get-Command Get-AzDOWorkItemTypes).Parameters.Keys | Should -Contain 'Project'
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have TeamName alias for Project" {
			$Param = (Get-Command Get-AzDOWorkItemTypes).Parameters['Project']
			$Param.Aliases | Should -Contain 'TeamName'
		}
	}

	It "Should return work item type names" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			$Script:Header = @{ Authorization = 'Basic test' }
			Mock Invoke-RestMethod { '{"value":[{"name":"User Story"},{"name":"Task"}]}' }

			$result = Get-AzDOWorkItemTypes -Project 'TestProject'

			$result | Should -Be @('User Story', 'Task')
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/wit/workitemtypes?api-version=7.0' -and $Method -eq 'Get'
			}
		}
	}
}
