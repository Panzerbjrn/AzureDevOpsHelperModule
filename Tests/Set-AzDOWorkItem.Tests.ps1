$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Set-AzDOWorkItem" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Set-AzDOWorkItem function" {
			Get-Command -Name Set-AzDOWorkItem -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have WorkItemID as mandatory parameter" {
			$Param = (Get-Command Set-AzDOWorkItem).Parameters['WorkItemID']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Status parameter" {
			(Get-Command Set-AzDOWorkItem).Parameters.Keys | Should -Contain 'Status'
		}

		It "Should have Tags parameter" {
			(Get-Command Set-AzDOWorkItem).Parameters.Keys | Should -Contain 'Tags'
		}

		It "Should have switches for work calculation" {
			$Command = Get-Command Set-AzDOWorkItem
			$Command.Parameters.Keys | Should -Contain 'CalculateRemainingWork'
			$Command.Parameters.Keys | Should -Contain 'AddToCompletedWork'
		}
	}

	It "Should patch the requested work item state" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Get-AzDoUserStoryWorkItem { @{ id = 123 } }
			Mock Invoke-RestMethod { @{ id = 123 } } -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/wit/workitems/123?api-version=7.0' -and
				$Method -eq 'PATCH' -and ($Body | ConvertFrom-Json).value -eq 'Active'
			}

			$result = Set-AzDOWorkItem -Project 'TestProject' -WorkItemID 123 -Status 'Active'

			$result.id | Should -Be 123
			Should -Invoke Invoke-RestMethod -Exactly -Times 1
		}
	}
}
