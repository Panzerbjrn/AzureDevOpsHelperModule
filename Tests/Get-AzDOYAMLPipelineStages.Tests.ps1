$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

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
}
