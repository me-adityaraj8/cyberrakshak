import '../app/tr.dart';

/// Practice calls: a scammer's script, step by step. At each step the user
/// picks a reply. A safe reply ends the call; an unsafe one lets the scammer
/// push further. Losing at the last step shows what it would have cost.
class CallChoice {
  const CallChoice(this.text, this.feedback, {this.safe = false});
  final Tr text;
  final Tr feedback;
  final bool safe;
}

class CallStep {
  const CallStep({
    required this.line,
    required this.trick,
    required this.choices,
  });

  /// What the caller says.
  final Tr line;

  /// The pressure tactic behind the line, shown in the debrief.
  final Tr trick;
  final List<CallChoice> choices;
}

class CallScenario {
  const CallScenario({
    required this.id,
    required this.title,
    required this.hook,
    required this.caller,
    required this.number,
    required this.steps,
    required this.loss,
    required this.remember,
  });

  final String id;
  final Tr title;
  final Tr hook;
  final Tr caller;

  /// Always masked, so the practice never points at a real person's number.
  final String number;
  final List<CallStep> steps;
  final Tr loss;
  final Tr remember;
}

/// The practice call to suggest next: the first one not yet passed, looking
/// from just after [after] (or from the start).
CallScenario nextCall(Set<String> passed, {String? after}) {
  final start = after == null
      ? 0
      : callScenarios.indexWhere((s) => s.id == after) + 1;
  for (var i = 0; i < callScenarios.length; i++) {
    final s = callScenarios[(start + i) % callScenarios.length];
    if (!passed.contains(s.id) && s.id != after) return s;
  }
  return callScenarios[start % callScenarios.length];
}

const callScenarios = <CallScenario>[
  CallScenario(
    id: 'bank-otp',
    title: Tr('The “bank” call', '“बैंक” वाली कॉल'),
    hook: Tr(
      'Your KYC is pending and your account will be blocked today.',
      'आपका KYC अधूरा है और खाता आज बंद हो जाएगा।',
    ),
    caller: Tr('SBI Customer Care', 'SBI ग्राहक सेवा'),
    number: '+91 98XXX XX310',
    steps: [
      CallStep(
        line: Tr(
          'Hello, I am calling from SBI head office. Your KYC is incomplete, so your account will be blocked today.',
          'नमस्ते, मैं SBI हेड ऑफ़िस से बोल रहा हूँ। आपका KYC अधूरा है, इसलिए आज आपका खाता बंद हो जाएगा।',
        ),
        trick: Tr(
          'Fear and a deadline: “blocked today”.',
          'डर और जल्दी: “आज ही बंद”।',
        ),
        choices: [
          CallChoice(
            Tr('Oh no! What should I do?', 'अरे! अब मैं क्या करूँ?'),
            Tr(
              'Panic is exactly what they want. No bank blocks an account over a phone call.',
              'वे यही घबराहट चाहते हैं। कोई बैंक फ़ोन पर खाता बंद नहीं करता।',
            ),
          ),
          CallChoice(
            Tr(
              'I’ll visit my branch myself. Bye.',
              'मैं ख़ुद ब्रांच जाकर पता करूँगा। नमस्ते।',
            ),
            Tr(
              'Right. Hang up, then contact the bank using the number on your passbook or card.',
              'सही। फ़ोन काटिए, फिर पासबुक या कार्ड पर लिखे नंबर से बैंक से ख़ुद बात कीजिए।',
            ),
            safe: true,
          ),
        ],
      ),
      CallStep(
        line: Tr(
          'Don’t worry, I will fix it right now. I have sent you a link by SMS. Just open it and fill in your details.',
          'घबराइए मत, मैं अभी ठीक कर देता हूँ। मैंने SMS पर एक लिंक भेजा है। बस उसे खोलकर अपनी जानकारी भर दीजिए।',
        ),
        trick: Tr(
          'A link to a fake bank website.',
          'नकली बैंक वेबसाइट का लिंक।',
        ),
        choices: [
          CallChoice(
            Tr('Okay, opening the link.', 'ठीक है, लिंक खोल रहा हूँ।'),
            Tr(
              'That link leads to a copy of the bank’s site, built to steal your details.',
              'वह लिंक बैंक की नकली साइट पर ले जाता है, जो आपकी जानकारी चुराने के लिए बनी है।',
            ),
          ),
          CallChoice(
            Tr(
              'I only use the official bank app. Bye.',
              'मैं सिर्फ़ बैंक का असली ऐप इस्तेमाल करता हूँ। नमस्ते।',
            ),
            Tr(
              'Well done. Banks never send links to update KYC.',
              'बहुत बढ़िया। बैंक KYC के लिए कभी लिंक नहीं भेजते।',
            ),
            safe: true,
          ),
        ],
      ),
      CallStep(
        line: Tr(
          'You will get a 6-digit OTP now. Just read it out to me so I can verify it is you.',
          'अब आपके पास 6 अंकों का OTP आएगा। बस मुझे बता दीजिए ताकि मैं पुष्टि कर सकूँ कि यह आप ही हैं।',
        ),
        trick: Tr(
          'Asking for the OTP, the key to your account.',
          'OTP माँगना, जो आपके खाते की चाबी है।',
        ),
        choices: [
          CallChoice(
            Tr('It’s 4 8 2 9 1 3.', 'जी, 4 8 2 9 1 3 है।'),
            Tr(
              'With that OTP the caller can move money out of your account.',
              'उस OTP से कॉल करने वाला आपके खाते से पैसे निकाल सकता है।',
            ),
          ),
          CallChoice(
            Tr(
              'No bank asks for an OTP. I’m hanging up.',
              'कोई बैंक OTP नहीं माँगता। मैं फ़ोन काट रहा हूँ।',
            ),
            Tr(
              'Exactly. An OTP is never to be shared with anyone, even a “bank officer”.',
              'बिल्कुल। OTP किसी को नहीं बताना है, “बैंक अधिकारी” को भी नहीं।',
            ),
            safe: true,
          ),
        ],
      ),
    ],
    loss: Tr(
      'Two minutes later, ₹49,000 left your account.',
      'दो मिनट बाद आपके खाते से ₹49,000 निकल गए।',
    ),
    remember: Tr(
      'Banks never ask for an OTP, PIN or CVV. Not on a call, not by SMS, never.',
      'बैंक कभी OTP, PIN या CVV नहीं माँगते। न फ़ोन पर, न SMS पर, कभी नहीं।',
    ),
  ),
  CallScenario(
    id: 'digital-arrest',
    title: Tr('The “police” call', '“पुलिस” वाली कॉल'),
    hook: Tr(
      'A parcel in your name, a crime you didn’t commit.',
      'आपके नाम का पार्सल, एक अपराध जो आपने किया ही नहीं।',
    ),
    caller: Tr('Mumbai Police · Cyber Cell', 'मुंबई पुलिस · साइबर सेल'),
    number: '+91 87XXX XX204',
    steps: [
      CallStep(
        line: Tr(
          'This is Inspector Sharma, Mumbai Police. A parcel with drugs and fake passports has been seized in your name.',
          'मैं इंस्पेक्टर शर्मा, मुंबई पुलिस से बोल रहा हूँ। आपके नाम का ड्रग्स और नकली पासपोर्ट वाला पार्सल पकड़ा गया है।',
        ),
        trick: Tr(
          'A fake officer and a crime you never committed.',
          'नकली अफ़सर और ऐसा अपराध जो आपने किया ही नहीं।',
        ),
        choices: [
          CallChoice(
            Tr(
              'That’s impossible! I never sent anything.',
              'यह नामुमकिन है! मैंने कुछ नहीं भेजा।',
            ),
            Tr(
              'Arguing keeps you on the line. Real police send a written notice; they don’t call about parcels.',
              'बहस करने से आप फ़ोन पर बने रहते हैं। असली पुलिस लिखित नोटिस भेजती है, पार्सल के लिए फ़ोन नहीं करती।',
            ),
          ),
          CallChoice(
            Tr(
              'I’ll go to my local police station myself.',
              'मैं ख़ुद अपने नज़दीकी थाने जाऊँगा।',
            ),
            Tr(
              'Perfect. A real case can always be checked at your own police station.',
              'बिल्कुल सही। असली मामला हमेशा अपने थाने में जाकर पता किया जा सकता है।',
            ),
            safe: true,
          ),
        ],
      ),
      CallStep(
        line: Tr(
          'This is serious. You are under digital arrest. Stay on the video call and do not tell anyone, not even your family.',
          'मामला गंभीर है। आप डिजिटल अरेस्ट में हैं। वीडियो कॉल पर बने रहिए और किसी को मत बताइए, परिवार को भी नहीं।',
        ),
        trick: Tr(
          'Cutting you off: “don’t tell your family”.',
          'आपको अकेला करना: “परिवार को मत बताइए”।',
        ),
        choices: [
          CallChoice(
            Tr(
              'Okay, I won’t tell anyone.',
              'ठीक है, मैं किसी को नहीं बताऊँगा।',
            ),
            Tr(
              'Keeping you alone is the trick. Real police never ask you to hide things from your family.',
              'आपको अकेला रखना ही चाल है। असली पुलिस कभी परिवार से बात छुपाने को नहीं कहती।',
            ),
          ),
          CallChoice(
            Tr(
              'There is no “digital arrest”. I’m calling my family.',
              '“डिजिटल अरेस्ट” कुछ नहीं होता। मैं परिवार को फ़ोन कर रहा हूँ।',
            ),
            Tr(
              'Exactly. Talking to someone you trust breaks the scam instantly.',
              'बिल्कुल। किसी भरोसेमंद से बात करते ही यह धोखा टूट जाता है।',
            ),
            safe: true,
          ),
        ],
      ),
      CallStep(
        line: Tr(
          'To clear your name, transfer your savings to an RBI verification account. It will be returned within 24 hours.',
          'अपना नाम साफ़ करने के लिए अपनी बचत RBI के जाँच खाते में भेज दीजिए। 24 घंटे में वापस आ जाएगी।',
        ),
        trick: Tr(
          'Money to “verify” you, promised back later.',
          'जाँच के नाम पर पैसे, बाद में लौटाने का वादा।',
        ),
        choices: [
          CallChoice(
            Tr('Okay, I’m sending it now.', 'ठीक है, अभी भेज रहा हूँ।'),
            Tr(
              'No government office ever takes money to verify anyone. This money never comes back.',
              'कोई सरकारी दफ़्तर जाँच के लिए पैसे नहीं लेता। यह पैसा कभी वापस नहीं आता।',
            ),
          ),
          CallChoice(
            Tr(
              'No agency asks for money like this. I’m calling 1930.',
              'कोई एजेंसी ऐसे पैसे नहीं माँगती। मैं 1930 पर कॉल कर रहा हूँ।',
            ),
            Tr(
              'Well done. 1930 is the national cyber crime helpline.',
              'बहुत बढ़िया। 1930 राष्ट्रीय साइबर अपराध हेल्पलाइन है।',
            ),
            safe: true,
          ),
        ],
      ),
    ],
    loss: Tr(
      '₹3,80,000, a lifetime of savings, is gone.',
      '₹3,80,000, ज़िंदगी भर की बचत, चली गई।',
    ),
    remember: Tr(
      'Police never arrest anyone on a video call and never ask for money. Hang up and call 1930.',
      'पुलिस वीडियो कॉल पर गिरफ़्तार नहीं करती और कभी पैसे नहीं माँगती। फ़ोन काटें और 1930 पर कॉल करें।',
    ),
  ),
  CallScenario(
    id: 'upi-refund',
    title: Tr('The “wrong transfer” call', '“ग़लती से पैसे भेजे” वाली कॉल'),
    hook: Tr(
      'A stranger says they sent you money by mistake.',
      'एक अनजान कहता है कि उसने ग़लती से आपको पैसे भेज दिए।',
    ),
    caller: Tr('Unknown number', 'अनजान नंबर'),
    number: '+91 70XXX XX562',
    steps: [
      CallStep(
        line: Tr(
          'Hello ji, I sent five thousand rupees to your number by mistake. It was my mother’s hospital fee. Please, please return it.',
          'हैलो जी, मैंने ग़लती से आपके नंबर पर पाँच हज़ार रुपये भेज दिए। वो मेरी माँ के अस्पताल की फ़ीस थी। प्लीज़ लौटा दीजिए।',
        ),
        trick: Tr(
          'A sad story to make you want to help fast.',
          'दुखभरी कहानी, ताकि आप जल्दी मदद करना चाहें।',
        ),
        choices: [
          CallChoice(
            Tr(
              'Oh, sorry to hear that. How do I return it?',
              'ओह, अफ़सोस हुआ। मैं कैसे लौटाऊँ?',
            ),
            Tr(
              'Kindness is what they count on. First check your bank app: in most such calls, no money ever arrived.',
              'वे आपकी अच्छाई पर ही भरोसा करते हैं। पहले बैंक ऐप देखिए: ऐसी ज़्यादातर कॉल में कोई पैसा आया ही नहीं होता।',
            ),
          ),
          CallChoice(
            Tr(
              'I’ll check my bank app myself first.',
              'मैं पहले ख़ुद अपना बैंक ऐप देखूँगा।',
            ),
            Tr(
              'Right. A fake “payment received” SMS is easy to send. Your bank app shows the truth.',
              'सही। “पैसे आ गए” का नकली SMS भेजना आसान है। सच आपका बैंक ऐप बताता है।',
            ),
            safe: true,
          ),
        ],
      ),
      CallStep(
        line: Tr(
          'I have sent you a request on PhonePe to return the money. Just tap pay and enter your UPI PIN, that is all.',
          'मैंने PhonePe पर पैसे वापस करने की रिक्वेस्ट भेजी है। बस पे दबाइए और UPI PIN डाल दीजिए, बस इतना।',
        ),
        trick: Tr(
          'A “collect request”: entering your PIN sends money, it never receives it.',
          '“कलेक्ट रिक्वेस्ट”: PIN डालने से पैसे जाते हैं, कभी आते नहीं।',
        ),
        choices: [
          CallChoice(
            Tr('Okay, entering my PIN.', 'ठीक है, PIN डाल रहा हूँ।'),
            Tr(
              'A UPI PIN is only ever needed to send money. To receive money, you never enter it.',
              'UPI PIN सिर्फ़ पैसे भेजने के लिए लगता है। पैसे पाने के लिए कभी PIN नहीं डालना होता।',
            ),
          ),
          CallChoice(
            Tr(
              'Receiving money never needs a PIN. I’m declining it.',
              'पैसे पाने के लिए PIN नहीं लगता। मैं रिक्वेस्ट मना कर रहा हूँ।',
            ),
            Tr(
              'Exactly. Decline any request you did not expect.',
              'बिल्कुल। जो रिक्वेस्ट आपने नहीं माँगी, उसे मना कर दीजिए।',
            ),
            safe: true,
          ),
        ],
      ),
      CallStep(
        line: Tr(
          'Why are you wasting time? My mother is in the ICU! Pay quickly or I will file a police complaint against you.',
          'आप टाइम क्यों बर्बाद कर रहे हैं? मेरी माँ ICU में है! जल्दी पे कीजिए, वरना मैं आपके ख़िलाफ़ पुलिस में शिकायत करूँगा।',
        ),
        trick: Tr(
          'From pleading to threats when you hesitate.',
          'आप रुकें तो मिन्नत से सीधे धमकी।',
        ),
        choices: [
          CallChoice(
            Tr('Sorry, I’m paying right now.', 'माफ़ कीजिए, अभी पे करता हूँ।'),
            Tr(
              'The pressure worked. That request took the money from your account.',
              'दबाव काम कर गया। उस रिक्वेस्ट से पैसे आपके खाते से चले गए।',
            ),
          ),
          CallChoice(
            Tr(
              'If it was a real mistake, ask your bank to reverse it. Bye.',
              'अगर सच में ग़लती हुई है, तो अपने बैंक से वापस करवाइए। नमस्ते।',
            ),
            Tr(
              'Well done. Real wrong transfers are reversed through the bank, never over a call.',
              'बहुत बढ़िया। असली ग़लत ट्रांसफ़र बैंक से वापस होते हैं, कॉल पर नहीं।',
            ),
            safe: true,
          ),
        ],
      ),
    ],
    loss: Tr(
      'You “returned” ₹5,000 that never came. It went straight to the scammer.',
      'आपने ₹5,000 “लौटा” दिए जो कभी आए ही नहीं थे। वो सीधे धोखेबाज़ के पास गए।',
    ),
    remember: Tr(
      'You never enter a UPI PIN to receive money. Check your bank app, not an SMS.',
      'पैसे पाने के लिए UPI PIN कभी नहीं डालते। SMS नहीं, अपना बैंक ऐप देखिए।',
    ),
  ),
  CallScenario(
    id: 'electricity',
    title: Tr('The “electricity” call', '“बिजली विभाग” वाली कॉल'),
    hook: Tr(
      'Your power will be cut tonight unless you pay now.',
      'अभी भुगतान नहीं किया तो आज रात बिजली कट जाएगी।',
    ),
    caller: Tr('Electricity Office', 'बिजली विभाग'),
    number: '+91 62XXX XX817',
    steps: [
      CallStep(
        line: Tr(
          'Hello, I am calling from the electricity office. Your last bill is not updated, so your connection will be cut tonight at nine thirty.',
          'हैलो, मैं बिजली दफ़्तर से बोल रहा हूँ। आपका पिछला बिल अपडेट नहीं हुआ है, इसलिए आज रात साढ़े नौ बजे आपका कनेक्शन कट जाएगा।',
        ),
        trick: Tr(
          'A deadline tonight, so you act before you think.',
          'आज रात की समय-सीमा, ताकि आप सोचने से पहले कुछ कर बैठें।',
        ),
        choices: [
          CallChoice(
            Tr(
              'But I paid it! What do I do now?',
              'पर मैंने तो भर दिया था! अब क्या करूँ?',
            ),
            Tr(
              'Worry keeps you listening. Power companies send a written notice; they don’t call to threaten.',
              'चिंता आपको फ़ोन पर रोके रखती है। बिजली कंपनी लिखित नोटिस भेजती है, धमकी भरी कॉल नहीं करती।',
            ),
          ),
          CallChoice(
            Tr(
              'I’ll check on the official app or at the office.',
              'मैं आधिकारिक ऐप या दफ़्तर में जाकर देखूँगा।',
            ),
            Tr(
              'Right. Your bill status is always on the official app or your last paper bill.',
              'सही। बिल की स्थिति हमेशा आधिकारिक ऐप या पिछले काग़ज़ी बिल पर मिलती है।',
            ),
            safe: true,
          ),
        ],
      ),
      CallStep(
        line: Tr(
          'There is no time for that. Just install the app called AnyDesk, and I will update your bill from here in two minutes.',
          'उसका टाइम नहीं है। बस AnyDesk नाम का ऐप डाल लीजिए, मैं यहीं से दो मिनट में आपका बिल अपडेट कर दूँगा।',
        ),
        trick: Tr(
          'A screen-sharing app that lets them see and control your phone.',
          'स्क्रीन-शेयरिंग ऐप, जिससे वे आपका फ़ोन देख और चला सकें।',
        ),
        choices: [
          CallChoice(
            Tr('Okay, downloading it now.', 'ठीक है, अभी डाउनलोड करता हूँ।'),
            Tr(
              'With AnyDesk they watch your screen, including every OTP and PIN you type.',
              'AnyDesk से वे आपकी स्क्रीन देखते हैं, आपका हर OTP और PIN भी।',
            ),
          ),
          CallChoice(
            Tr(
              'No one gets control of my phone. Bye.',
              'मेरा फ़ोन कोई नहीं चलाएगा। नमस्ते।',
            ),
            Tr(
              'Well done. No real office ever asks you to install a screen-sharing app.',
              'बहुत बढ़िया। कोई असली दफ़्तर स्क्रीन-शेयरिंग ऐप डालने को नहीं कहता।',
            ),
            safe: true,
          ),
        ],
      ),
      CallStep(
        line: Tr(
          'Good. Now pay just ten rupees to update the bill. Open your bank app and type the PIN while I wait.',
          'अच्छा। अब बिल अपडेट करने के लिए बस दस रुपये भरिए। अपना बैंक ऐप खोलिए और PIN डालिए, मैं रुका हूँ।',
        ),
        trick: Tr(
          'A tiny payment, so you type your PIN while they watch.',
          'छोटी सी रक़म, ताकि आप उनकी नज़र के सामने PIN डालें।',
        ),
        choices: [
          CallChoice(
            Tr('It’s only ten rupees. Okay.', 'सिर्फ़ दस रुपये हैं। ठीक है।'),
            Tr(
              'The ten rupees was never the point. They saw your PIN and emptied the account.',
              'दस रुपये असली मक़सद नहीं थे। उन्होंने आपका PIN देख लिया और खाता खाली कर दिया।',
            ),
          ),
          CallChoice(
            Tr(
              'I’m uninstalling that app and calling 1930.',
              'मैं वो ऐप हटा रहा हूँ और 1930 पर कॉल कर रहा हूँ।',
            ),
            Tr(
              'Exactly. Remove the app, change your PINs, and report it.',
              'बिल्कुल। ऐप हटाइए, PIN बदलिए, और रिपोर्ट कीजिए।',
            ),
            safe: true,
          ),
        ],
      ),
    ],
    loss: Tr(
      'For a ₹10 “bill”, ₹1,20,000 left your account.',
      '₹10 के “बिल” के बदले आपके खाते से ₹1,20,000 चले गए।',
    ),
    remember: Tr(
      'No electricity office calls to cut power tonight, and none asks for AnyDesk. Hang up and check the official app.',
      'कोई बिजली दफ़्तर आज रात बिजली काटने की कॉल नहीं करता, और AnyDesk नहीं माँगता। फ़ोन काटें और आधिकारिक ऐप देखें।',
    ),
  ),
];
