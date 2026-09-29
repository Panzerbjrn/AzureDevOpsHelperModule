$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Register-AzDOEntraGroup" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Register-AzDOEntraGroup function" {
			Get-Command -Name Register-AzDOEntraGroup -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have EntraObjectId as mandatory parameter" {
			$Param = (Get-Command Register-AzDOEntraGroup).Parameters['EntraObjectId']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Organisation parameter" {
			(Get-Command Register-AzDOEntraGroup).Parameters.Keys | Should -Contain 'Organisation'
		}
	}

	It "Should materialize the group using its Entra origin ID" {
		InModuleScope 'AzureDevOpsHelperModule' {
			Mock Invoke-RestMethod { @{ descriptor = 'vssgp.target'; displayName = 'Test Group' } } -ParameterFilter {
				$Uri -eq 'https://vssps.dev.azure.com/TestOrg/_apis/graph/groups?api-version=7.1-preview.1' -and
				$Method -eq 'POST' -and ($Body | ConvertFrom-Json).originId -eq 'target'
			}

			$result = Register-AzDOEntraGroup -Organisation 'TestOrg' -EntraObjectId 'target'

			$result.descriptor | Should -Be 'vssgp.target'
			Should -Invoke Invoke-RestMethod -Exactly -Times 1
		}
	}
}
