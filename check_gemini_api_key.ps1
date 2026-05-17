param(
  [string]$Model = "gemini-2.5-flash"
)

$ErrorActionPreference = "Stop"

$apiKey = $env:GEMINI_API_KEY
$keyName = "GEMINI_API_KEY"
if (-not $apiKey) {
  $apiKey = $env:GOOGLE_API_KEY
  $keyName = "GOOGLE_API_KEY"
}

if (-not $apiKey) {
  Write-Host "No Gemini API key found."
  Write-Host "Set one of these in PowerShell:"
  Write-Host '$env:GEMINI_API_KEY = "YOUR_KEY"'
  Write-Host '[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "YOUR_KEY", "User")'
  Write-Host "If you used SetEnvironmentVariable, open a new PowerShell window."
  exit 2
}

$redacted = if ($apiKey.Length -ge 8) {
  $apiKey.Substring(0, 4) + "..." + $apiKey.Substring($apiKey.Length - 4)
} else {
  "set_but_too_short_to_redact"
}
Write-Host "Found $keyName = $redacted"

$uri = "https://generativelanguage.googleapis.com/v1beta/models/${Model}:generateContent?key=$apiKey"
$body = @{
  contents = @(
    @{
      parts = @(
        @{ text = "Reply with exactly: ok" }
      )
    }
  )
  generationConfig = @{
    temperature = 0
    maxOutputTokens = 8
  }
} | ConvertTo-Json -Depth 20

try {
  $resp = Invoke-RestMethod `
    -Uri $uri `
    -Method Post `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) `
    -ContentType "application/json; charset=utf-8" `
    -TimeoutSec 60

  $text = $resp.candidates[0].content.parts[0].text
  Write-Host "Gemini API ping succeeded. Response: $text"
}
catch {
  Write-Host "Gemini API ping failed."
  Write-Host $_.Exception.Message
  if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
    Write-Host $_.ErrorDetails.Message
  }
  exit 1
}

