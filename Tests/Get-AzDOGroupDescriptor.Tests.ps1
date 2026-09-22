$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

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
}
