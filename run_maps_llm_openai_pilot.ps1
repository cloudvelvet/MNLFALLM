param(
  [int]$Limit = 3,
  [string]$Model = $(if ($env:OPENAI_MODEL) { $env:OPENAI_MODEL } else { "gpt-4o-mini" }),
  [double]$SleepSeconds = 0.25
)

$ErrorActionPreference = "Stop"

$apiKey = $env:OPENAI_API_KEY
if (-not $apiKey) {
  Write-Error "OPENAI_API_KEY is not set; no paid API call was made."
}

$outDir = Join-Path $PSScriptRoot "llm_dif_output"
$promptPath = Join-Path $outDir "maps_llm_pilot_prompts_30.jsonl"
if (-not (Test-Path $promptPath)) {
  Write-Error "Missing prompt file: $promptPath. Run maps_llm_build_pilot_prompts.R first."
}

$safeModel = $Model -replace '[^A-Za-z0-9_.-]', '_'
$resultPath = Join-Path $outDir "maps_llm_openai_pilot_results_${safeModel}_n${Limit}.jsonl"
$rows = Get-Content -Path $promptPath -Encoding UTF8 | Where-Object { $_.Trim().Length -gt 0 } | Select-Object -First $Limit

$headers = @{
  "Authorization" = "Bearer $apiKey"
  "Content-Type"  = "application/json; charset=utf-8"
}

if (Test-Path $resultPath) {
  Remove-Item -LiteralPath $resultPath
}

$i = 0
foreach ($line in $rows) {
  $i += 1
  $row = $line | ConvertFrom-Json
  $body = @{
    model = $Model
    messages = $row.messages
    temperature = 0
    response_format = @{ type = "json_object" }
  } | ConvertTo-Json -Depth 20

  try {
    $resp = Invoke-RestMethod `
      -Uri "https://api.openai.com/v1/chat/completions" `
      -Method Post `
      -Headers $headers `
      -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) `
      -ContentType "application/json; charset=utf-8" `
      -TimeoutSec 120

    $record = [ordered]@{
      custom_id = $row.custom_id
      model = $Model
      content = $resp.choices[0].message.content
      raw_response = $resp
    }
    Write-Host "[$i/$($rows.Count)] ok $($row.custom_id)"
  }
  catch {
    $record = [ordered]@{
      custom_id = $row.custom_id
      model = $Model
      error = $_.Exception.GetType().FullName
      message = $_.Exception.Message
    }
    Write-Host "[$i/$($rows.Count)] error $($row.custom_id): $($_.Exception.Message)"
  }

  ($record | ConvertTo-Json -Depth 50 -Compress) | Add-Content -Path $resultPath -Encoding UTF8
  Start-Sleep -Seconds $SleepSeconds
}

Write-Host "Saved: $resultPath"

