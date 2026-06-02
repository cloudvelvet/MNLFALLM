param(
  [ValidateSet("original", "strict_dif", "response_process")]
  [string]$PromptVersion = "original",
  [int]$Start = 1,
  [int]$End = 0,
  [int]$Limit = 0,
  [string]$Model = "gemini-2.5-flash",
  [double]$SleepSeconds = 240,
  [int]$MaxRetries = 8,
  [int]$RateLimitBaseSeconds = 600,
  [int]$RateLimitMaxSeconds = 1800,
  [switch]$Resume,
  [switch]$Overwrite
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
$promptPath = Join-Path $outDir "maps_llm_sensitivity_prompts_${PromptVersion}.jsonl"
if (-not (Test-Path $promptPath)) {
  Write-Error "Missing prompt file: $promptPath. Run maps_llm_build_sensitivity_prompts.R first."
}

$allRows = @(Get-Content -Path $promptPath -Encoding UTF8 | Where-Object { $_.Trim().Length -gt 0 })
$total = $allRows.Count
if ($End -le 0 -or $End -gt $total) {
  $End = $total
}
if ($Start -lt 1 -or $Start -gt $End) {
  Write-Error "Invalid Start/End. Start=$Start End=$End Total=$total"
}

$rows = @($allRows[($Start - 1)..($End - 1)])
if ($Limit -gt 0 -and $Limit -lt $rows.Count) {
  $rows = @($rows | Select-Object -First $Limit)
}

$safeModel = $Model -replace '[^A-Za-z0-9_.-]', '_'
$resultPath = Join-Path $outDir "maps_llm_gemini_sensitivity_${PromptVersion}_${safeModel}.jsonl"

if ((Test-Path $resultPath) -and $Overwrite) {
  Remove-Item -LiteralPath $resultPath
}
if ((Test-Path $resultPath) -and -not $Resume -and -not $Overwrite) {
  Write-Error "Result file already exists: $resultPath. Use -Resume to continue or -Overwrite to restart."
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
  $globalIndex = $Start + $i - 1

  if ($completed.ContainsKey($row.custom_id)) {
    Write-Host "[$i/$($rows.Count) global=$globalIndex] skip $($row.custom_id) already completed"
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
        prompt_version = $PromptVersion
        item_order = $row.item_order
        respondent_type = $row.respondent_type
        scale_id = $row.scale_id
        item_id = $row.item_id
        model = $Model
        attempts = $attempt
        content = $content
        raw_response = $resp
      }
      Write-Host "[$i/$($rows.Count) global=$globalIndex] ok $($row.custom_id) attempt=$attempt"
      $done = $true
    }
    catch {
      $statusCode = $null
      if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
        $statusCode = [int]$_.Exception.Response.StatusCode
      }
      $record = [ordered]@{
        custom_id = $row.custom_id
        prompt_version = $PromptVersion
        item_order = $row.item_order
        respondent_type = $row.respondent_type
        scale_id = $row.scale_id
        item_id = $row.item_id
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
        Write-Host "[$i/$($rows.Count) global=$globalIndex] retry $($row.custom_id): $($_.Exception.Message); waiting ${wait}s"
        Start-Sleep -Seconds $wait
      } else {
        Write-Host "[$i/$($rows.Count) global=$globalIndex] error $($row.custom_id): $($_.Exception.Message)"
        $done = $true
      }
    }
  }

  ($record | ConvertTo-Json -Depth 50 -Compress) | Add-Content -Path $resultPath -Encoding UTF8
  Start-Sleep -Seconds $SleepSeconds
}

Write-Host "Saved: $resultPath"
