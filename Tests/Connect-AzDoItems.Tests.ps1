$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Connect-AzDoItems" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Connect-AzDoItems function" {
			Get-Command -Name Connect-AzDoItems -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have ParentItemID as mandatory parameter" {
			$Param = (Get-Command Connect-AzDoItems).Parameters['ParentItemID']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have ChildItemID as mandatory parameter" {
			$Param = (Get-Command Connect-AzDoItems).Parameters['ChildItemID']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	It "Should add a parent relation to the child work item" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ id = 20 } } -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/wit/workitems/20?api-version=7.0' -and
				$Method -eq 'PATCH' -and ($Body | ConvertFrom-Json).value.url -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/wit/workItems/10'
			}

			$result = Connect-AzDoItems -Project 'TestProject' -ParentItemID 10 -ChildItemID 20

			$result.id | Should -Be 20
			Should -Invoke Invoke-RestMethod -Exactly -Times 1
		}
	}
}
