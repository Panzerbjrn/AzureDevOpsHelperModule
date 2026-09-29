$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoUserStoryComment" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoUserStoryComment function" {
			Get-Command -Name Add-AzDoUserStoryComment -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have WorkItemID as mandatory parameter" {
			$Param = (Get-Command Add-AzDoUserStoryComment).Parameters['WorkItemID']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Comment as mandatory parameter" {
			$Param = (Get-Command Add-AzDoUserStoryComment).Parameters['Comment']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	It "Should patch the work item history with the comment" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ id = 123 } } -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/wit/workitems/123?api-version=7.0' -and
				$Method -eq 'PATCH' -and ($Body | ConvertFrom-Json).value -eq 'Reviewed'
			}

			$result = Add-AzDoUserStoryComment -Project 'TestProject' -WorkItemID 123 -Comment 'Reviewed'

			$result.id | Should -Be 123
			Should -Invoke Invoke-RestMethod -Exactly -Times 1
		}
	}
}
