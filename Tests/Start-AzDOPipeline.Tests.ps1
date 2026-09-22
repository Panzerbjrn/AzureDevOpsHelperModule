$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

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
}
