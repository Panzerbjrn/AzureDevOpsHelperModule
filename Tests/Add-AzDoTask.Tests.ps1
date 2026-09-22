$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

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
}
