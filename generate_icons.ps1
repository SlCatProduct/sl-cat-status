param (
    [Parameter(Mandatory=$true)]
    [string]$SourceImage
)

Add-Type -AssemblyName System.Drawing

function Resize-Image {
    param (
        [System.Drawing.Image]$Image,
        [int]$Width,
        [int]$Height,
        [string]$TargetPath
    )

    $destRect = New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)
    $destImage = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

    $graphics = [System.Drawing.Graphics]::FromImage($destImage)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $graphics.DrawImage($Image, $destRect, 0, 0, $Image.Width, $Image.Height, [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()

    $dir = [System.IO.Path]::GetDirectoryName($TargetPath)
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }

    $destImage.Save($TargetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $destImage.Dispose()
    Write-Host "Generated: $TargetPath ($Width x $Height)"
}

$src = [System.Drawing.Image]::FromFile($SourceImage)

# 1. Android Mipmaps
$androidBase = "C:\Users\punsi\.gemini\antigravity\scratch\sl_cat_status\android\app\src\main\res"
Resize-Image -Image $src -Width 48 -Height 48 -TargetPath "$androidBase\mipmap-mdpi\ic_launcher.png"
Resize-Image -Image $src -Width 72 -Height 72 -TargetPath "$androidBase\mipmap-hdpi\ic_launcher.png"
Resize-Image -Image $src -Width 96 -Height 96 -TargetPath "$androidBase\mipmap-xhdpi\ic_launcher.png"
Resize-Image -Image $src -Width 144 -Height 144 -TargetPath "$androidBase\mipmap-xxhdpi\ic_launcher.png"
Resize-Image -Image $src -Width 192 -Height 192 -TargetPath "$androidBase\mipmap-xxxhdpi\ic_launcher.png"

# 2. iOS AppIcons
$iosBase = "C:\Users\punsi\.gemini\antigravity\scratch\sl_cat_status\ios\Runner\Assets.xcassets\AppIcon.appiconset"
Resize-Image -Image $src -Width 1024 -Height 1024 -TargetPath "$iosBase\Icon-App-1024x1024@1x.png"
Resize-Image -Image $src -Width 20 -Height 20 -TargetPath "$iosBase\Icon-App-20x20@1x.png"
Resize-Image -Image $src -Width 40 -Height 40 -TargetPath "$iosBase\Icon-App-20x20@2x.png"
Resize-Image -Image $src -Width 60 -Height 60 -TargetPath "$iosBase\Icon-App-20x20@3x.png"
Resize-Image -Image $src -Width 29 -Height 29 -TargetPath "$iosBase\Icon-App-29x29@1x.png"
Resize-Image -Image $src -Width 58 -Height 58 -TargetPath "$iosBase\Icon-App-29x29@2x.png"
Resize-Image -Image $src -Width 87 -Height 87 -TargetPath "$iosBase\Icon-App-29x29@3x.png"
Resize-Image -Image $src -Width 40 -Height 40 -TargetPath "$iosBase\Icon-App-40x40@1x.png"
Resize-Image -Image $src -Width 80 -Height 80 -TargetPath "$iosBase\Icon-App-40x40@2x.png"
Resize-Image -Image $src -Width 120 -Height 120 -TargetPath "$iosBase\Icon-App-40x40@3x.png"
Resize-Image -Image $src -Width 120 -Height 120 -TargetPath "$iosBase\Icon-App-60x60@2x.png"
Resize-Image -Image $src -Width 180 -Height 180 -TargetPath "$iosBase\Icon-App-60x60@3x.png"
Resize-Image -Image $src -Width 76 -Height 76 -TargetPath "$iosBase\Icon-App-76x76@1x.png"
Resize-Image -Image $src -Width 152 -Height 152 -TargetPath "$iosBase\Icon-App-76x76@2x.png"
Resize-Image -Image $src -Width 167 -Height 167 -TargetPath "$iosBase\Icon-App-83.5x83.5@2x.png"

# 3. Asset directory
Resize-Image -Image $src -Width 512 -Height 512 -TargetPath "C:\Users\punsi\.gemini\antigravity\scratch\sl_cat_status\assets\images\app_logo.png"

$src.Dispose()
Write-Host "All Android and iOS icons generated successfully!"
