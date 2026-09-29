$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOYAMLPipelineStages" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOYAMLPipelineStages function" {
			Get-Command -Name Get-AzDOYAMLPipelineStages -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have PipelineId as mandatory parameter" {
			$Param = (Get-Command Get-AzDOYAMLPipelineStages).Parameters['PipelineId']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Project parameter" {
			(Get-Command Get-AzDOYAMLPipelineStages).Parameters.Keys | Should -Contain 'Project'
		}
	}

	It "Should return YAML content from the pipeline definition" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ configuration = @{ repository = @{ yamlFileContent = 'stages: [Build]' } } } }

			Get-AzDOYAMLPipelineStages -Project 'TestProject' -PipelineId 42 | Should -Be 'stages: [Build]'
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/pipelines/42/definitions?api-version=7.0'
			}
		}
	}
}
