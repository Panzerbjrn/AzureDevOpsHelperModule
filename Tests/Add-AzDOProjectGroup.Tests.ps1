$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Remove-Module $ModuleName -ErrorAction SilentlyContinue
Import-Module $ModuleRoot -Force -ErrorAction Stop

Describe "Add-AzDOProjectGroup" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDOProjectGroup function" {
			Get-Command -Name Add-AzDOProjectGroup -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have GroupName as mandatory parameter" {
			$Param = (Get-Command Add-AzDOProjectGroup).Parameters['GroupName']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Project parameter" {
			(Get-Command Add-AzDOProjectGroup).Parameters.Keys | Should -Contain 'Project'
		}

		It "Should create a new project group by resolving the project descriptor and posting the expected payload" {
			InModuleScope 'AzureDevOpsHelperModule' {
				$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
				$Script:Header = @{ Authorization = 'Basic test'; accept = 'application/json' }
				$script:capturedPostUri = $null
				$script:capturedPostMethod = $null
				$script:capturedPostContentType = $null
				$script:capturedPostBody = $null

				Mock Invoke-RestMethod {
					param(
						$Uri,
						$Method,
						$Headers,
						$ContentType,
						$Body
					)

					if ($Method -eq 'GET') {
						return [pscustomobject]@{
							descriptor = 'scp.test-project-descriptor'
						}
					}

					$script:capturedPostUri = $Uri
					$script:capturedPostMethod = $Method
					$script:capturedPostContentType = $ContentType
					$script:capturedPostBody = $Body

					[pscustomobject]@{
						displayName = 'Project Developers'
						descriptor = 'vssgp.test-group'
						url = 'https://vssps.dev.azure.com/TestOrg/_apis/graph/groups/vssgp.test-group'
					}
				}

				$result = Add-AzDOProjectGroup -GroupName 'Project Developers' -Project 'MyProject' -Description 'Created by test'

				$result.displayName | Should -Be 'Project Developers'
				$script:capturedPostUri | Should -Be 'https://vssps.dev.azure.com/TestOrg/_apis/graph/groups?scopeDescriptor=scp.test-project-descriptor&api-version=7.1-preview.1'
				$script:capturedPostMethod | Should -Be 'POST'
				$script:capturedPostContentType | Should -Be 'application/json'

				$bodyObject = $script:capturedPostBody | ConvertFrom-Json
				$bodyObject.displayName | Should -Be 'Project Developers'
				$bodyObject.description | Should -Be 'Created by test'
			}
		}
	}
}
