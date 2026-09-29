$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoTask" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoTask function" {
			Get-Command -Name Add-AzDoTask -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have TaskTitle as mandatory parameter" {
			$Param = (Get-Command Add-AzDoTask).Parameters['TaskTitle']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have ParentItemID parameter" {
			(Get-Command Add-AzDoTask).Parameters.Keys | Should -Contain 'ParentItemID'
		}

		It "Should have Description parameter" {
			(Get-Command Add-AzDoTask).Parameters.Keys | Should -Contain 'Description'
		}
	}

	It "Should create a task and connect it to its parent" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ id = 20 } } -ParameterFilter {
				$Method -eq 'POST' -and ($Body | ConvertFrom-Json | Where-Object path -eq '/fields/System.Title').value -eq 'Fix build'
			}
			Mock Connect-AzDoItems { @{ id = 20 } }

			$result = Add-AzDoTask -Project 'TestProject' -TaskTitle 'Fix build' -ParentItemID 10 -Board 'TestProject' -Iteration 'TestProject\Sprint 1'

			$result[-1].id | Should -Be 20
			Should -Invoke Invoke-RestMethod -Exactly -Times 1
			Should -Invoke Connect-AzDoItems -Exactly -Times 1 -ParameterFilter { $ParentItemID -eq 10 -and $ChildItemID -eq 20 }
		}
	}
}
