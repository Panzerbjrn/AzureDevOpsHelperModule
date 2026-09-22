$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

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
}
