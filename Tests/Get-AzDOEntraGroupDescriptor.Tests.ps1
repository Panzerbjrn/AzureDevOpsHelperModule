$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOEntraGroupDescriptor" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOEntraGroupDescriptor function" {
			Get-Command -Name Get-AzDOEntraGroupDescriptor -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have EntraObjectId as mandatory parameter" {
			$Param = (Get-Command Get-AzDOEntraGroupDescriptor).Parameters['EntraObjectId']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Organisation parameter" {
			(Get-Command Get-AzDOEntraGroupDescriptor).Parameters.Keys | Should -Contain 'Organisation'
		}
	}

	It "Should match the group by Entra origin ID" {
		InModuleScope 'AzureDevOpsHelperModule' {
			Mock Invoke-RestMethod { @{ value = @(@{ originId = 'other'; descriptor = 'vssgp.other' }, @{ originId = 'target'; descriptor = 'vssgp.target' }) } }

			$result = Get-AzDOEntraGroupDescriptor -Organisation 'TestOrg' -EntraObjectId 'target'

			$result.descriptor | Should -Be 'vssgp.target'
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://vssps.dev.azure.com/TestOrg/_apis/graph/groups?api-version=7.1-preview.1'
			}
		}
	}
}
