$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

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
}
