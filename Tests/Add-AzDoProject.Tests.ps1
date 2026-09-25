$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Resolve-Path "$PSScriptRoot\..\$ModuleName"

Import-Module $ModuleRoot -ErrorAction Stop

Describe "Add-AzDoProject" -Tag 'Function' {

	Context 'Function should exist and be available' {

		It "Should have Add-AzDoProject function" {
			Get-Command -Name Add-AzDoProject -Module $ModuleName | Should -Not -BeNullOrEmpty
		}

		It "Should have ProjectName as mandatory parameter" {
			$Param = (Get-Command Add-AzDoProject).Parameters['ProjectName']
			$Param.Attributes.Where({$_.TypeId.Name -eq 'ParameterAttribute'}).Mandatory | Should -Contain $true
		}
	}

	Context 'Function parameters should be correct' {

		It "Should have Description parameter" {
			(Get-Command Add-AzDoProject).Parameters.Keys | Should -Contain 'Description'
		}

		It "Should create a new project by posting the expected payload" {
			InModuleScope 'AzureDevOpsHelperModule' {
				$Script:BaseUri = 'https://dev.azure.com/TestOrg/'
				$Script:Header = @{ Authorization = 'Basic test'; accept = 'application/json' }
				$script:capturedUri = $null
				$script:capturedMethod = $null
				$script:capturedContentType = $null
				$script:capturedBody = $null

				Mock Invoke-RestMethod {
					param(
						$Uri,
						$Method,
						$Headers,
						$ContentType,
						$Body
					)

					$script:capturedUri = $Uri
					$script:capturedMethod = $Method
					$script:capturedContentType = $ContentType
					$script:capturedBody = $Body

					[pscustomobject]@{
						name = 'NewCoolProject'
						url = 'https://dev.azure.com/TestOrg/_apis/projects/NewCoolProject'
					}
				}

				$result = Add-AzDoProject -ProjectName 'NewCoolProject' -Description 'Created by test'

				$result.name | Should -Be 'NewCoolProject'
				$script:capturedUri | Should -Be 'https://dev.azure.com/TestOrg/_apis/projects?api-version=7.0'
				$script:capturedMethod | Should -Be 'POST'
				$script:capturedContentType | Should -Be 'application/json'

				$bodyObject = $script:capturedBody | ConvertFrom-Json
				$bodyObject.name | Should -Be 'NewCoolProject'
				$bodyObject.description | Should -Be 'Created by test'
				$bodyObject.visibility | Should -Be 'private'
				$bodyObject.capabilities.versioncontrol.sourceControlType | Should -Be 'Git'
				$bodyObject.capabilities.processTemplate.templateTypeId | Should -Be '6b724908-ef14-45cf-84f8-768b5384da45'
			}
		}
	}
}
