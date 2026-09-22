$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Get-AzDoUserStoryWorkItem" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDoUserStoryWorkItem function" {
			Get-Command -Name Get-AzDoUserStoryWorkItem -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have WorkItemID as mandatory parameter" {
			$Param = (Get-Command Get-AzDoUserStoryWorkItem).Parameters['WorkItemID']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Project parameter" {
			(Get-Command Get-AzDoUserStoryWorkItem).Parameters.Keys | Should -Contain 'Project'
		}

		It "Should have aliases for WorkItemID" {
			$Param = (Get-Command Get-AzDoUserStoryWorkItem).Parameters['WorkItemID']
			$Param.Aliases | Should -Contain 'WorkItem'
		}
	}
}
