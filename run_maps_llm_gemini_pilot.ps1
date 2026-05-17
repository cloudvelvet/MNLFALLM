param(
  [int]$Limit = 3,
  [string]$Model = "gemini-2.5-flash",
  [double]$SleepSeconds = 60,
  [int]$MaxRetries = 8,
  [int]$RateLimitBaseSeconds = 60,
  [int]$RateLimitMaxSeconds = 300,
  [switch]$Resume
)

$ErrorActionPreference = "Stop"

$apiKey = $env:GEMINI_API_KEY
if (-not $apiKey) {
  $apiKey = $env:GOOGLE_API_KEY
}
if (-not $apiKey) {
  Write-Error "GEMINI_API_KEY or GOOGLE_API_KEY is not set; no API call was made."
}

$outDir = Join-Path $PSScriptRoot "llm_dif_output"
$promptPath = Join-Path $outDir "maps_llm_pilot_prompts_30.jsonl"
if (-not (Test-Path $promptPath)) {
  Write-Error "Missing prompt file: $promptPath. Run maps_llm_build_pilot_prompts.R first."
}

$safeModel = $Model -replace '[^A-Za-z0-9_.-]', '_'
$resultPath = Join-Path $outDir "maps_llm_gemini_pilot_results_${safeModel}_n${Limit}.jsonl"
$rows = Get-Content -Path $promptPath -Encoding UTF8 | Where-Object { $_.Trim().Length -gt 0 } | Select-Object -First $Limit

if ((Test-Path $resultPath) -and -not $Resume) {
  Remove-Item -LiteralPath $resultPath
}

$completed = @{}
if ((Test-Path $resultPath) -and $Resume) {
  Get-Content -Path $resultPath -Encoding UTF8 | ForEach-Object {
    if ($_.Trim().Length -gt 0) {
      try {
        $rec = $_ | ConvertFrom-Json
        if ($rec.content) {
          $completed[$rec.custom_id] = $true
        }
      } catch {
        # Ignore malformed old lines.
      }
    }
  }
  Write-Host "Resume mode: found $($completed.Count) completed rows in $resultPath"
}

$uri = "https://generativelanguage.googleapis.com/v1beta/models/${Model}:generateContent?key=$apiKey"
$i = 0
foreach ($line in $rows) {
  $i += 1
  $row = $line | ConvertFrom-Json
  if ($completed.ContainsKey($row.custom_id)) {
    Write-Host "[$i/$($rows.Count)] skip $($row.custom_id) already completed"
    continue
  }
  $systemText = (($row.messages | Where-Object { $_.role -eq "system" } | Select-Object -First 1).content)
  $userText = (($row.messages | Where-Object { $_.role -eq "user" } | Select-Object -First 1).content)

  $body = @{
    systemInstruction = @{
      parts = @(@{ text = $systemText })
    }
    contents = @(
      @{
        role = "user"
        parts = @(@{ text = $userText })
      }
    )
    generationConfig = @{
      temperature = 0
      responseMimeType = "application/json"
    }
  } | ConvertTo-Json -Depth 30

  $attempt = 0
  $done = $false
  while (-not $done -and $attempt -le $MaxRetries) {
    $attempt += 1
    try {
      $resp = Invoke-RestMethod `
        -Uri $uri `
        -Method Post `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) `
        -ContentType "application/json; charset=utf-8" `
        -TimeoutSec 120

      $content = $resp.candidates[0].content.parts[0].text
      $record = [ordered]@{
        custom_id = $row.custom_id
        model = $Model
        attempts = $attempt
        content = $content
        raw_response = $resp
      }
      Write-Host "[$i/$($rows.Count)] ok $($row.custom_id) attempt=$attempt"
      $done = $true
    }
    catch {
      $statusCode = $null
      if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
        $statusCode = [int]$_.Exception.Response.StatusCode
      }
      $record = [ordered]@{
        custom_id = $row.custom_id
        model = $Model
        attempts = $attempt
        error = $_.Exception.GetType().FullName
        status_code = $statusCode
        message = $_.Exception.Message
      }
      if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
        $record.error_details = $_.ErrorDetails.Message
      }

      $retryable = ($statusCode -in @(429, 500, 502, 503, 504)) -or ($_.Exception.Message -match "503|429|temporar|timeout")
      if ($retryable -and $attempt -le $MaxRetries) {
        $wait = if ($statusCode -eq 429 -or $_.Exception.Message -match "429") {
          [Math]::Min($RateLimitMaxSeconds, $RateLimitBaseSeconds * $attempt)
        } else {
          [Math]::Min(60, [Math]::Pow(2, $attempt))
        }
        Write-Host "[$i/$($rows.Count)] retry $($row.custom_id): $($_.Exception.Message); waiting ${wait}s"
        Start-Sleep -Seconds $wait
      } else {
        Write-Host "[$i/$($rows.Count)] error $($row.custom_id): $($_.Exception.Message)"
        $done = $true
      }
    }
  }

  ($record | ConvertTo-Json -Depth 50 -Compress) | Add-Content -Path $resultPath -Encoding UTF8
  Start-Sleep -Seconds $SleepSeconds
}

Write-Host "Saved: $resultPath"
