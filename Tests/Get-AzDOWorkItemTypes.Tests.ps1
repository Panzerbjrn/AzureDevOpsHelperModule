$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOWorkItemTypes" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOWorkItemTypes function" {
			Get-Command -Name Get-AzDOWorkItemTypes -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have Project parameter" {
			(Get-Command Get-AzDOWorkItemTypes).Parameters.Keys | Should -Contain 'Project'
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have TeamName alias for Project" {
			$Param = (Get-Command Get-AzDOWorkItemTypes).Parameters['Project']
			$Param.Aliases | Should -Contain 'TeamName'
		}
	}
}
