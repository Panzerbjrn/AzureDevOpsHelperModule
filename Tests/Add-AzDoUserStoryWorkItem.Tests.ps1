$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoUserStoryWorkItem" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoUserStoryWorkItem function" {
			Get-Command -Name Add-AzDoUserStoryWorkItem -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have WorkItemTitle as mandatory parameter" {
			$Param = (Get-Command Add-AzDoUserStoryWorkItem).Parameters['WorkItemTitle']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Board parameter" {
			(Get-Command Add-AzDoUserStoryWorkItem).Parameters.Keys | Should -Contain 'Board'
		}

		It "Should have WorkItemType parameter" {
			(Get-Command Add-AzDoUserStoryWorkItem).Parameters.Keys | Should -Contain 'WorkItemType'
		}
	}

	It "Should create a story with its title and area path" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ id = 123 } } -ParameterFilter {
				$Method -eq 'POST' -and
				($Body | ConvertFrom-Json | Where-Object path -eq '/fields/System.Title').value -eq 'New story' -and
				($Body | ConvertFrom-Json | Where-Object path -eq '/fields/System.AreaPath').value -eq 'TestProject'
			}

			$result = Add-AzDoUserStoryWorkItem -Project 'TestProject' -WorkItemTitle 'New story' -Board 'TestProject' -WorkItemType 'User Story'

			$result.id | Should -Be 123
			Should -Invoke Invoke-RestMethod -Exactly -Times 1
		}
	}
}
