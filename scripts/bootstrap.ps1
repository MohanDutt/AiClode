param(
  [ValidateSet('local','aws','gcp','azure')]
  [string]$Target = 'local',
  [switch]$NoAutoInstall
)

$RootDir = Split-Path -Parent $PSScriptRoot
$Python = Get-Command py -ErrorAction SilentlyContinue
if ($Python) {
  $PythonArgs = @('-3', "$RootDir/scripts/bootstrap.py", '--target', $Target)
} else {
  $Python = Get-Command python -ErrorAction SilentlyContinue
  if (-not $Python) {
    throw 'Python is required to run scripts/bootstrap.py'
  }
  $PythonArgs = @("$RootDir/scripts/bootstrap.py", '--target', $Target)
}
if ($NoAutoInstall) {
  $PythonArgs += '--no-auto-install'
}
& $Python.Source @PythonArgs
