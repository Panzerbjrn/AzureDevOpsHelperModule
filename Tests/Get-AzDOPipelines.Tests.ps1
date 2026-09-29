$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOPipelines" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOPipelines function" {
			Get-Command -Name Get-AzDOPipelines -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have Project parameter" {
			(Get-Command Get-AzDOPipelines).Parameters.Keys | Should -Contain 'Project'
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have PipelineId parameter" {
			(Get-Command Get-AzDOPipelines).Parameters.Keys | Should -Contain 'PipelineId'
		}

		It "Should accept Project or use default from script scope" {
			$Param = (Get-Command Get-AzDOPipelines).Parameters['Project']
			$Param.DefaultValue -or $Param.Attributes | Should -Not -BeNullOrEmpty
		}

		It "Should return the pipelines from the requested project" {
			InModuleScope 'AzureDevOpsHelperModule' {
				$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
				$Script:Header = @{ Authorization = 'Basic test' }
				Mock Invoke-RestMethod { @{ value = @(@{ id = 42; name = 'Build' }) } } -ParameterFilter {
					$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/pipelines?api-version=7.0' -and $Method -eq 'get'
				}

				$result = Get-AzDOPipelines -Project 'TestProject'

				$result.id | Should -Be 42
				Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
					$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/pipelines?api-version=7.0' -and $Method -eq 'get'
				}
			}
		}
	}
}
