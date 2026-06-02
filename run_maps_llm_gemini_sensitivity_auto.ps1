param(
  [string[]]$PromptVersions = @("original"),
  [int]$Start = 1,
  [int]$End = 105,
  [int]$ChunkSize = 35,
  [string]$Model = "gemini-2.5-flash",
  [double]$SleepSeconds = 120,
  [int]$RateLimitBaseSeconds = 600,
  [int]$RateLimitMaxSeconds = 1800,
  [int]$MaxRetries = 8,
  [int]$PauseBetweenChunksSeconds = 300,
  [int]$MaxChunksThisRun = 0,
  [switch]$ParseAfterEachChunk,
  [switch]$EvaluateAfterEachChunk
)

$ErrorActionPreference = "Stop"

$validVersions = @("original", "strict_dif", "response_process")
foreach ($version in $PromptVersions) {
  if ($validVersions -notcontains $version) {
    Write-Error "Invalid PromptVersion '$version'. Use one of: $($validVersions -join ', ')"
  }
}

if ($ChunkSize -lt 1) {
  Write-Error "ChunkSize must be >= 1."
}
if ($Start -lt 1 -or $End -lt $Start) {
  Write-Error "Invalid Start/End. Start=$Start End=$End"
}

$runner = Join-Path $PSScriptRoot "run_maps_llm_gemini_sensitivity.ps1"
if (-not (Test-Path $runner)) {
  Write-Error "Missing runner: $runner"
}

$chunkCount = 0

foreach ($version in $PromptVersions) {
  Write-Host ""
  Write-Host "=== PromptVersion: $version ==="

  $chunkStart = $Start
  while ($chunkStart -le $End) {
    $chunkEnd = [Math]::Min($End, $chunkStart + $ChunkSize - 1)
    $chunkCount += 1

    if ($MaxChunksThisRun -gt 0 -and $chunkCount -gt $MaxChunksThisRun) {
      Write-Host "MaxChunksThisRun=$MaxChunksThisRun reached. Stop."
      exit 0
    }

    Write-Host ""
    Write-Host ">>> Running $version chunk $chunkStart-$chunkEnd"

    & powershell -ExecutionPolicy Bypass -File $runner `
      -PromptVersion $version `
      -Start $chunkStart `
      -End $chunkEnd `
      -Model $Model `
      -Resume `
      -SleepSeconds $SleepSeconds `
      -RateLimitBaseSeconds $RateLimitBaseSeconds `
      -RateLimitMaxSeconds $RateLimitMaxSeconds `
      -MaxRetries $MaxRetries

    if ($LASTEXITCODE -ne 0) {
      Write-Error "Runner failed for $version chunk $chunkStart-$chunkEnd."
    }

    if ($ParseAfterEachChunk) {
      Write-Host ">>> Parsing sensitivity results"
      & Rscript (Join-Path $PSScriptRoot "maps_llm_parse_sensitivity_results.R")
    }

    if ($EvaluateAfterEachChunk) {
      Write-Host ">>> Evaluating sensitivity results"
      & Rscript (Join-Path $PSScriptRoot "maps_llm_eval_sensitivity.R")
    }

    if ($chunkEnd -lt $End) {
      Write-Host ">>> Pausing $PauseBetweenChunksSeconds seconds before next chunk"
      Start-Sleep -Seconds $PauseBetweenChunksSeconds
    }

    $chunkStart = $chunkEnd + 1
  }
}

Write-Host ""
Write-Host "All requested chunks completed."
