package app.kaywalker.linknote

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Exposes the current Activity intent's share extras to Dart.
 *
 * Why: [receive_sharing_intent] prefers [Intent.EXTRA_STREAM] file path over
 * [Intent.EXTRA_TEXT] when both are present. YouTube's Android share sheet
 * often attaches a thumbnail stream **and** the video URL in EXTRA_TEXT, so
 * the plugin delivers a cache file path and the URL is dropped. This channel
 * lets Flutter fall back to EXTRA_TEXT / EXTRA_SUBJECT.
 */
class MainActivity : FlutterActivity() {
    private val shareChannel = "app.kaywalker.linknote/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shareChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getShareExtras" -> result.success(readShareExtras(intent))
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * singleTop: a new share delivers [onNewIntent]. Without [setIntent],
     * subsequent reads of [intent] (and this channel) still see the old
     * launcher/share payload.
     */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    private fun readShareExtras(intent: Intent?): Map<String, String?> {
        if (intent == null) {
            return mapOf(
                "action" to null,
                "type" to null,
                "text" to null,
                "subject" to null,
                "htmlText" to null,
                "clip0Text" to null,
                "clip0Uri" to null,
            )
        }
        val text = intent.getStringExtra(Intent.EXTRA_TEXT)
            ?: intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT)
            ?: intent.getCharSequenceExtra(Intent.EXTRA_SUBJECT)?.toString()
        val htmlText = intent.getStringExtra(Intent.EXTRA_HTML_TEXT)
        // Some share sources (e.g. YouTube) attach the URL only to ClipData
        // rather than EXTRA_TEXT. Expose the first item so Dart can fall back.
        val clip = intent.clipData
        val clip0 = if (clip != null && clip.itemCount > 0) clip.getItemAt(0) else null
        return mapOf(
            "action" to intent.action,
            "type" to intent.type,
            "text" to text,
            "subject" to subject,
            "htmlText" to htmlText,
            "clip0Text" to clip0?.text?.toString(),
            "clip0Uri" to clip0?.uri?.toString(),
        )
    }
}
