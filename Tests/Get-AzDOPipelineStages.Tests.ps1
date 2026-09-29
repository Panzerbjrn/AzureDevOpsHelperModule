$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDOPipelineStages" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDOPipelineStages function" {
			Get-Command -Name Get-AzDOPipelineStages -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have PipelineId as mandatory parameter" {
			$Param = (Get-Command Get-AzDOPipelineStages).Parameters['PipelineId']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Project parameter" {
			(Get-Command Get-AzDOPipelineStages).Parameters.Keys | Should -Contain 'Project'
		}
	}

	It "Should return stage names from the pipeline definition" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ stages = @(@{ name = 'Build' }, @{ name = 'Deploy' }) } }

			Get-AzDOPipelineStages -Project 'TestProject' -PipelineId 42 | Should -Be @('Build', 'Deploy')
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/pipelines/42?api-version=7.0'
			}
		}
	}
}
