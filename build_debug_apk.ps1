# VitaCase Debug APK Build Script
# Automates: Flutter Clean, Pub Get, Debug APK Build, and Path Mirroring.

$ErrorActionPreference = "Stop"

# --- CONFIGURATION ---
$APK_NAME = "app-debug.apk"
$APK_FINAL_PATH = "build/app/outputs/flutter-apk/$APK_NAME"

# --- 1. CLEANUP & PREP ---
Write-Host "`n[1/2] Cleaning project and preparing dependencies..." -ForegroundColor Cyan
if (Test-Path "build") { Remove-Item -Path "build" -Recurse -Force -ErrorAction Ignore }
flutter clean
flutter pub get

# --- 2. BUILD DEBUG APK ---
Write-Host "`n[2/2] Building Android Debug APK..." -ForegroundColor Cyan
if (Test-Path "build.env") {
    flutter build apk --debug --dart-define-from-file=build.env
} else {
    Write-Warning "build.env not found! Building with default environment settings."
    flutter build apk --debug
}

# --- 3. PATH MIRRORING & FIX FOR FLUTTER GRADLE CLI PATHS ---
if (-not (Test-Path $APK_FINAL_PATH)) {
    Write-Host "Locating APK in Android build output directory..." -ForegroundColor Yellow
    $FoundAPK = Get-ChildItem -Path "android/app/build/outputs" -Filter "app-debug.apk" -Recurse | Select-Object -First 1
    if ($FoundAPK) {
        Write-Host "Found APK at: $($FoundAPK.FullName)" -ForegroundColor Green
        if (-not (Test-Path "build/app/outputs/flutter-apk")) {
            New-Item -ItemType Directory -Force -Path "build/app/outputs/flutter-apk" | Out-Null
        }
        Copy-Item -Path $FoundAPK.FullName -Destination $APK_FINAL_PATH -Force
    } else {
        Write-Error "Debug APK build failed! Could not locate app-debug.apk"
    }
}

# Also ensure standard apk/debug directory has a copy
if (-not (Test-Path "build/app/outputs/apk/debug")) {
    New-Item -ItemType Directory -Force -Path "build/app/outputs/apk/debug" | Out-Null
}
Copy-Item -Path $APK_FINAL_PATH -Destination "build/app/outputs/apk/debug/$APK_NAME" -Force

# --- 4. SUMMARY ---
$FileItem = Get-Item $APK_FINAL_PATH
$SizeMB = [math]::Round($FileItem.Length / 1MB, 2)
Write-Host "`n=======================================================" -ForegroundColor Green
Write-Host " DEBUG APK BUILD COMPLETE SUCCESSFUL! " -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "OUTPUT APK : $APK_FINAL_PATH" -ForegroundColor White
Write-Host "SIZE       : $SizeMB MB ($($FileItem.Length) bytes)" -ForegroundColor White
Write-Host "MODIFIED   : $($FileItem.LastWriteTime)" -ForegroundColor White
Write-Host "=======================================================`n" -ForegroundColor Green
