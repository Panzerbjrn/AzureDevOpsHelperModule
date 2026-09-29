$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOGroupDescriptor" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOGroupDescriptor function" {
			Get-Command -Name Get-AzDOGroupDescriptor -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have parameter sets" {
			(Get-Command Get-AzDOGroupDescriptor).ParameterSets.Count | Should -BeGreaterThan 0
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have GroupName parameter" {
			(Get-Command Get-AzDOGroupDescriptor).Parameters.Keys | Should -Contain 'GroupName'
		}

		It "Should have Project parameter" {
			(Get-Command Get-AzDOGroupDescriptor).Parameters.Keys | Should -Contain 'Project'
		}
	}

	It "Should look up a descriptor by group origin ID" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:Organisation = 'TestOrg'
			Mock Invoke-RestMethod { @{ value = 'vssgp.target' } }

			$result = Get-AzDOGroupDescriptor -GroupOriginId 'target'

			$result.value | Should -Be 'vssgp.target'
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://vssps.dev.azure.com/TestOrg/_apis/graph/descriptors/target?api-version=7.1-preview.1'
			}
		}
	}
}
