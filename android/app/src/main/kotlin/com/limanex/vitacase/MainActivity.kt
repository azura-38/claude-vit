package com.limanex.vitacase

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.content.ContentValues
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.OutputStream

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "vitacase/security"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureScreen" -> {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "disableSecureScreen" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "vitacase/downloads"
        ).setMethodCallHandler { call, result ->
            if (call.method == "saveToDownloads") {
                val tempPath = call.argument<String>("tempPath")
                val displayName = call.argument<String>("displayName")
                val mimeType = call.argument<String>("mimeType")

                if (tempPath == null || displayName == null || mimeType == null) {
                    result.error("INVALID_ARGUMENTS", "Missing arguments", null)
                    return@setMethodCallHandler
                }

                try {
                    val savedPath = saveFileToDownloads(tempPath, displayName, mimeType)
                    if (savedPath != null) {
                        result.success(savedPath)
                    } else {
                        result.error("SAVE_FAILED", "Could not save file", null)
                    }
                } catch (e: Exception) {
                    result.error("SAVE_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveFileToDownloads(tempPath: String, displayName: String, mimeType: String): String? {
        val tempFile = File(tempPath)
        if (!tempFile.exists()) return null

        var finalName = displayName
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = contentResolver
            val contentValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, finalName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            }

            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            if (uri != null) {
                resolver.openOutputStream(uri)?.use { outputStream ->
                    FileInputStream(tempFile).use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
                return uri.toString()
            }
        } else {
            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!downloadsDir.exists()) {
                downloadsDir.mkdirs()
            }
            
            var destFile = File(downloadsDir, finalName)
            var counter = 1
            
            val nameWithoutExt = finalName.substringBeforeLast(".")
            val ext = if (finalName.contains(".")) ".${finalName.substringAfterLast(".")}" else ""

            while (destFile.exists()) {
                finalName = "$nameWithoutExt ($counter)$ext"
                destFile = File(downloadsDir, finalName)
                counter++
            }

            FileInputStream(tempFile).use { inputStream ->
                FileOutputStream(destFile).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
            return destFile.absolutePath
        }
        return null
    }
}
