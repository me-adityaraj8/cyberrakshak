package `in`.iiitbh.cyberrakshak

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Receives text from other apps: "Share" from WhatsApp or SMS, and the
 * "Check with CyberRakshak" item in the text-selection menu. The text is
 * handed to Flutter, which checks it straight away.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var pending: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pending = textFrom(intent)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cyberrakshak/share").also {
            it.setMethodCallHandler { call, result ->
                if (call.method == "initial") {
                    result.success(pending)
                    pending = null
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        textFrom(intent)?.let { channel?.invokeMethod("shared", it) }
    }

    private fun textFrom(intent: Intent?): String? {
        val text = when (intent?.action) {
            Intent.ACTION_SEND -> intent.getStringExtra(Intent.EXTRA_TEXT)
            Intent.ACTION_PROCESS_TEXT -> intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
            else -> null
        }
        return text?.trim()?.takeIf { it.isNotEmpty() }
    }
}
