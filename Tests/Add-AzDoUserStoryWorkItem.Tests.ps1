$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoUserStoryWorkItem" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoUserStoryWorkItem function" {
			Get-Command -Name Add-AzDoUserStoryWorkItem -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have WorkItemTitle as mandatory parameter" {
			$Param = (Get-Command Add-AzDoUserStoryWorkItem).Parameters['WorkItemTitle']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Board parameter" {
			(Get-Command Add-AzDoUserStoryWorkItem).Parameters.Keys | Should -Contain 'Board'
		}

		It "Should have WorkItemType parameter" {
			(Get-Command Add-AzDoUserStoryWorkItem).Parameters.Keys | Should -Contain 'WorkItemType'
		}
	}
}
