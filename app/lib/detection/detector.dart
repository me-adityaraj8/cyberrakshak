import '../app/tr.dart';
import 'rules.dart';
import 'scam_model.dart';

enum RiskLevel { safe, suspicious, scam }

class Verdict {
  const Verdict({
    required this.level,
    required this.score,
    required this.modelProbability,
    required this.signals,
    required this.text,
  });

  final RiskLevel level;

  /// Combined probability (model + rules), 0..1.
  final double score;
  final double modelProbability;
  final List<Signal> signals;
  final String text;

  /// Red flags only (positive signals), strongest first.
  List<Signal> get redFlags =>
      signals.where((s) => s.weight > 0).toList()
        ..sort((a, b) => b.weight.compareTo(a.weight));

  /// Reassuring signals (negative weights).
  List<Signal> get goodSigns => signals.where((s) => s.weight < 0).toList();
}

/// Combines the ML model with the rule engine:
///   score = sigmoid(model log-odds + sum of rule weights)
class Detector {
  Detector(this.model, {RuleEngine? rules}) : rules = rules ?? RuleEngine();

  final ScamModel model;
  final RuleEngine rules;

  static const double scamThreshold = 0.75;
  static const double suspiciousThreshold = 0.45;

  Verdict check(String text, {String? sender}) {
    final trimmed = text.trim();
    final signals = rules.analyse(trimmed, sender: sender);
    final z = model.logit(trimmed);
    final combined = ScamModel.sigmoid(
      z + signals.fold<double>(0, (a, s) => a + s.weight),
    );
    var level = combined >= scamThreshold
        ? RiskLevel.scam
        : combined >= suspiciousThreshold
        ? RiskLevel.suspicious
        : RiskLevel.safe;
    // A strong red flag never lets a message be called safe.
    if (level == RiskLevel.safe && signals.any((s) => s.weight >= 2)) {
      level = RiskLevel.suspicious;
    }
    return Verdict(
      level: level,
      score: combined,
      modelProbability: ScamModel.sigmoid(z),
      signals: signals,
      text: trimmed,
    );
  }
}

/// Phone-number check against the local list of reported scam numbers.
class NumberCheck {
  NumberCheck(this.reported);

  /// Normalised 10-digit numbers reported as scams.
  final Set<String> reported;

  static String? normalise(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9+]'), '');
    final m = RegExp(r'^(?:\+?91|0)?([6-9]\d{9})$').firstMatch(digits);
    return m?.group(1);
  }

  static bool looksLikeNumber(String input) {
    final t = input.trim();
    return RegExp(r'^[+0-9\s-]{8,16}$').hasMatch(t);
  }

  NumberVerdict check(String input) {
    final t = input.replaceAll(RegExp(r'[\s-]'), '');
    final n = normalise(t);
    if (n != null && reported.contains(n)) {
      return NumberVerdict(
        RiskLevel.scam,
        t,
        const Tr(
          'This number has been reported as a scam by the CyberRakshak community.',
          'इस नंबर को CyberRakshak समुदाय ने धोखेबाज़ के रूप में रिपोर्ट किया है।',
        ),
      );
    }
    if (t.startsWith('+') && !t.startsWith('+91')) {
      return NumberVerdict(
        RiskLevel.suspicious,
        t,
        const Tr(
          'An international number. Be careful if the caller claims to be a bank, police or a government office in India.',
          'यह विदेशी नंबर है। अगर कॉल करने वाला ख़ुद को बैंक, पुलिस या सरकारी दफ़्तर बताए तो सावधान रहें।',
        ),
      );
    }
    if (t.startsWith('140')) {
      return NumberVerdict(
        RiskLevel.safe,
        t,
        const Tr(
          '140-series numbers are registered telemarketing lines. Annoying, but not a scam.',
          '140 वाले नंबर रजिस्टर्ड टेलीमार्केटिंग लाइन होते हैं। परेशान कर सकते हैं, पर धोखा नहीं।',
        ),
      );
    }
    if (t.startsWith('1600')) {
      return NumberVerdict(
        RiskLevel.safe,
        t,
        const Tr(
          '1600-series numbers are reserved for banks and financial services in India.',
          '1600 वाले नंबर भारत में बैंकों और वित्तीय सेवाओं के लिए तय हैं।',
        ),
      );
    }
    return NumberVerdict(
      RiskLevel.safe,
      t,
      const Tr(
        'Not in our list of reported scam numbers. If the caller asks for an OTP, PIN or money, hang up.',
        'यह नंबर रिपोर्ट किए गए धोखेबाज़ नंबरों में नहीं है। फिर भी अगर कॉल पर OTP, PIN या पैसे माँगे जाएँ, तो फ़ोन काट दें।',
      ),
    );
  }
}

class NumberVerdict {
  const NumberVerdict(this.level, this.number, this.reason);
  final RiskLevel level;
  final String number;
  final Tr reason;
}
