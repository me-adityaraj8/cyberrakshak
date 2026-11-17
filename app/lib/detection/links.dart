import '../app/tr.dart';
import 'rules.dart';

/// Looks at every link in a message. A link that borrows a bank's or
/// brand's name but is not that brand's real website is the single clearest
/// sign of phishing, so the verdict names both the fake and the real site.
class LinkCheck {
  static final RegExp _domain = RegExp(
    r'(?:https?://)?((?:[a-z0-9-]+\.)+(?:com|in|net|org|co|info|xyz|top|site|online|click|live|buzz|app|link|me|io|shop|store|bank|sbi|gov|ly|gd|at|cc|tk|ml|ga|cf|vip|club|icu|cyou|pro|biz|support|help|services|cloud))(?=$|[\s/:?#)\],.!])',
    caseSensitive: false,
  );

  /// Brand name as it appears inside a domain, its display name, and the
  /// real website to point people to.
  static const _brands = <(String, String, String)>[
    ('sbi', 'SBI', 'onlinesbi.sbi'),
    ('yono', 'SBI YONO', 'onlinesbi.sbi'),
    ('hdfc', 'HDFC Bank', 'hdfcbank.com'),
    ('icici', 'ICICI Bank', 'icicibank.com'),
    ('axis', 'Axis Bank', 'axisbank.com'),
    ('pnb', 'PNB', 'pnbindia.in'),
    ('kotak', 'Kotak', 'kotak.com'),
    ('canara', 'Canara Bank', 'canarabank.com'),
    ('paytm', 'Paytm', 'paytm.com'),
    ('phonepe', 'PhonePe', 'phonepe.com'),
    ('gpay', 'Google Pay', 'pay.google.com'),
    ('amazon', 'Amazon', 'amazon.in'),
    ('flipkart', 'Flipkart', 'flipkart.com'),
    ('irctc', 'IRCTC', 'irctc.co.in'),
    ('aadhaar', 'Aadhaar', 'uidai.gov.in'),
    ('uidai', 'Aadhaar', 'uidai.gov.in'),
    ('incometax', 'Income Tax', 'incometax.gov.in'),
    ('epfo', 'EPFO', 'epfindia.gov.in'),
    ('indiapost', 'India Post', 'indiapost.gov.in'),
    ('rbi', 'RBI', 'rbi.org.in'),
    ('npci', 'NPCI', 'npci.org.in'),
    ('fastag', 'FASTag', 'ihmcl.co.in'),
    ('echallan', 'e-Challan', 'echallan.parivahan.gov.in'),
    ('parivahan', 'Parivahan', 'parivahan.gov.in'),
  ];

  /// Real sites (and everything under them).
  static const _official = [
    'onlinesbi.sbi',
    'sbi.co.in',
    'sbi.bank.in',
    'hdfcbank.com',
    'hdfc.bank.in',
    'icicibank.com',
    'icici.bank.in',
    'axisbank.com',
    'axis.bank.in',
    'pnbindia.in',
    'pnb.bank.in',
    'kotak.com',
    'kotak.bank.in',
    'canarabank.com',
    'canarabank.bank.in',
    'paytm.com',
    'phonepe.com',
    'pay.google.com',
    'amazon.in',
    'amazon.com',
    'flipkart.com',
    'irctc.co.in',
    'rbi.org.in',
    'npci.org.in',
    'ihmcl.co.in',
    'fastag.ihmcl.com',
  ];

  static bool _isOfficial(String host) =>
      host.endsWith('.gov.in') ||
      host.endsWith('.nic.in') ||
      _official.any((o) => host == o || host.endsWith('.$o'));

  static List<Signal> analyse(String text) {
    final out = <Signal>[];
    final seen = <String>{};
    for (final m in _domain.allMatches(text)) {
      final host = m
          .group(1)!
          .toLowerCase()
          .replaceFirst(RegExp(r'^www\.'), '');
      if (!seen.add(host)) continue;
      final span = (m.start, m.end);
      if (_isOfficial(host)) {
        out.add(
          Signal(
            'official_link',
            -0.5,
            Tr(
              'The link $host is a genuine official website.',
              'लिंक $host एक असली आधिकारिक वेबसाइट है।',
            ),
            spans: [span],
          ),
        );
        continue;
      }
      final flat = host.replaceAll(RegExp(r'[.-]'), '');
      for (final (key, name, real) in _brands) {
        if (flat.contains(key)) {
          out.add(
            Signal(
              'lookalike_link',
              2.4,
              Tr(
                'The link $host uses $name’s name, but it is not $name’s website. The real one is $real.',
                'लिंक $host में $name का नाम है, पर यह $name की वेबसाइट नहीं है। असली वेबसाइट $real है।',
              ),
              spans: [span],
            ),
          );
          break;
        }
      }
    }
    return out;
  }
}
