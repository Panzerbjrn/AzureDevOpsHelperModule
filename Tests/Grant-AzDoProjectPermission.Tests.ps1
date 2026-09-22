$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Grant-AzDoProjectPermission" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Grant-AzDoProjectPermission function" {
			Get-Command -Name Grant-AzDoProjectPermission -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have User as mandatory parameter" {
			$Param = (Get-Command Grant-AzDoProjectPermission).Parameters['User']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Group as mandatory parameter" {
			$Param = (Get-Command Grant-AzDoProjectPermission).Parameters['Group']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}

		It "Should have Project parameter" {
			(Get-Command Grant-AzDoProjectPermission).Parameters.Keys | Should -Contain 'Project'
		}
	}
}
