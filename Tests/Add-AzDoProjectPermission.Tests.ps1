$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoProjectPermission" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoProjectPermission function" {
			Get-Command -Name Add-AzDoProjectPermission -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have Project as mandatory parameter" {
			$Param = (Get-Command Add-AzDoProjectPermission).Parameters['Project']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Role as mandatory parameter" {
			$Param = (Get-Command Add-AzDoProjectPermission).Parameters['Role']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}

		It "Should have Role parameter with ValidateSet" {
			$Param = (Get-Command Add-AzDoProjectPermission).Parameters['Role']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ValidateSetAttribute'}) | Should -Not -BeNullOrEmpty
		}
	}
}
