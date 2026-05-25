# VitaCase Ultimate Build & Package Script
# Automates: Flutter Clean, Pub Get, AAB Build, and Selective ZIP Archiving.

$ErrorActionPreference = "Stop"

# --- CONFIGURATION ---
$AAB_NAME = "app-release.aab"
$AAB_SOURCE_DIR = "android/app/build/outputs/bundle/release"
$AAB_FINAL_PATH = "build/app/outputs/bundle/release/$AAB_NAME"
$EXCLUDES = @(
    "build", 
    ".dart_tool", 
    ".git", 
    ".idea", 
    "*.jks", 
    "*.zip", 
    "*.env", 
    ".packages",
    "vitacase_flutter",
    "sentry-wizard.exe",
    ".firebase"
)

# --- 1. CLEANUP & PREP ---
Write-Host "`n[1/2] Cleaning project..." -ForegroundColor Cyan
if (Test-Path "build") { Remove-Item -Path "build" -Recurse -Force -ErrorAction Ignore }
flutter clean
flutter pub get

# --- 2. BUILD AAB ---
Write-Host "`n[2/2] Building Android App Bundle (AAB)..." -ForegroundColor Cyan
if (Test-Path "build.env") {
    flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols --dart-define-from-file=build.env
} else {
    Write-Warning "build.env not found! Building without environment variables."
    flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols
}

# Fix for "Flutter CLI can't find AAB" issue
if (-not (Test-Path $AAB_FINAL_PATH)) {
    Write-Host "Searching for AAB in alternative paths..." -ForegroundColor Yellow
    $FoundAAB = Get-ChildItem -Path "android" -Filter "app-release.aab" -Recurse | Select-Object -First 1
    if ($FoundAAB) {
        Write-Host "Found AAB at: $($FoundAAB.FullName)" -ForegroundColor Green
        if (-not (Test-Path "build/app/outputs/bundle/release")) {
            New-Item -ItemType Directory -Force -Path "build/app/outputs/bundle/release" | Out-Null
        }
        Copy-Item -Path $FoundAAB.FullName -Destination $AAB_FINAL_PATH
    } else {
        Write-Error "AAB build failed! Could not find app-release.aab"
    }
}

# --- 3. SUMMARY ---
Write-Host "`n--- BUILD COMPLETE ---" -ForegroundColor Green
Write-Host "RESULT AAB: $AAB_FINAL_PATH" -ForegroundColor White
Write-Host "-----------------------`n"
