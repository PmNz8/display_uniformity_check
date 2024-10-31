Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Convert-PercentageToRGB {
    param (
        [float]$percentage
    )
    return [math]::Round(255 * $percentage / 100)
}

$primaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen

$screenWidth = $primaryScreen.Bounds.Width
$screenHeight = $primaryScreen.Bounds.Height

$modeIndex = 0
$modes = @("Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "White")
$percentages = 0
$increment = 1

# Initialize text variables
$global:currentModeText = "$($modes[$modeIndex]) 0%"
$global:currentMode = $modes[$modeIndex]
$global:currentPercentage = 0

$form = New-Object System.Windows.Forms.Form
$form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.BackColor = [System.Drawing.Color]::Black
$form.KeyPreview = $true

# Handle the Paint event to draw text with outline
$form.Add_Paint({
    param ($sender, $e)

    $graphics = $e.Graphics
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    # Define fonts and brushes
    $font = New-Object System.Drawing.Font("Arial", 48, [System.Drawing.FontStyle]::Bold)
    $text = $global:currentModeText

    # Define positions
    $x = $screenWidth / 8
    $y = $screenHeight / 8

    # Draw outline by drawing the text multiple times with slight offsets
    $outlineColor = [System.Drawing.Color]::Black
    for ($dx = -2; $dx -le 2; $dx++) {
        for ($dy = -2; $dy -le 2; $dy++) {
            if ($dx -ne 0 -or $dy -ne 0) {
                $outlineBrush = New-Object System.Drawing.SolidBrush($outlineColor)
                $graphics.DrawString($text, $font, $outlineBrush, $x + $dx, $y + $dy)
                $outlineBrush.Dispose()
            }
        }
    }

    # Draw the main text
    $mainColor = [System.Drawing.Color]::Gray
    $mainBrush = New-Object System.Drawing.SolidBrush($mainColor)
    $graphics.DrawString($text, $font, $mainBrush, $x, $y)
    $mainBrush.Dispose()
})

function Update-Form {
    param (
        [string]$mode,
        [int]$percentage
    )

    $script:percentages = 0

    $red = 0
    $green = 0
    $blue = 0

    switch ($mode) {
        "Red" {
            $script:percentages = $percentage 
            $red = Convert-PercentageToRGB $script:percentages
        }
        "Green" {
            $script:percentages = $percentage 
            $green = Convert-PercentageToRGB $script:percentages
        }
        "Blue" {
            $script:percentages = $percentage 
            $blue = Convert-PercentageToRGB $script:percentages
        }
        "Cyan" {
            $script:percentages = $percentage
            $green = Convert-PercentageToRGB $script:percentages
            $blue = Convert-PercentageToRGB $script:percentages
        }
        "Magenta" {
            $script:percentages = $percentage
            $red = Convert-PercentageToRGB $script:percentages
            $blue = Convert-PercentageToRGB $script:percentages
        }
        "Yellow" {
            $script:percentages = $percentage
            $red = Convert-PercentageToRGB $script:percentages
            $green = Convert-PercentageToRGB $script:percentages
        }
        "White" {
            $script:percentages = $percentage
            $red = Convert-PercentageToRGB $script:percentages
            $green = Convert-PercentageToRGB $script:percentages
            $blue = Convert-PercentageToRGB $script:percentages
        }
    }

    $form.BackColor = [System.Drawing.Color]::FromArgb($red, $green, $blue)
    $global:currentModeText = "$mode $percentage`%"

    # Update text color if needed (optional)
    # $label.ForeColor = [System.Drawing.Color]::Gray

    Write-Host "Colors Red: $red Green: $green Blue: $blue"

    # Refresh the form to trigger the Paint event
    $form.Invalidate()
}

$handler = [System.Windows.Forms.KeyEventHandler]{
    param ($sender, $e)
    switch ($e.KeyCode) {
        "X" {
            $form.Close()
        }
        "M" {
            $script:modeIndex = ($script:modeIndex + 1) % $modes.Length
            Update-Form -mode $modes[$script:modeIndex] -percentage 0
        }
        "Up" {
            $currentMode = $modes[$script:modeIndex]
            $currentPercentage = $script:percentages
            $newPercentage = [math]::Min($currentPercentage + $increment, 100)
            Update-Form -mode $currentMode -percentage $newPercentage
        }
        "Down" {
            $currentMode = $modes[$script:modeIndex]
            $currentPercentage = $script:percentages
            $newPercentage = [math]::Max($currentPercentage - $increment, 0)
            Update-Form -mode $currentMode -percentage $newPercentage
        }
    }
}

$form.add_KeyDown($handler)

Update-Form -mode $modes[$modeIndex] -percentage 0

$form.ShowDialog()
