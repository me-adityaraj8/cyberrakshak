import '../app/tr.dart';
import 'links.dart';

/// One thing the rule engine noticed. [weight] is added to the model's
/// log-odds: positive pushes towards "scam", negative towards "safe".
class Signal {
  const Signal(this.id, this.weight, this.reason, {this.spans = const []});
  final String id;
  final double weight;
  final Tr reason;

  /// Where in the text this signal was found, as (start, end) offsets.
  /// Used to highlight the exact words that gave the message away.
  final List<(int, int)> spans;
}

List<(int, int)> _spans(RegExp p, String text) => [
  for (final m in p.allMatches(text))
    if (m.end > m.start) (m.start, m.end),
];

class _Rule {
  const _Rule(this.id, this.weight, this.reason, this.pattern);
  final String id;
  final double weight;
  final Tr reason;
  final RegExp pattern;
}

RegExp _r(String p) => RegExp(p, caseSensitive: false, unicode: true);

/// Hand-written red flags. They make the verdict explainable ("why we think
/// this is a scam") and catch patterns the small model has not seen yet.
class RuleEngine {
  static final RegExp _neverShare = _r(
    r"(do not|don't|never|dont)\s+share|किसी\s*(के\s*साथ|को)\s*(साझा|शेयर|न\s*बताएं|ना\s*बताएं)|share\s+na\s+kar|kisi\s+ko\s+(na|mat)\s+bata|bank\s+(officials\s+)?never\s+ask",
  );

  static final RegExp _shortLink = _r(
    r'\b(bit\.ly|tinyurl\.com|rb\.gy|cutt\.ly|t\.ly|is\.gd|goo\.gl|shorturl\.at)\b|\b[a-z0-9-]+\.(xyz|top|info|site|online|click|live|buzz)\b|\b(sbi|hdfc|icici|axis|pnb|kotak|canara|paytm|kyc)[a-z0-9]*-[a-z0-9-]+\.[a-z]{2,}',
  );

  static final List<_Rule> _rules = [
    _Rule(
      'asks_secret',
      2.6,
      const Tr(
        'Asks you to share an OTP, PIN or CVV. No bank or officer ever asks for these.',
        'OTP, PIN या CVV बताने को कह रहा है। कोई बैंक या अधिकारी इन्हें कभी नहीं माँगता।',
      ),
      _r(
        r'(share|tell|send|enter|give|bata|batao|bataiye|bhej|daal|बता|भेज|डाल)\w*.{0,40}(otp|o\.t\.p|upi\s*pin|\bpin\b|cvv)|(otp|upi\s*pin|\bpin\b|cvv).{0,40}(share\s+(it\s+)?with|bata\s*(do|dijiye|dein)|bhej|बता\s*(दीजिए|दें|दो)|बताएं|भेजें|enter)',
      ),
    ),
    _Rule(
      'remote_app',
      2.6,
      const Tr(
        'Asks you to install a screen-sharing app. Scammers use these to take over your phone.',
        'स्क्रीन-शेयरिंग ऐप डालने को कह रहा है। धोखेबाज़ इससे आपका फ़ोन चला लेते हैं।',
      ),
      _r(r'anydesk|teamviewer|quick\s*support|rustdesk|airdroid'),
    ),
    _Rule(
      'digital_arrest',
      2.2,
      const Tr(
        '"Digital arrest" is not real. Police never arrest anyone over a video call.',
        '"डिजिटल अरेस्ट" जैसा कुछ नहीं होता। पुलिस वीडियो कॉल पर गिरफ़्तार नहीं करती।',
      ),
      _r(
        r'digital\s*arrest|डिजिटल\s*अरेस्ट|video\s*call.{0,60}(police|cbi|arrest|warrant)|(police|cbi|arrest|warrant|पुलिस|गिरफ्तार).{0,60}(video\s*call|वीडियो\s*कॉल)',
      ),
    ),
    _Rule(
      'short_link',
      1.6,
      const Tr(
        'Contains a shortened or look-alike link, not an official bank website.',
        'इसमें छोटा या नकली दिखने वाला लिंक है, बैंक की असली वेबसाइट नहीं।',
      ),
      _shortLink,
    ),
    _Rule(
      'prize',
      1.5,
      const Tr(
        'Promises a prize or lottery you never entered.',
        'ऐसे इनाम या लॉटरी का वादा जिसमें आपने कभी हिस्सा ही नहीं लिया।',
      ),
      _r(
        r'lottery|lucky\s*draw|\bkbc\b|you\s+have\s+won|congratulations.{0,40}won|jeet[ae]|जीत[ाे]|इनाम|लॉटरी',
      ),
    ),
    _Rule(
      'pay_to_receive',
      1.5,
      const Tr(
        'Asks you to pay a fee to receive money. Real refunds and prizes never need a fee.',
        'पैसा पाने के लिए फ़ीस भरने को कह रहा है। असली रिफ़ंड या इनाम में फ़ीस नहीं लगती।',
      ),
      _r(
        r'processing\s*fee|clearance\s*fee|registration\s*fee|fees?\s*bhar|फ़?फीस\s*(भर|जमा)|pay\s+rs\.?\s*\d+.{0,30}(fee|charge)',
      ),
    ),
    _Rule(
      'too_good',
      1.4,
      const Tr(
        'Promises guaranteed or unrealistic returns.',
        'पक्के या बहुत ज़्यादा मुनाफ़े का वादा कर रहा है।',
      ),
      _r(
        r'guarantee|guaranteed|double\s+(your\s+)?money|paisa\s+double|\d{3}\s*%\s*return|तीन\s*गुना|दोगुना|गारंटी|daily\s+(earn|payment)|roz\s*rs|रोज़?\s*₹',
      ),
    ),
    _Rule(
      'new_number_money',
      1.8,
      const Tr(
        'Someone "on a new number" asking for money. Call the person on their old number first.',
        '"नए नंबर" से कोई पैसे माँग रहा है। पहले उनके पुराने नंबर पर फ़ोन करके पूछें।',
      ),
      _r(
        r'(new|naya|नया)\s*(number|नंबर).{0,80}(send|bhej|भेज|upi|rs|₹)|(phone|फ़ोन|फोन).{0,20}(broke|kharab|खराब)',
      ),
    ),
    _Rule(
      'threat',
      1.0,
      const Tr(
        'Threatens to block, cut off or arrest you to make you panic.',
        'खाता बंद करने, कनेक्शन काटने या गिरफ़्तारी की धमकी देकर डरा रहा है।',
      ),
      _r(
        r'block(ed)?|suspend|disconnect|deactivat|legal\s+action|arrest|warrant|\bfir\b|band\s+ho|kaat|बंद\s*(हो|कर)|काट\s*दिया|गिरफ्तार|कानूनी',
      ),
    ),
    _Rule(
      'urgency',
      0.8,
      const Tr(
        'Creates urgency ("today", "within 24 hours") so you act without thinking.',
        '"आज ही", "24 घंटे में" कहकर जल्दबाज़ी करवा रहा है ताकि आप सोचें नहीं।',
      ),
      _r(
        r'immediately|urgent|today|tonight|within\s+\d+\s*(hours|hrs|minutes)|right\s+now|\bturant\b|\babhi\b|\baaj\b|तुरंत|अभी|आज\s*(ही|रात)|\d+\s*घंटे',
      ),
    ),
    _Rule(
      'identity_docs',
      0.8,
      const Tr(
        'Asks you to update or send KYC, Aadhaar or PAN details through a message.',
        'मैसेज के ज़रिए KYC, आधार या PAN की जानकारी माँग रहा है।',
      ),
      _r(
        r'(kyc|aadhaar|aadhar|\bpan\b|आधार|पैन).{0,50}(update|verify|send|bhej|अपडेट|सत्यापित|भेज)|(update|verify|अपडेट).{0,30}(kyc|aadhaar|pan|आधार)',
      ),
    ),
    _Rule(
      'call_officer',
      0.6,
      const Tr(
        'Asks you to call or WhatsApp an "officer" or "executive" on a personal number.',
        'किसी "अधिकारी" या "एग्ज़िक्यूटिव" के निजी नंबर पर कॉल या व्हाट्सएप करने को कह रहा है।',
      ),
      _r(
        r'(officer|executive|customer\s*care|अधिकारी|whatsapp|व्हाट्सएप|telegram).{0,40}(\+?91[\s-]?)?[6-9]\d{9}|call.{0,30}(\+?91[\s-]?)?[6-9]\d{9}',
      ),
    ),
  ];

  static Signal _neverShareSignal(String text) => Signal(
    'never_share_notice',
    -2.2,
    spans: _spans(_neverShare, text),
    const Tr(
      'Reminds you never to share your OTP, which is what genuine bank messages do.',
      'OTP किसी को न बताने की याद दिला रहा है, जैसा असली बैंक मैसेज करते हैं।',
    ),
  );

  static final RegExp _mobileSender = RegExp(r'^\+?(91)?[6-9]\d{9}$');
  static final RegExp _headerSender = RegExp(
    r'^[A-Z]{2}-[A-Z0-9]{3,9}(-[SPTG])?$',
  );
  static final RegExp _bankWords = _r(
    r'\b(bank|sbi|hdfc|icici|axis|pnb|kotak|yono|kyc|account|a/c)\b|बैंक|खाता',
  );

  /// Signals for [text]. [sender] is the SMS sender address when known.
  List<Signal> analyse(String text, {String? sender}) {
    final out = <Signal>[];
    final neverShare = _neverShare.hasMatch(text);
    for (final r in _rules) {
      if (r.id == 'asks_secret' && neverShare) continue;
      if (r.pattern.hasMatch(text)) {
        out.add(
          Signal(r.id, r.weight, r.reason, spans: _spans(r.pattern, text)),
        );
      }
    }
    final links = LinkCheck.analyse(text);
    if (links.any((l) => l.id == 'lookalike_link')) {
      // The look-alike reason names the fake site and the real one, which
      // says more than the generic short-link flag for the same link.
      final fake = [
        for (final l in links)
          if (l.id == 'lookalike_link') ...l.spans,
      ];
      out.removeWhere(
        (s) =>
            s.id == 'short_link' &&
            s.spans.every((a) => fake.any((b) => a.$1 < b.$2 && b.$1 < a.$2)),
      );
    }
    out.addAll(links);
    if (neverShare &&
        !out.any(
          (s) =>
              s.id == 'short_link' ||
              s.id == 'remote_app' ||
              s.id == 'lookalike_link',
        )) {
      out.add(_neverShareSignal(text));
    }
    final s = sender?.replaceAll(' ', '');
    if (s != null && s.isNotEmpty && _bankWords.hasMatch(text)) {
      if (_mobileSender.hasMatch(s)) {
        out.add(
          const Signal(
            'bank_from_mobile',
            1.4,
            Tr(
              'Claims to be from a bank but was sent from a personal mobile number. Banks send SMS from names like "VM-SBIBNK".',
              'बैंक का होने का दावा, पर एक निजी मोबाइल नंबर से भेजा गया। बैंक "VM-SBIBNK" जैसे नाम से SMS भेजते हैं।',
            ),
          ),
        );
      } else if (_headerSender.hasMatch(s.toUpperCase())) {
        out.add(
          const Signal(
            'registered_header',
            -0.6,
            Tr(
              'Sent from a registered business sender ID.',
              'एक रजिस्टर्ड बिज़नेस सेंडर ID से भेजा गया।',
            ),
          ),
        );
      }
    }
    return out;
  }
}
