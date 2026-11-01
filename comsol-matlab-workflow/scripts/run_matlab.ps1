#requires -Version 7.0
param(
    [Parameter(Mandatory)][string]$TaskFile,
    [Parameter(Mandatory)][string]$ConfigFile,
    [ValidateSet('PrepareConnected','Standalone')][string]$Mode = 'PrepareConnected',
    [string[]]$InputFiles = @(),
    [string[]]$SupportFiles = @(),
    [string]$ResultsRoot,
    [string]$ProjectRoot,
    [switch]$Execute
)
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Execute this entry on Windows, including when controlled remotely from Mac.' }
if (-not $ProjectRoot) { $ProjectRoot = (Get-Location).Path }
$projectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
if (-not (Test-Path -LiteralPath $projectRoot -PathType Container)) { throw 'ProjectRoot must be an existing directory.' }
$skillRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if ($projectRoot -eq $skillRoot -or $projectRoot.StartsWith($skillRoot + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) {
    throw 'Use a research project directory, not the global Skill directory.'
}
if (-not $ResultsRoot) { $ResultsRoot = Join-Path $projectRoot 'results' }
$ResultsRoot = [IO.Path]::GetFullPath($ResultsRoot)
$taskPath = (Resolve-Path -LiteralPath $TaskFile).Path
$configPath = (Resolve-Path -LiteralPath $ConfigFile).Path
$taskName = [IO.Path]::GetFileNameWithoutExtension($taskPath)
if ([IO.Path]::GetExtension($taskPath) -ne '.m' -or $taskName -notmatch '^[A-Za-z][A-Za-z0-9_]*$' -or $taskName -eq 'matlab_entry_template') {
    throw 'Task must be a MATLAB function file with a valid, nonreserved name.'
}
$configText = [IO.File]::ReadAllText($configPath)
$config = $configText | ConvertFrom-Json
if ($configText -match '"[^"\r\n]*(password|passwd|credential|secret|license[_-]?key|token)[^"\r\n]*"\s*:') {
    throw 'Credential-like configuration keys are prohibited; authentication must precede task logging.'
}
if ($Mode -eq 'Standalone' -and $config.requires_comsol -eq $true) { throw 'Standalone cannot execute a task that requires COMSOL.' }
if ($Mode -eq 'PrepareConnected' -and $Execute) { throw 'Existing-session submission is not automated without the actual verified adapter.' }
$localTime = [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTimeOffset]::UtcNow,'China Standard Time')
$runName = 'run_' + $localTime.ToString('yyyyMMdd_HHmmss') + '_' + [Guid]::NewGuid().ToString('N').Substring(0,8)
New-Item -ItemType Directory -Path $ResultsRoot -Force | Out-Null
$runDir = Join-Path $ResultsRoot $runName
if (Test-Path -LiteralPath $runDir) { throw 'Run directory collision.' }
New-Item -ItemType Directory -Path $runDir | Out-Null
foreach ($folder in @('input','source','logs','output','matlab_prefs','tmp')) {
    New-Item -ItemType Directory -Path (Join-Path $runDir $folder) | Out-Null
}
function Copy-NewFile([string]$Source,[string]$Destination) {
    [IO.File]::Copy($Source,$Destination,$false)
}
Copy-NewFile $taskPath (Join-Path $runDir "source\$taskName.m")
Copy-NewFile (Join-Path $PSScriptRoot 'matlab_entry_template.m') (Join-Path $runDir 'source\matlab_entry_template.m')
Copy-NewFile $configPath (Join-Path $runDir 'input\config.json')
$inputManifest = @()
foreach ($inputPath in $InputFiles) {
    $resolved = (Resolve-Path -LiteralPath $inputPath).Path
    $destination = Join-Path $runDir ('input\' + [IO.Path]::GetFileName($resolved))
    Copy-NewFile $resolved $destination
    $inputManifest += @{original=$resolved;snapshot=$destination;sha256=(Get-FileHash -LiteralPath $destination).Hash}
}
foreach ($supportPath in $SupportFiles) {
    $resolved = (Resolve-Path -LiteralPath $supportPath).Path
    Copy-NewFile $resolved (Join-Path $runDir ('source\' + [IO.Path]::GetFileName($resolved)))
}
$context = [ordered]@{
    run_id=$runName;created_utc=[DateTimeOffset]::UtcNow.ToString('o');host_name=$env:COMPUTERNAME
    project_root=$projectRoot;mode=$Mode;require_comsol=($Mode -eq 'PrepareConnected');task_function=$taskName
    task_original=$taskPath;config_original=$configPath;inputs=$inputManifest
    sources=@(Get-ChildItem -LiteralPath "$runDir\source" -File | ForEach-Object {Get-FileHash -LiteralPath $_.FullName} | Select-Object Path,Hash)
    existing_processes=@(Get-Process | Where-Object {$_.ProcessName -match 'comsol|matlab'} | Select-Object ProcessName,Id,Path)
}
[IO.File]::WriteAllText((Join-Path $runDir 'run_context.json'),($context | ConvertTo-Json -Depth 8))
$escapedRun = $runDir.Replace("'","''")
$escapedSource = (Join-Path $runDir 'source').Replace("'","''")
# cd is restored even on failure; use source as current folder, not a persistent path change.
$invoke = "workflow_invoke_local();`nfunction workflow_invoke_local()`noldPwd=pwd; cleanup=onCleanup(@()cd(oldPwd));`ncd('$escapedSource');`nmatlab_entry_template('$escapedRun');`nend`n"
[IO.File]::WriteAllText((Join-Path $runDir 'invoke_in_existing_session.m'),$invoke)
$invocationFile = (Join-Path $runDir 'invoke_in_existing_session.m').Replace("'","''")
[IO.File]::WriteAllText((Join-Path $runDir 'invoke_command.txt'),"run('$invocationFile')")
$record = [ordered]@{
    run_id=$runName;status='PREPARED';mode=$Mode;run_directory=$runDir
    validation='NOT TESTED';server_log='UNAVAILABLE'
    stream_encoding='Native process bytes; MATLAB diary/error/status are separate text evidence'
    stdout= $(if($Mode -eq 'PrepareConnected'){'UNAVAILABLE: existing MATLAB window'}else{'NOT TESTED'})
    stderr= $(if($Mode -eq 'PrepareConnected'){'UNAVAILABLE: existing MATLAB window'}else{'NOT TESTED'})
}
$statePath = Join-Path $runDir 'run_status.json'
function Save-RunState { [IO.File]::WriteAllText($statePath,($record | ConvertTo-Json -Depth 8)) }
Save-RunState
if ($Mode -eq 'PrepareConnected' -or -not $Execute) {
    $record.status = if ($Mode -eq 'PrepareConnected') {'AWAITING_EXISTING_SESSION'} else {'PREPARED_NOT_EXECUTED'}
    Save-RunState
    [pscustomobject]@{RunDirectory=$runDir;Status=$record.status;Invocation="run('$invocationFile')"}
    return
}
# Explicit Standalone execution only; no service/connection/login flags.
$startInfo = [Diagnostics.ProcessStartInfo]::new()
$startInfo.FileName = 'D:\Program Files\MATLAB\R2023a\bin\matlab.exe'
$startInfo.WorkingDirectory = Join-Path $runDir 'source'
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
$startInfo.Environment['MATLAB_PREFDIR'] = Join-Path $runDir 'matlab_prefs'
$startInfo.Environment['TEMP'] = Join-Path $runDir 'tmp'
$startInfo.Environment['TMP'] = Join-Path $runDir 'tmp'
foreach ($arg in @('-wait','-sd',$startInfo.WorkingDirectory,'-batch',"matlab_entry_template('$escapedRun')")) { $startInfo.ArgumentList.Add($arg) }
$record.executable = $startInfo.FileName
$record.arguments = @($startInfo.ArgumentList)
$record.started_utc = [DateTimeOffset]::UtcNow.ToString('o')
$record.status = 'RUNNING'; Save-RunState
try {
    $process = [Diagnostics.Process]::Start($startInfo)
    $record.pid = $process.Id
    # Stream directly to files so long jobs preserve output before exit.
    $outStream = [IO.File]::Open((Join-Path $runDir 'logs\stdout.log'),[IO.FileMode]::CreateNew)
    $errStream = [IO.File]::Open((Join-Path $runDir 'logs\stderr.log'),[IO.FileMode]::CreateNew)
    try {
        $outTask = $process.StandardOutput.BaseStream.CopyToAsync($outStream)
        $errTask = $process.StandardError.BaseStream.CopyToAsync($errStream)
        Save-RunState
        while (-not $process.WaitForExit(1000)) {
            # State persists while the outer agent polls logs and gives progress updates.
        }
    $outTask.GetAwaiter().GetResult() | Out-Null
    $errTask.GetAwaiter().GetResult() | Out-Null
    } finally { $outStream.Dispose(); $errStream.Dispose() }
    $record.exit_code = $process.ExitCode
    $record.stdout = 'logs/stdout.log'; $record.stderr = 'logs/stderr.log'
    $matlabStatePath = Join-Path $runDir 'matlab_status.json'
    if ($process.ExitCode -ne 0) { $record.status = 'FAIL' }
    elseif (Test-Path -LiteralPath $matlabStatePath) {
        $matlabState = Get-Content -LiteralPath $matlabStatePath -Raw | ConvertFrom-Json
        $record.status = $matlabState.status; $record.validation = $matlabState.validation
    } else { $record.status = 'COMPLETED_UNVALIDATED' }
} catch {
    $record.status = 'FAIL'
    $record.exception = $_.Exception.ToString()
    $record.powershell_error = ($_ | Format-List * -Force | Out-String)
} finally {
    $record.finished_utc = [DateTimeOffset]::UtcNow.ToString('o')
    $record.outputs = @(Get-ChildItem -LiteralPath "$runDir\output" -File | Select-Object Name,Length)
    Save-RunState
}
[pscustomobject]$record
