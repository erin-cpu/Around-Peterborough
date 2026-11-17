# Builds docs/index.html (a standalone page) from src/page.html.
#
# src/page.html is the page as the Claude artifact viewer serves it: no
# <!doctype>, <html>, <head> or <body>, because the viewer supplies those.
# This script wraps it in a real document so the same source also works as a
# plain static site (GitHub Pages, any web server, or opened from disk).
#
#   pwsh ./build.ps1        # or:  powershell -File .\build.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src  = Join-Path $root 'src\page.html'
$out  = Join-Path $root 'docs\index.html'

if (-not (Test-Path $src)) { throw "Missing source page: $src" }
$page = Get-Content -Raw -Encoding UTF8 $src

# The <title> and the Google Fonts links belong in <head>, so lift them out.
$title = [regex]::Match($page, '(?s)<title>(.*?)</title>').Groups[1].Value
if (-not $title) { $title = 'Peterborough Holiday Happenings' }
$links = @([regex]::Matches($page, '(?m)^[ \t]*<link rel="(?:preconnect|stylesheet)"[^>]*>[ \t]*$') |
           ForEach-Object { $_.Value.Trim() })

$body = $page
$body = [regex]::Replace($body, '(?s)<title>.*?</title>[ \t]*\r?\n?', '')
# viewport-fit-sides is a hint to the artifact viewer only.
$body = [regex]::Replace($body, '(?m)^[ \t]*<meta name="claude:viewport-fit-sides"[^>]*>[ \t]*\r?\n?', '')
foreach ($l in $links) { $body = $body.Replace($l, '') }

$desc = 'Calendar, downtown map and shop guide to the 2026 holiday season in Peterborough, New Hampshire.'
$linkBlock = $links -join "`n"

$head = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>$title</title>
<meta name="description" content="$desc">
<meta name="theme-color" content="#102B22">
<meta property="og:type" content="website">
<meta property="og:title" content="$title">
<meta property="og:description" content="$desc">
$linkBlock
<style>
  /* Equivalent of the reset the Claude artifact viewer applies. */
  :root{
    color-scheme:light;
    padding-top:env(safe-area-inset-top,0px);
    padding-bottom:env(safe-area-inset-bottom,0px);
  }
  body{margin:0;font:14px system-ui,-apple-system,"Segoe UI",sans-serif}
  img{max-width:100%}
  [hidden]{display:none!important}
</style>
</head>
<body>
"@

$tail = "`n</body>`n</html>`n"

New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null
Set-Content -Path $out -Value ($head + $body.Trim() + $tail) -Encoding utf8
Write-Host "Built $out ($([math]::Round((Get-Item $out).Length / 1KB)) KB)"
