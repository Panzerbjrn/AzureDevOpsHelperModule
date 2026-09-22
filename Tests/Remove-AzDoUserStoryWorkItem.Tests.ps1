$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Remove-AzDoUserStoryWorkItem" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Remove-AzDoUserStoryWorkItem function" {
			Get-Command -Name Remove-AzDoUserStoryWorkItem -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have WorkItemID as mandatory parameter" {
			$Param = (Get-Command Remove-AzDoUserStoryWorkItem).Parameters['WorkItemID']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function should support ShouldProcess' {

		It "Should have SupportsShouldProcess attribute" {
			$Attr = (Get-Command Remove-AzDoUserStoryWorkItem).ScriptBlock.Attributes.Where({$_.TypeId.Name -eq 'CmdletBindingAttribute'})
			$Attr.SupportsShouldProcess | Should -Be $true
		}
	}
}
