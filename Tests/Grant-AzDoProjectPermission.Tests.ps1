$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

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

	It "Should resolve a user and group without creating membership under WhatIf" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
			$Script:Header = @{ Authorization = 'Basic test' }
			Mock Invoke-RestMethod { @{ id = 'project-id' } } -ParameterFilter { $Uri -like 'https://dev.azure.com/*' }
			Mock Invoke-RestMethod { @{ value = @(@{ displayName = 'TestProject Contributors'; descriptor = 'vssgp.contributors' }) } } -ParameterFilter { $Uri -like '*/graph/groups?*' }
			Mock Invoke-RestMethod { @{ value = @(@{ displayName = 'Test User'; mailAddress = 'user@example.test'; descriptor = 'aad.user' }) } } -ParameterFilter { $Uri -like '*/graph/users?*' }
			Mock Invoke-RestMethod { throw 'A membership request was sent' } -ParameterFilter { $Method -eq 'PUT' }

			$result = Grant-AzDoProjectPermission -Project 'TestProject' -User 'user@example.test' -Group 'Contributors' -WhatIf

			$result | Should -Match 'WhatIf: would create membership'
			Should -Invoke Invoke-RestMethod -Exactly -Times 0 -ParameterFilter { $Method -eq 'PUT' }
		}
	}
}
