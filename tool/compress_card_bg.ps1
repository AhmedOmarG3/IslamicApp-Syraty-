# Compresses the home-screen card background JPGs in place.
#
# Uses System.Drawing, which ships with Windows, so no Pillow install is needed.
#
#   .\tool\compress_card_bg.ps1           # dry run, reports savings only
#   .\tool\compress_card_bg.ps1 -Apply    # rewrites the files
#
# The cards render at roughly 400x148 logical px under a 0.88-0.94 alpha
# gradient overlay, so the photo is only faintly visible. 1200px covers a
# 3x-density phone width with room to spare.

param([switch]$Apply)

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$root    = Join-Path $PSScriptRoot '..\assets\images'
$maxEdge = 1200
$quality = 85

$images = @(
  'evening_card_bg.jpg',
  'favorites_card_bg.jpg',
  'hisn_card_bg.jpg',
  'morning_card_bg.jpg',
  'quran_card_bg.jpg',
  'zakat_card_bg.jpg'
)

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
  Where-Object { $_.MimeType -eq 'image/jpeg' }

if (-not $encoder) { throw 'No JPEG encoder available.' }

$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters 1
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
  [System.Drawing.Imaging.Encoder]::Quality, [int]$quality)

$totalBefore = 0
$totalAfter  = 0

foreach ($name in $images) {
  $path = Join-Path $root $name
  if (-not (Test-Path $path)) { Write-Host "MISSING $name"; continue }

  $before = (Get-Item $path).Length
  $totalBefore += $before

  $img = [System.Drawing.Image]::FromFile($path)
  try {
    $w = $img.Width
    $h = $img.Height

    $scale = [Math]::Min(1.0, $maxEdge / [Math]::Max($w, $h))
    $nw = [int][Math]::Round($w * $scale)
    $nh = [int][Math]::Round($h * $scale)

    $bmp = New-Object System.Drawing.Bitmap $nw, $nh
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($img, 0, 0, $nw, $nh)
    $g.Dispose()
    $img.Dispose()   # release the file handle so -Apply can overwrite in place

    if ($Apply) {
      $bmp.Save($path, $encoder, $encoderParams)
      $after = (Get-Item $path).Length
    }
    else {
      $tmp = "$path.tmp"
      $bmp.Save($tmp, $encoder, $encoderParams)
      $after = (Get-Item $tmp).Length
      Remove-Item $tmp -Force
    }
    $bmp.Dispose()

    $totalAfter += $after
    $pct = [Math]::Round(100 * (1 - $after / $before), 1)
    Write-Host ('{0,-26} {1}x{2} -> {3}x{4}   {5,8:N1} KB -> {6,8:N1} KB   ({7}% smaller)' -f `
        $name, $w, $h, $nw, $nh, ($before / 1KB), ($after / 1KB), $pct)
  }
  finally {
    $img.Dispose()
  }
}

Write-Host ('-' * 84)
Write-Host ('{0,-26} {1,8:N2} MB -> {2,8:N2} MB   saved {3:N2} MB' -f `
    'TOTAL', ($totalBefore / 1MB), ($totalAfter / 1MB), (($totalBefore - $totalAfter) / 1MB))

if (-not $Apply) {
  Write-Host '(dry run - nothing was written; re-run with -Apply to rewrite the files)'
}
