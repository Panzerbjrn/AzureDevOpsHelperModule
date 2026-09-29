$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDoUserStoryWorkItem" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDoUserStoryWorkItem function" {
			Get-Command -Name Get-AzDoUserStoryWorkItem -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have WorkItemID as mandatory parameter" {
			$Param = (Get-Command Get-AzDoUserStoryWorkItem).Parameters['WorkItemID']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Project parameter" {
			(Get-Command Get-AzDoUserStoryWorkItem).Parameters.Keys | Should -Contain 'Project'
		}

		It "Should have aliases for WorkItemID" {
			$Param = (Get-Command Get-AzDoUserStoryWorkItem).Parameters['WorkItemID']
			$Param.Aliases | Should -Contain 'WorkItem'
		}
	}

	It "Should return the requested work item" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			$Script:Header = @{ Authorization = 'Basic test' }
			Mock Invoke-RestMethod { @{ id = 123 } }

			$result = Get-AzDoUserStoryWorkItem -Project 'TestProject' -WorkItemID 123

			$result.id | Should -Be 123
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/wit/workitems/123?api-version=7.0' -and $Method -eq 'get'
			}
		}
	}
}
