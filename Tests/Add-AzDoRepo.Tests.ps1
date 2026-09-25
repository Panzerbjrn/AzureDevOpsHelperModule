$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoRepo" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoRepo function" {
			Get-Command -Name Add-AzDoRepo -Module $ModuleName | Should -Not -BeNullOrEmpty
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Project parameter" {
			(Get-Command Add-AzDoRepo).Parameters.Keys | Should -Contain 'Project'
		}
	}
}
