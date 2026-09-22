$ModuleName = 'AzureDevOpsHelperModule'
$ModuleRoot = Join-Path -Path (Resolve-Path "$PSScriptRoot\..").Path -ChildPath $ModuleName

Import-Module (Join-Path $ModuleRoot "$ModuleName.psd1") -ErrorAction Stop

Describe "Add-AzDoRepo" {

	It "Should have Add-AzDoRepo function" {
		Get-Command -Name Add-AzDoRepo -Module $ModuleName | Should Not BeNullOrEmpty
	}

	It "Should have Project parameter" {
		$Params = (Get-Command Add-AzDoRepo).Parameters
		$Params.ContainsKey('Project') | Should Be $true
	}
}
