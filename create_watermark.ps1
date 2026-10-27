Add-Type -AssemblyName System.Drawing

$w = 210
$h = 62
$bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)

$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.Clear([System.Drawing.Color]::Transparent)

# 1. Top Pill: right-aligned or left-aligned?
# If the watermark is snapped to the bottom-right corner, aligning the pill to the right or left:
# Align pill nicely:
$pillW = 142
$pillH = 24
$pillX = $w - $pillW - 2 # flush to right
$pillY = 2
$pillR = 6

$pillPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$pillRect = New-Object System.Drawing.Rectangle($pillX, $pillY, $pillW, $pillH)
$pillPath.AddArc($pillRect.X, $pillRect.Y, $pillR, $pillR, 180, 90)
$pillPath.AddArc(($pillRect.Right - $pillR), $pillRect.Y, $pillR, $pillR, 270, 90)
$pillPath.AddArc(($pillRect.Right - $pillR), ($pillRect.Bottom - $pillR), $pillR, $pillR, 0, 90)
$pillPath.AddArc($pillRect.X, ($pillRect.Bottom - $pillR), $pillR, $pillR, 90, 90)
$pillPath.CloseFigure()

# Translucent backing
$pillBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120, 255, 255, 255))
$g.FillPath($pillBrush, $pillPath)

# Pill text: "Full HD"
$pillFont = New-Object System.Drawing.Font("Arial", 10.5, [System.Drawing.FontStyle]::Bold)
$pillTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 20, 20, 20))
$g.DrawString("Full HD", $pillFont, $pillTextBrush, ($pillX + 8), ($pillY + 4))

# Vector Play Store triangle ▶
$triX = $pillX + 76
$triY = $pillY + 6
$p1 = New-Object System.Drawing.Point(($triX), ($triY))
$p2 = New-Object System.Drawing.Point(($triX), ($triY + 11))
$p3 = New-Object System.Drawing.Point(($triX + 9), ($triY + 5))
$triBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 25, 25, 25))
$g.FillPolygon($triBrush, @($p1, $p2, $p3))

# Vector Apple Icon 
$appleX = $triX + 22
$appleY = $triY + 2
$g.FillEllipse($triBrush, ($appleX), ($appleY), 8, 9)
$g.FillEllipse($triBrush, ($appleX + 3), ($appleY), 8, 9)
$g.FillEllipse($triBrush, ($appleX + 4), ($appleY - 3), 4, 3)

# 2. Bottom Text: "SL CAT STATUS" flush right and bottom
$statusFont = New-Object System.Drawing.Font("Arial", 16.5, [System.Drawing.FontStyle]::Bold)

# Right-aligned text position
$textX = $w - 202
$textY = 32

# Drop shadow
$shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 0, 0, 0))
$g.DrawString("SL CAT STATUS", $statusFont, $shadowBrush, ($textX + 1), ($textY + 1))
$g.DrawString("SL CAT STATUS", $statusFont, $shadowBrush, ($textX + 2), ($textY + 2))

# Main white text
$textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 255, 255, 255))
$g.DrawString("SL CAT STATUS", $statusFont, $textBrush, $textX, $textY)

$targetDir = "C:\Users\punsi\.gemini\antigravity\scratch\sl_cat_status\assets\images"
$outPath = Join-Path $targetDir "sl_cat_watermark.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

$brainPath = "C:\Users\punsi\.gemini\antigravity\brain\d790ad7d-0c10-420b-8532-015ae0ed48b5\sl_cat_watermark.png"
$bmp.Save($brainPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
Write-Output "SUCCESS: Regenerated snug watermark!"
