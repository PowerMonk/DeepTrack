package com.example.frontend

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "deeptrack/usage_stats"
    
    private val socialMediaApps = mapOf(
        "com.instagram.android" to "Instagram",
        "com.zhiliaoapp.musically" to "TikTok",
        "com.twitter.android" to "Twitter",
        "com.google.android.youtube" to "YouTube"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsageStatsPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    requestUsageStatsPermission()
                    result.success(null)
                }
                "getSocialMediaUsage" -> {
                    val usage = getSocialMediaUsage()
                    result.success(usage)
                }
                "getInstalledSocialApps" -> {
                    val apps = getInstalledSocialApps()
                    result.success(apps)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivity(intent)
    }

    private fun getSocialMediaUsage(): Map<String, Double> {
        if (!hasUsageStatsPermission()) {
            return emptyMap()
        }

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        val endTime = calendar.timeInMillis
        calendar.add(Calendar.DAY_OF_YEAR, -1)
        val startTime = calendar.timeInMillis

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val socialUsage = mutableMapOf<String, Double>()
        
        for ((packageName, appName) in socialMediaApps) {
            val appStats = stats.find { it.packageName == packageName }
            if (appStats != null && isAppInstalled(packageName)) {
                val hours = appStats.totalTimeInForeground / (1000.0 * 60.0 * 60.0)
                socialUsage[appName] = hours
            }
        }

        return socialUsage
    }

    private fun getInstalledSocialApps(): List<String> {
        val installedApps = mutableListOf<String>()
        
        for ((packageName, appName) in socialMediaApps) {
            if (isAppInstalled(packageName)) {
                installedApps.add(appName)
            }
        }
        
        return installedApps
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
}
