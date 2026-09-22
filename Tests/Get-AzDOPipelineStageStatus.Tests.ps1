$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOPipelineStageStatus" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOPipelineStageStatus function" {
			Get-Command -Name Get-AzDOPipelineStageStatus -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have PipelineId parameter" {
			(Get-Command Get-AzDOPipelineStageStatus).Parameters.Keys | Should -Contain 'PipelineId'
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have RunID parameter" {
			(Get-Command Get-AzDOPipelineStageStatus).Parameters.Keys | Should -Contain 'RunID'
		}

		It "Should have Project parameter" {
			(Get-Command Get-AzDOPipelineStageStatus).Parameters.Keys | Should -Contain 'Project'
		}
	}
}
