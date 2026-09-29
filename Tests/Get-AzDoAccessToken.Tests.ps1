$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDoAccessToken" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDoAccessToken function" {
			Get-Command -Name Get-AzDoAccessToken -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have PersonalAccessToken as mandatory parameter" {
			$Param = (Get-Command Get-AzDoAccessToken).Parameters['PersonalAccessToken']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Organisation parameter" {
			(Get-Command Get-AzDoAccessToken).Parameters.Keys | Should -Contain 'Organisation'
		}

		It "Should have PAT alias for PersonalAccessToken" {
			$Param = (Get-Command Get-AzDoAccessToken).Parameters['PersonalAccessToken']
			$Param.Aliases | Should -Contain 'PAT'
		}
	}

	It "Should configure the module for the requested organisation and project" {
		InModuleScope 'AzureDevOpsHelperModule' {
			Get-AzDoAccessToken -PersonalAccessToken 'test-token' -Organisation 'TestOrg' -Project 'TestProject'

			$Script:BaseUri | Should -Be 'https://dev.azure.com/TestOrg/'
			$Script:Project | Should -Be 'TestProject'
			$Script:Header.Authorization | Should -Be ('Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(':test-token')))
		}
	}
}
