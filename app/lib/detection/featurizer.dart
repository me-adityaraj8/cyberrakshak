import 'dart:convert';

/// Dart port of ml/featurize.py. Behaviour must match it exactly; the parity
/// test in test/featurizer_test.dart checks against fixtures exported by
/// ml/train.py.
class Featurizer {
  static const int numBuckets = 1 << 14;

  static final RegExp _url = RegExp(
    r'(https?://\S+|www\.\S+|\b[a-z0-9-]+\.(?:ly|in|com|xyz|top|info|link|site|online|co|net|org|me|io|app)(?:/\S*)?)',
  );
  static final RegExp _digit = RegExp(r'[0-9०-९]');
  static final RegExp _tokenChar = RegExp(r'[\p{L}\p{M}\p{N}]', unicode: true);

  static String normalize(String text) {
    var t = text.toLowerCase();
    t = t.replaceAll(_url, ' urltok ');
    t = t.replaceAll(_digit, '0');
    return t;
  }

  static List<String> tokenize(String text) {
    final tokens = <String>[];
    final cur = StringBuffer();
    for (final rune in normalize(text).runes) {
      final ch = String.fromCharCode(rune);
      if (_tokenChar.hasMatch(ch)) {
        cur.write(ch);
      } else if (cur.isNotEmpty) {
        tokens.add(cur.toString());
        cur.clear();
      }
    }
    if (cur.isNotEmpty) tokens.add(cur.toString());
    return tokens;
  }

  static List<String> features(String text) {
    final toks = tokenize(text);
    final out = <String>[for (final t in toks) 'w:$t'];
    for (var i = 0; i + 1 < toks.length; i++) {
      out.add('b:${toks[i]} ${toks[i + 1]}');
    }
    for (final t in toks) {
      final padded = ' $t '.runes.toList();
      for (var i = 0; i + 3 <= padded.length; i++) {
        out.add('c:${String.fromCharCodes(padded.sublist(i, i + 3))}');
      }
    }
    return out;
  }

  /// FNV-1a 32-bit. The multiply is split so intermediate values stay below
  /// 2^53 and the result is identical on the Dart VM and on the web.
  static int fnv1a(String s) {
    var h = 2166136261;
    for (final byte in utf8.encode(s)) {
      h = (h ^ byte) % 4294967296;
      h = ((h % 256) * 16777216 + h * 403) % 4294967296;
    }
    return h;
  }

  static List<int> bucketIds(String text) {
    final ids = <int>{for (final f in features(text)) fnv1a(f) % numBuckets};
    return ids.toList()..sort();
  }
}
