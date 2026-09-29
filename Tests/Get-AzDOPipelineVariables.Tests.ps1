$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOPipelineVariables" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOPipelineVariables function" {
			Get-Command -Name Get-AzDOPipelineVariables -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have PipelineId as mandatory parameter" {
			$Param = (Get-Command Get-AzDOPipelineVariables).Parameters['PipelineId']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Project parameter" {
			(Get-Command Get-AzDOPipelineVariables).Parameters.Keys | Should -Contain 'Project'
		}
	}

	It "Should return variable names from the pipeline configuration" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ configuration = @{ variables = [pscustomobject]@{ Branch = 'main'; Environment = 'test' } } } }

			Get-AzDOPipelineVariables -Project 'TestProject' -PipelineId 42 | Should -Be @('Branch', 'Environment')
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/pipelines/42?api-version=7.0'
			}
		}
	}
}
