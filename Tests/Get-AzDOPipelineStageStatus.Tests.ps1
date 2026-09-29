$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

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

	It "Should return stage status for the requested run" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ value = @(@{ name = 'Build'; state = 'completed' }) } }

			$result = Get-AzDOPipelineStageStatus -Project 'TestProject' -PipelineId 42 -RunID 7

			$result.value[0].state | Should -Be 'completed'
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/pipelines/42/runs/7/stages?api-version=7.0'
			}
		}
	}
}
