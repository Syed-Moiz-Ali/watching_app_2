package com.example.watching_app_2

import android.app.WallpaperManager
import android.content.ContentValues
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "wallpaper_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // ================= SET WALLPAPER =================
                "setWallpaper" -> {
                    val path = call.argument<String>("path")
                    val location = call.argument<Int>("location") ?: 1

                    if (path == null) {
                        result.error("INVALID_PATH", "Path is null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val bitmap =
                            BitmapFactory.decodeFile(File(path).absolutePath)
                        val manager = WallpaperManager.getInstance(this)

                        when (location) {
                            1 -> manager.setBitmap(
                                bitmap,
                                null,
                                true,
                                WallpaperManager.FLAG_SYSTEM
                            )
                            2 -> if (Build.VERSION.SDK_INT >= 24) {
                                manager.setBitmap(
                                    bitmap,
                                    null,
                                    true,
                                    WallpaperManager.FLAG_LOCK
                                )
                            }
                            3 -> {
                                manager.setBitmap(
                                    bitmap,
                                    null,
                                    true,
                                    WallpaperManager.FLAG_SYSTEM
                                )
                                if (Build.VERSION.SDK_INT >= 24) {
                                    manager.setBitmap(
                                        bitmap,
                                        null,
                                        true,
                                        WallpaperManager.FLAG_LOCK
                                    )
                                }
                            }
                        }

                        result.success(true)
                    } catch (e: Exception) {
                        result.error("WALLPAPER_ERROR", e.message, null)
                    }
                }

                // ================= SAVE TO GALLERY =================
                "saveToGallery" -> {
                    val path = call.argument<String>("path")
                    val name = call.argument<String>("name") ?: "wallpaper"

                    if (path == null) {
                        result.error("INVALID_PATH", "Path is null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val resolver = contentResolver

                        val values = ContentValues().apply {
                            put(
                                MediaStore.Images.Media.DISPLAY_NAME,
                                "${name}_${System.currentTimeMillis()}.jpg"
                            )
                            put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                            put(
                                MediaStore.Images.Media.RELATIVE_PATH,
                                Environment.DIRECTORY_PICTURES + "/Wallpapers"
                            )
                        }

                        val uri = resolver.insert(
                            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                            values
                        )

                        val input = FileInputStream(File(path))
                        val output: OutputStream? =
                            resolver.openOutputStream(uri!!)

                        input.copyTo(output!!)
                        input.close()
                        output.close()

                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
