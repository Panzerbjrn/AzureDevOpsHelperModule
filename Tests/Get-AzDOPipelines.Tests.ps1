$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

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
	}
}
