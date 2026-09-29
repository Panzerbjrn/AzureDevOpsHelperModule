$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

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

	It "Should return the requested pipeline run status" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ id = 7; state = 'completed' } }

			$result = Get-AzDOPipelineStatus -Project 'TestProject' -PipelineId 42 -RunID 7

			$result.state | Should -Be 'completed'
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/pipelines/42/runs/7?api-version=7.0'
			}
		}
	}
}
