$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Add-AzDOEntraGroupToProjectGroup" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDOEntraGroupToProjectGroup function" {
			Get-Command -Name Add-AzDOEntraGroupToProjectGroup -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have EntraObjectId as mandatory parameter" {
			$Param = (Get-Command Add-AzDOEntraGroupToProjectGroup).Parameters['EntraObjectId']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have ProjectGroupDescriptor as mandatory parameter" {
			$Param = (Get-Command Add-AzDOEntraGroupToProjectGroup).Parameters['ProjectGroupDescriptor']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}
}
