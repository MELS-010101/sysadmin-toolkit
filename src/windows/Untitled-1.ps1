# tests/powershell/Test-SystemHealth.Tests.ps1
BeforeAll {
  $Script:ModulePath = "$PSScriptRoot/../../src/windows/System-Health.ps1"
  # Импортируем функции в текущую сессию для тестирования
  . $Script:ModulePath
}

Describe "Параметры CLI" {
  It "Должен завершаться с кодом 0 при -Help" {
    $out = & $Script:ModulePath -Help 2>&1
    $LASTEXITCODE | Should -Be 0
    $out | Should -Match "PRODUCTION TIPS"
  }

  It "Должен выводить версию при -Version" {
    $out = & $Script:ModulePath -Version
    $out | Should -Match "v?1\.0\.0"
  }
}

Describe "Логика Check-DiskHealth (моки)" {
  BeforeEach {
    Mock Get-CimInstance {
      param($Filter, $ClassName)
      if ($ClassName -eq 'Win32_LogicalDisk' -and $Filter -eq 'DriveType=3') {
        return @(
          [PSCustomObject]@{ DeviceID='C:'; Size=50GB; FreeSpace=2GB; DriveType=3 },
          [PSCustomObject]@{ DeviceID='D:'; Size=200GB; FreeSpace=150GB; DriveType=3 }
        )
      }
    }
  }

  It "Не должен бросать исключения при проверке дисков" {
    { Check-DiskHealth } | Should -Not -Throw
  }
}