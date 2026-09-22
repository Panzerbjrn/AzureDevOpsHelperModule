$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOProjects" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOProjects function" {
			Get-Command -Name Get-AzDOProjects -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have Organisation parameter" {
			(Get-Command Get-AzDOProjects).Parameters.Keys | Should -Contain 'Organisation'
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Company alias for Organisation" {
			$Param = (Get-Command Get-AzDOProjects).Parameters['Organisation']
			$Param.Aliases | Should -Contain 'Company'
		}
	}
}
