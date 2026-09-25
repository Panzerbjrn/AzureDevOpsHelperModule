$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Remove-Module $ModuleName -ErrorAction SilentlyContinue
Import-Module $ModuleRoot -Force -ErrorAction Stop

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

		It "Should use the connected organisation when Organization is omitted" {
			InModuleScope 'AzureDevOpsHelperModule' {
				$Script:Organisation = 'Panzerbjrn'
				$Script:Header = @{ Authorization = 'Basic test' }
				$script:capturedUri = $null

				Mock Invoke-RestMethod {
					$script:capturedUri = $Uri
					[pscustomobject]@{
						memberDescriptor = 'aadgp.registered-group'
						containerDescriptor = 'vssgp.project-group'
					}
				}

				Add-AzDoGroupMember `
					-MemberDescriptor 'aadgp.registered-group' `
					-ContainerDescriptor 'vssgp.project-group'

				$script:capturedUri | Should -Be 'https://vssps.dev.azure.com/Panzerbjrn/_apis/graph/memberships/aadgp.registered-group/vssgp.project-group?api-version=7.1-preview.1'
			}
		}
	}
}
