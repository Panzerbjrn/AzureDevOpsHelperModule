$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Set-AzDOWorkItem" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Set-AzDOWorkItem function" {
			Get-Command -Name Set-AzDOWorkItem -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have WorkItemID as mandatory parameter" {
			$Param = (Get-Command Set-AzDOWorkItem).Parameters['WorkItemID']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Status parameter" {
			(Get-Command Set-AzDOWorkItem).Parameters.Keys | Should -Contain 'Status'
		}

		It "Should have Tags parameter" {
			(Get-Command Set-AzDOWorkItem).Parameters.Keys | Should -Contain 'Tags'
		}

		It "Should have switches for work calculation" {
			$Command = Get-Command Set-AzDOWorkItem
			$Command.Parameters.Keys | Should -Contain 'CalculateRemainingWork'
			$Command.Parameters.Keys | Should -Contain 'AddToCompletedWork'
		}
	}
}
