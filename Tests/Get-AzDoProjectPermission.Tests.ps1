$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

Describe "Get-AzDoProjectPermission" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Get-AzDoProjectPermission function" {
			Get-Command -Name Get-AzDoProjectPermission -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have Project as mandatory parameter" {
			$Param = (Get-Command Get-AzDoProjectPermission).Parameters['Project']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have UserEmail parameter" {
			(Get-Command Get-AzDoProjectPermission).Parameters.Keys | Should -Contain 'UserEmail'
		}

		It "Should have GroupName parameter" {
			(Get-Command Get-AzDoProjectPermission).Parameters.Keys | Should -Contain 'GroupName'
		}
	}

	It "Should list project groups without fetching members by default" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:Organisation = 'TestOrg'
			Mock Get-AzDOProjects { @([pscustomobject]@{ name = 'TestProject'; id = 'project-id' }) }
			Mock Invoke-RestMethod { @{ value = @(@{ displayName = 'Contributors'; descriptor = 'vssgp.test'; origin = 'vsts' }) } }

			$result = Get-AzDoProjectPermission -Project 'TestProject'

			$result.GroupName | Should -Be 'Contributors'
			$result.Descriptor | Should -Be 'vssgp.test'
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://vssps.dev.azure.com/TestOrg/_apis/graph/groups?scopeDescriptor=scp.project-id&api-version=7.0-preview.1'
			}
		}
	}
}
