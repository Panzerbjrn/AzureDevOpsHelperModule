$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

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
}
