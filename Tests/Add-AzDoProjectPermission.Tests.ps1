$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module -Name $ModuleRoot -ErrorAction Stop

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

	It "Should add the user to the group mapped from the selected role" {
		InModuleScope 'AzureDevOpsHelperModule' {
			$Script:Organisation = 'TestOrg'
			Mock Get-AzDOProjects { @([pscustomobject]@{ name = 'TestProject'; id = 'project-id' }) }
			Mock Invoke-RestMethod { @{ value = @(@{ displayName = 'Contributors'; descriptor = 'vssgp.contributors' }) } } -ParameterFilter { $Uri -like '*scopeDescriptor=scp.project-id*' }
			Mock Invoke-RestMethod { @{ value = @(@{ mailAddress = 'user@example.test'; descriptor = 'aad.user' }) } } -ParameterFilter { $Uri -like '*/_apis/graph/users?*' }
			Mock Invoke-RestMethod { @{ memberDescriptor = 'aad.user' } } -ParameterFilter { $Method -eq 'PUT' }

			$result = Add-AzDoProjectPermission -Project 'TestProject' -UserEmail 'user@example.test' -Role Contributor

			$result | Should -Contain "Successfully added 'user@example.test' to 'Contributors' in project 'TestProject'."
			Should -Invoke Invoke-RestMethod -Exactly -Times 1 -ParameterFilter {
				$Uri -eq 'https://vssps.dev.azure.com/TestOrg/_apis/graph/memberships/aad.user/vssgp.contributors?api-version=7.0-preview.1' -and $Method -eq 'PUT'
			}
		}
	}
}
