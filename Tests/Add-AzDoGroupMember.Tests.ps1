$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Path $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoGroupMember" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoGroupMember function" {
			Get-Command -Name Add-AzDoGroupMember -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have parameter sets" {
			(Get-Command Add-AzDoGroupMember).ParameterSets.Count | Should -BeGreaterThan 1
		}
	}

	Context 'Function parameters should be correct' {

		It "Should accept Organization parameter" {
			(Get-Command Add-AzDoGroupMember).Parameters.Keys | Should -Contain 'Organization'
		}

		It "Should have either descriptor or origin ID methods" {
			$Params = (Get-Command Add-AzDoGroupMember).Parameters.Keys
			($Params -contains 'MemberDescriptor' -or $Params -contains 'MemberOriginId') | Should -Be $true
		}
	}
}
