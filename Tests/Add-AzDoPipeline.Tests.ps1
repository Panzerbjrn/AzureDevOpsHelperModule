$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoPipeline" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoPipeline function" {
			Get-Command -Name Add-AzDoPipeline -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have PipelineName as mandatory parameter" {
			$Param = (Get-Command Add-AzDoPipeline).Parameters['PipelineName']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have YAMLPath parameter" {
			(Get-Command Add-AzDoPipeline).Parameters.Keys | Should -Contain 'YAMLPath'
		}

		It "Should accept either RepositoryId or RepositoryName" {
			$Command = Get-Command Add-AzDoPipeline
			$Command.Parameters.Keys | Should -Contain 'RepositoryId'
			$Command.Parameters.Keys | Should -Contain 'RepositoryName'
		}
	}

	It "Should create a YAML pipeline for the specified repository" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			Mock Invoke-RestMethod { @{ id = 42 } } -ParameterFilter {
				$Uri -eq 'https://dev.azure.com/TestOrg/TestProject/_apis/pipelines?api-version=7.0' -and
				$Method -eq 'POST' -and ($Body | ConvertFrom-Json).configuration.repository.id -eq 'repo-id'
			}

			$result = Add-AzDoPipeline -Project 'TestProject' -PipelineName 'Build' -RepositoryId 'repo-id' -YAMLPath '/azure-pipelines.yml'

			$result.id | Should -Be 42
			Should -Invoke Invoke-RestMethod -Exactly -Times 1
		}
	}
}
