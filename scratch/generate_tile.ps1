Add-Type -AssemblyName System.Drawing

$size = 104
$bmp = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

# Alpha 28 (around 11% opacity) mint/sage color #8DCFB8
$penColor = [System.Drawing.Color]::FromArgb(26, 141, 207, 184)
$pen = New-Object System.Drawing.Pen $penColor, 1.2

function Draw-Octagram($cx, $cy, $s) {
    $outerR = $s * 0.44
    $innerR = $s * 0.31
    $points = New-Object System.Drawing.PointF[] 16
    for ($i = 0; $i -lt 16; $i++) {
        $r = if ($i % 2 -eq 0) { $outerR } else { $innerR }
        $angle = ($i * [Math]::PI / 8) - ([Math]::PI / 2)
        $x = $cx + $r * [Math]::Cos($angle)
        $y = $cy + $r * [Math]::Sin($angle)
        $points[$i] = New-Object System.Drawing.PointF ([float]$x), ([float]$y)
    }
    $g.DrawPolygon($pen, $points)
    $cr = [float]($s * 0.12)
    $g.DrawEllipse($pen, [float]($cx - $cr), [float]($cy - $cr), [float]($cr * 2), [float]($cr * 2))
}

# 1. Square grid border
$g.DrawRectangle($pen, 0, 0, $size, $size)

# 2. Center Octagram
Draw-Octagram 52 52 $size

# 3. Corner Octagrams (for seamless tiling across boundaries)
Draw-Octagram 0 0 $size
Draw-Octagram $size 0 $size
Draw-Octagram 0 $size $size
Draw-Octagram $size $size $size

$outPath = "d:\Flutter_Projects\siraty\android\app\src\main\res\drawable\islamic_tile_pattern.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
$pen.Dispose()
Write-Output "Created: $outPath"
