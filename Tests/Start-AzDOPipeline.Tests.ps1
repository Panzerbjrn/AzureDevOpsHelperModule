$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Start-AzDOPipeline" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Start-AzDOPipeline function" {
			Get-Command -Name Start-AzDOPipeline -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have PipelineId as mandatory parameter" {
			$Param = (Get-Command Start-AzDOPipeline).Parameters['PipelineId']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have BranchName parameter" {
			(Get-Command Start-AzDOPipeline).Parameters.Keys | Should -Contain 'BranchName'
		}

		It "Should have TemplateParameters parameter" {
			(Get-Command Start-AzDOPipeline).Parameters.Keys | Should -Contain 'TemplateParameters'
		}
	}

	It "Should queue a run on the requested branch" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ id = 7 } } -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/pipelines/42/runs?api-version=7.0' -and
				$Method -eq 'POST' -and ($Body | ConvertFrom-Json).resources.repositories.self.refName -eq 'refs/heads/main'
			}

			$result = Start-AzDOPipeline -Project 'TestProject' -PipelineId 42 -BranchName 'refs/heads/main'

			$result.id | Should -Be 7
			Should -Invoke Invoke-RestMethod -Exactly -Times 1
		}
	}
}
