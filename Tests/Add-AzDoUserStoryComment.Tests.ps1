$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoUserStoryComment" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoUserStoryComment function" {
			Get-Command -Name Add-AzDoUserStoryComment -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have WorkItemID as mandatory parameter" {
			$Param = (Get-Command Add-AzDoUserStoryComment).Parameters['WorkItemID']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Comment as mandatory parameter" {
			$Param = (Get-Command Add-AzDoUserStoryComment).Parameters['Comment']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}
}
