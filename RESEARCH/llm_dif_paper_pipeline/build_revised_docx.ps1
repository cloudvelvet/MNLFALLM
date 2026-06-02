param(
  [string]$TemplateDocx = "RESEARCH\llm_dif_paper_pipeline\outputs\새논문_working.docx",
  [string]$IntroMd = "RESEARCH\llm_dif_paper_pipeline\outputs\introduction_revised3_ko.md",
  [string]$MethodMd = "RESEARCH\llm_dif_paper_pipeline\outputs\method_covariate_baseline_rationale_ko.md",
  [string]$OutDocx = "RESEARCH\llm_dif_paper_pipeline\outputs\새논문_수정본.docx"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Escape-XmlText {
  param([string]$Text)
  if ($null -eq $Text) { return "" }
  $clean = $Text -replace "`t", " " -replace "`r", "" -replace "`n", " "
  $clean = $clean -replace "`u{00A0}", " "
  $clean = $clean -replace "`u{2013}", "-"
  $clean = $clean -replace "`u{2014}", "-"
  $clean = $clean -replace "`u{201C}", '"'
  $clean = $clean -replace "`u{201D}", '"'
  $clean = $clean -replace "`u{2018}", "'"
  $clean = $clean -replace "`u{2019}", "'"
  $clean = $clean -replace '`', ''
  return [System.Security.SecurityElement]::Escape($clean)
}

function Paragraph-Wml {
  param(
    [string]$Text,
    [string]$Kind = "body"
  )
  $escaped = Escape-XmlText $Text
  switch ($Kind) {
    "h1" {
      return '<w:p><w:pPr><w:spacing w:before="280" w:after="180"/><w:outlineLvl w:val="0"/></w:pPr><w:r><w:rPr><w:rFonts w:eastAsia="Malgun Gothic" w:ascii="Arial" w:hAnsi="Arial"/><w:b/><w:sz w:val="32"/></w:rPr><w:t>' + $escaped + '</w:t></w:r></w:p>'
    }
    "h2" {
      return '<w:p><w:pPr><w:spacing w:before="240" w:after="120"/><w:outlineLvl w:val="1"/></w:pPr><w:r><w:rPr><w:rFonts w:eastAsia="Malgun Gothic" w:ascii="Arial" w:hAnsi="Arial"/><w:b/><w:sz w:val="26"/></w:rPr><w:t>' + $escaped + '</w:t></w:r></w:p>'
    }
    default {
      return '<w:p><w:pPr><w:spacing w:before="0" w:after="120" w:line="360" w:lineRule="auto"/><w:jc w:val="both"/></w:pPr><w:r><w:rPr><w:rFonts w:eastAsia="Malgun Gothic" w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:sz w:val="22"/></w:rPr><w:t>' + $escaped + '</w:t></w:r></w:p>'
    }
  }
}

function Cell-Wml {
  param(
    [string]$Text,
    [bool]$Header = $false
  )
  $escaped = Escape-XmlText $Text
  $shade = ""
  $bold = ""
  if ($Header) {
    $shade = '<w:shd w:val="clear" w:color="auto" w:fill="E8EEF7"/>'
    $bold = "<w:b/>"
  }
  return '<w:tc><w:tcPr><w:tcW w:w="0" w:type="auto"/><w:tcMar><w:top w:w="90" w:type="dxa"/><w:left w:w="110" w:type="dxa"/><w:bottom w:w="90" w:type="dxa"/><w:right w:w="110" w:type="dxa"/></w:tcMar>' + $shade + '</w:tcPr><w:p><w:pPr><w:spacing w:after="0"/></w:pPr><w:r><w:rPr><w:rFonts w:eastAsia="Malgun Gothic" w:ascii="Arial" w:hAnsi="Arial"/>' + $bold + '<w:sz w:val="18"/></w:rPr><w:t>' + $escaped + '</w:t></w:r></w:p></w:tc>'
}

function Table-Wml {
  param(
    [string[]]$Headers,
    [object[]]$Rows
  )
  $parts = New-Object System.Collections.Generic.List[string]
  $parts.Add('<w:tbl><w:tblPr><w:tblStyle w:val="TableGrid"/><w:tblW w:w="0" w:type="auto"/><w:tblLook w:val="04A0" w:firstRow="1" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="1"/><w:tblCellMar><w:top w:w="80" w:type="dxa"/><w:left w:w="100" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:right w:w="100" w:type="dxa"/></w:tblCellMar></w:tblPr>')
  $parts.Add('<w:tr>')
  foreach ($h in $Headers) { $parts.Add((Cell-Wml $h $true)) }
  $parts.Add('</w:tr>')
  foreach ($row in $Rows) {
    $parts.Add('<w:tr>')
    foreach ($cell in $row) { $parts.Add((Cell-Wml ([string]$cell) $false)) }
    $parts.Add('</w:tr>')
  }
  $parts.Add('</w:tbl>')
  $parts.Add((Paragraph-Wml "" "body"))
  return ($parts -join "")
}

function Normalize-MethodLines {
  param([string[]]$Lines)
  $out = New-Object System.Collections.Generic.List[string]
  $section = 0
  $methodTitleWritten = $false
  $methodTitle = "# 2. " + [string]::Concat([char[]](0xC5F0, 0xAD6C, 0xBC29, 0xBC95))
  foreach ($line in $Lines) {
    $trimmed = $line.Trim().Trim([char]0xFEFF)
    if (-not $methodTitleWritten -and $trimmed.StartsWith("# ")) {
      $out.Add($methodTitle)
      $methodTitleWritten = $true
      continue
    }
    if ($trimmed -like "# 방법 섹션 초안*" -or $trimmed -like "방법 섹션 초안*") {
      $out.Add($methodTitle)
      $methodTitleWritten = $true
      continue
    }
    if ($trimmed -like "## 2.X *") {
      $section++
      $title = $trimmed -replace "^## 2\.X\s+", ""
      $out.Add(("## 2.{0} {1}" -f $section, $title))
      continue
    }
    $out.Add($line)
  }
  return $out.ToArray()
}

function Blocks-FromMarkdown {
  param([string[]]$Lines)
  $blocks = New-Object System.Collections.Generic.List[object]
  $i = 0
  while ($i -lt $Lines.Count) {
    $line = $Lines[$i].Trim()
    if ($line.Length -eq 0) { $i++; continue }

    if ($line.StartsWith("|")) {
      $tableLines = New-Object System.Collections.Generic.List[string]
      while ($i -lt $Lines.Count -and $Lines[$i].Trim().StartsWith("|")) {
        $tableLines.Add($Lines[$i].Trim())
        $i++
      }
      $rows = @()
      foreach ($tl in $tableLines) {
        if ($tl -match "^\|\s*:?-+:?\s*(\|\s*:?-+:?\s*)+\|?$") { continue }
        $cells = $tl.Trim("|").Split("|") | ForEach-Object { $_.Trim() }
        $rows += ,$cells
      }
      if ($rows.Count -gt 0) {
        $headers = [string[]]$rows[0]
        $bodyRows = @()
        if ($rows.Count -gt 1) { $bodyRows = $rows[1..($rows.Count - 1)] }
        $blocks.Add([pscustomobject]@{ Type = "table"; Headers = $headers; Rows = $bodyRows })
      }
      continue
    }

    if ($line.StartsWith("# ")) {
      $blocks.Add([pscustomobject]@{ Type = "h1"; Text = $line.Substring(2).Trim() })
      $i++
      continue
    }
    if ($line.StartsWith("## ")) {
      $blocks.Add([pscustomobject]@{ Type = "h2"; Text = $line.Substring(3).Trim() })
      $i++
      continue
    }
    if ($line.StartsWith("- ")) {
      $blocks.Add([pscustomobject]@{ Type = "body"; Text = $line.Substring(2).Trim() })
      $i++
      continue
    }

    $blocks.Add([pscustomobject]@{ Type = "body"; Text = $line })
    $i++
  }
  return $blocks
}

$introLines = Get-Content -LiteralPath $IntroMd -Encoding UTF8
$methodLines = Normalize-MethodLines (Get-Content -LiteralPath $MethodMd -Encoding UTF8)
$allLines = @($introLines) + @("") + @($methodLines)
$blocks = Blocks-FromMarkdown $allLines

$bodyParts = New-Object System.Collections.Generic.List[string]
foreach ($block in $blocks) {
  if ($block.Type -eq "table") {
    $bodyParts.Add((Table-Wml $block.Headers $block.Rows))
  } elseif ($block.Type -eq "h1") {
    $bodyParts.Add((Paragraph-Wml $block.Text "h1"))
  } elseif ($block.Type -eq "h2") {
    $bodyParts.Add((Paragraph-Wml $block.Text "h2"))
  } else {
    $bodyParts.Add((Paragraph-Wml $block.Text "body"))
  }
}

$bodyXml = $bodyParts -join ""
$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" mc:Ignorable="w14 wp14">
<w:body>
$bodyXml
<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="708" w:footer="708" w:gutter="0"/><w:cols w:space="708"/><w:docGrid w:linePitch="360"/></w:sectPr>
</w:body>
</w:document>
"@

Copy-Item -LiteralPath $TemplateDocx -Destination $OutDocx -Force
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($OutDocx, [System.IO.Compression.ZipArchiveMode]::Update)
try {
  $entry = $zip.GetEntry("word/document.xml")
  if ($null -ne $entry) { $entry.Delete() }
  $newEntry = $zip.CreateEntry("word/document.xml")
  $stream = $newEntry.Open()
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  $writer = New-Object System.IO.StreamWriter($stream, $utf8NoBom)
  $writer.Write($documentXml)
  $writer.Close()
} finally {
  $zip.Dispose()
}

Write-Output $OutDocx
