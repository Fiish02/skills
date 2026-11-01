#requires -Version 7.0
param([Parameter(Mandatory)][string]$OutFile)
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Run this collector on the Windows execution host.' }
$target = [IO.Path]::GetFullPath($OutFile)
if (Test-Path -LiteralPath $target) { throw 'Output exists; refusing to overwrite.' }
if (-not (Test-Path -LiteralPath (Split-Path $target -Parent))) { throw 'Output parent must exist.' }
$matlabRoot = 'D:\Program Files\MATLAB\R2023a'
$comsolRoot = 'D:\Program Files\COMSOL\COMSOL56\Multiphysics'
$exe = Get-Item -LiteralPath "$comsolRoot\bin\win64\comsol.exe"
$probe = [ordered]@{
    collected_utc = [DateTimeOffset]::UtcNow.ToString('o')
    host_name = $env:COMPUTERNAME
    os_kernel = [Runtime.InteropServices.RuntimeInformation]::OSDescription
    architecture = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
    working_directory = (Get-Location).Path
    ssh_connection_present = [bool]$env:SSH_CONNECTION
    matlab_root = $matlabRoot
    matlab_executable = "$matlabRoot\bin\matlab.exe"
    comsol_root = $comsolRoot
    comsol_file_version = $exe.VersionInfo.FileVersion
    matlab_install_metadata = [IO.File]::ReadAllText("$matlabRoot\VersionInfo.xml")
    processes = @(Get-Process | Where-Object { $_.ProcessName -match 'matlab|comsol' } | Select-Object ProcessName,Id,Path)
    interfaces = @('mphstart.p','mphstart.m','mphload.p','mphsave.p','mphversion.p' | ForEach-Object {
        Get-Item -LiteralPath (Join-Path "$comsolRoot\mli" $_) | Select-Object Name,Length
    })
    runtime_verified_here = $false
}
# No environment dump, Preferences/license/login content, or software startup.
$stream = [IO.File]::Open($target,[IO.FileMode]::CreateNew)
try {
    $bytes = [Text.Encoding]::UTF8.GetBytes(($probe | ConvertTo-Json -Depth 6))
    $stream.Write($bytes,0,$bytes.Length)
} finally { $stream.Dispose() }
$target
