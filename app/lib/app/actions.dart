import 'package:url_launcher/url_launcher.dart';

/// Outgoing actions: phone calls, SMS to family, the reporting portal.
class Act {
  static Future<void> call() => launchUrl(Uri.parse('tel:1930'));

  static Future<void> portal() => launchUrl(
    Uri.parse('https://cybercrime.gov.in'),
    mode: LaunchMode.externalApplication,
  );

  /// Opens the SMS app with [body] ready to send. False if no app took it.
  static Future<bool> textFamily(String number, String body) async {
    final to = number.replaceAll(RegExp(r'[^0-9+]'), '');
    // Build the query by hand: Uri(queryParameters:) encodes spaces as "+",
    // which some SMS apps show literally.
    try {
      return await launchUrl(
        Uri.parse('sms:$to?body=${Uri.encodeComponent(body)}'),
      );
    } catch (_) {
      return false;
    }
  }

  /// Opens WhatsApp (app or web) with [body] ready to send. With no number,
  /// WhatsApp asks which chat to send it to.
  static Future<bool> whatsApp(String number, String body) async {
    final to = whatsAppNumber(number);
    try {
      return await launchUrl(
        Uri.parse('https://wa.me/$to?text=${Uri.encodeComponent(body)}'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  /// Digits WhatsApp expects: country code first, no "+" or spaces.
  /// A bare Indian mobile number gets 91 in front.
  static String whatsAppNumber(String number) {
    final d = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (RegExp(r'^[6-9]\d{9}$').hasMatch(d)) return '91$d';
    if (RegExp(r'^0[6-9]\d{9}$').hasMatch(d)) return '91${d.substring(1)}';
    return d;
  }
}

/// Where community reports go. For now reports are kept on the device;
/// the Firebase step replaces this with a Firestore write.
class ReportSink {
  static final List<Map<String, Object?>> pending = [];

  static void submit({
    required String kind,
    required String level,
    String? number,
  }) {
    pending.add({
      'kind': kind,
      'level': level,
      'number': number,
      'at': DateTime.now().toIso8601String(),
    });
  }
}
