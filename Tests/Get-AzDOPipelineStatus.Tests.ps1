$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOPipelineStatus" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOPipelineStatus function" {
			Get-Command -Name Get-AzDOPipelineStatus -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have PipelineId parameter" {
			(Get-Command Get-AzDOPipelineStatus).Parameters.Keys | Should -Contain 'PipelineId'
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have RunID parameter" {
			(Get-Command Get-AzDOPipelineStatus).Parameters.Keys | Should -Contain 'RunID'
		}
	}
}
