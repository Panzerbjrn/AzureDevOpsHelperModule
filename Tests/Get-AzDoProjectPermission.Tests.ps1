$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Get-AzDoProjectPermission" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDoProjectPermission function" {
			Get-Command -Name Get-AzDoProjectPermission -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have Project as mandatory parameter" {
			$Param = (Get-Command Get-AzDoProjectPermission).Parameters['Project']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have UserEmail parameter" {
			(Get-Command Get-AzDoProjectPermission).Parameters.Keys | Should -Contain 'UserEmail'
		}

		It "Should have GroupName parameter" {
			(Get-Command Get-AzDoProjectPermission).Parameters.Keys | Should -Contain 'GroupName'
		}
	}
}
