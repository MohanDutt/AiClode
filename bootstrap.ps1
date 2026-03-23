param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$ArgsList
)

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$RootDir/scripts/bootstrap.ps1" @ArgsList
