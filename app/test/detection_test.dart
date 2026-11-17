import 'dart:convert';

import 'package:cyberrakshak/detection/rules.dart';
import 'package:cyberrakshak/detection/links.dart';

import 'dart:io';

import 'package:cyberrakshak/detection/detector.dart';
import 'package:cyberrakshak/detection/featurizer.dart';
import 'package:cyberrakshak/detection/scam_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final model = ScamModel.fromJson(
    File('assets/model/scam_model.json').readAsStringSync(),
  );
  final detector = Detector(model);

  group('parity with the Python training code', () {
    final fixtures = (jsonDecode(
      File('test/fixtures/model_parity.json').readAsStringSync(),
    ) as List).cast<Map<String, dynamic>>();
    for (final f in fixtures) {
      final text = f['text'] as String;
      test('"${text.length > 30 ? text.substring(0, 30) : text}"', () {
        expect(Featurizer.bucketIds(text), (f['buckets'] as List).cast<int>());
        expect(
          model.probability(text),
          closeTo((f['prob'] as num).toDouble(), 1e-3),
        );
      });
    }
  });

  test('FNV-1a matches the reference value', () {
    // FNV-1a 32-bit of "a" is 0xe40c292c
    expect(Featurizer.fnv1a('a'), 0xe40c292c);
  });

  group('verdicts', () {
    test('KYC link scam is a scam', () {
      final v = detector.check(
        'Dear customer, your SBI KYC has expired. Update now at bit.ly/x9k2 or your account will be blocked today.',
      );
      expect(v.level, RiskLevel.scam);
      expect(
        v.redFlags.map((s) => s.id),
        containsAll(['short_link', 'urgency']),
      );
    });

    test('genuine bank OTP is not a scam', () {
      final v = detector.check(
        '482913 is your OTP for a payment of Rs 1,250 at Amazon. Do not share it with anyone. -HDFC Bank',
      );
      expect(v.level, isNot(RiskLevel.scam));
      expect(v.goodSigns, isNotEmpty);
    });

    test('Hinglish OTP request is a scam', () {
      final v = detector.check(
        'Bhaiya galti se OTP aapke number par chala gaya, please bata do urgent hai',
      );
      expect(v.level, RiskLevel.scam);
    });

    test('Hindi digital arrest is a scam', () {
      final v = detector.check(
        'यह CBI साइबर सेल है। आप डिजिटल अरेस्ट में हैं, वीडियो कॉल न काटें।',
      );
      expect(v.level, RiskLevel.scam);
      expect(v.redFlags.first.id, 'digital_arrest');
    });

    test('family chat is safe', () {
      expect(
        detector
            .check(
              'Hi Priya, reached Patna safely. Will call you in the evening.',
            )
            .level,
        RiskLevel.safe,
      );
    });

    test('bank claim from a mobile number raises a flag', () {
      final v = detector.check(
        'Your HDFC account needs verification',
        sender: '+919812345678',
      );
      expect(v.signals.map((s) => s.id), contains('bank_from_mobile'));
    });
  });

  group('number check', () {
    final nc = NumberCheck({'9812345678'});
    test(
      'reported number',
      () => expect(nc.check('+91 98123 45678').level, RiskLevel.scam),
    );
    test(
      'international',
      () => expect(nc.check('+92 300 1234567').level, RiskLevel.suspicious),
    );
    test(
      'unknown local number',
      () => expect(nc.check('9000011111').level, RiskLevel.safe),
    );
    test('normalise', () {
      expect(NumberCheck.normalise('098123 45678'), '9812345678');
      expect(NumberCheck.normalise('+91-98123-45678'), '9812345678');
      expect(NumberCheck.normalise('12345'), isNull);
    });
  });

  test('red flags point at the words that triggered them', () {
    final rules = RuleEngine();
    const text =
        'Your KYC expired. Update at bit.ly/sbi-kyc9 today or account blocked.';
    final sigs = rules.analyse(text);
    final link = sigs.firstWhere((s) => s.id == 'short_link');
    expect(link.spans, isNotEmpty);
    final (a, b) = link.spans.first;
    expect(text.substring(a, b), 'bit.ly');
    final urgency = sigs.firstWhere((s) => s.id == 'urgency');
    expect(
      urgency.spans.map((p) => text.substring(p.$1, p.$2)),
      contains('today'),
    );
  });

  group('links', () {
    test('look-alike bank link names the real site', () {
      final v = detector.check(
        'Your SBI account is on hold. Verify at https://sbi-kyc-update.in/login within 24 hours.',
      );
      final flag = v.redFlags.firstWhere((s) => s.id == 'lookalike_link');
      expect(flag.reason.en, contains('onlinesbi.sbi'));
      expect(v.redFlags.map((s) => s.id), isNot(contains('short_link')));
      expect(v.level, RiskLevel.scam);
    });

    test('official sites are not flagged', () {
      final v = detector.check(
        'Track your order on amazon.in or call the number on www.hdfcbank.com',
      );
      expect(v.redFlags.map((s) => s.id), isNot(contains('lookalike_link')));
      expect(v.goodSigns.map((s) => s.id), contains('official_link'));
    });

    test('government domains are trusted, copies are not', () {
      expect(
        LinkCheck.analyse('visit incometax.gov.in').single.id,
        'official_link',
      );
      expect(
        LinkCheck.analyse('refund at incometax-refund.online').single.id,
        'lookalike_link',
      );
      expect(LinkCheck.analyse('Mr.Sharma said hi'), isEmpty);
    });
  });
}
