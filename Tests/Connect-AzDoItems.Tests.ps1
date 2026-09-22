$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

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
}
