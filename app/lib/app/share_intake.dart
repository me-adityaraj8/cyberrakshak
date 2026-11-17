import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Text sent to the app from elsewhere on Android: "Share" from WhatsApp or
/// SMS, or "Check with CyberRakshak" in the text-selection menu.
class ShareIntake {
  static const _channel = MethodChannel('cyberrakshak/share');

  /// Calls [onText] for text that opened the app and for every later share.
  static Future<void> listen(ValueChanged<String> onText) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'shared' && call.arguments is String) {
        onText(call.arguments as String);
      }
    });
    try {
      final first = await _channel.invokeMethod<String>('initial');
      if (first != null && first.trim().isNotEmpty) onText(first);
    } on PlatformException {
      // Nothing shared.
    } on MissingPluginException {
      // Not running inside the Android app.
    }
  }
}
