$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

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
}
