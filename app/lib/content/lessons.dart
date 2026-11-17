import '../app/tr.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.hook,
    required this.minutes,
    required this.example,
    required this.redFlags,
    required this.doThis,
  });

  final String id;
  final Tr title;

  /// One-line summary shown on the card.
  final Tr hook;
  final int minutes;

  /// What the scam looks like when it reaches you.
  final Tr example;
  final List<Tr> redFlags;
  final List<Tr> doThis;
}

const lessons = <Lesson>[
  Lesson(
    id: 'digital-arrest',
    title: Tr('“Digital arrest”', '“डिजिटल अरेस्ट”'),
    hook: Tr(
      'A fake officer keeps you on a video call until you pay.',
      'नकली अफ़सर वीडियो कॉल पर तब तक रोके रखता है जब तक आप पैसे न दें।',
    ),
    minutes: 3,
    example: Tr(
      '“This is CBI. A parcel with drugs in your name was seized. You are under digital arrest. Do not disconnect the video call.”',
      '“यह CBI है। आपके नाम का ड्रग्स वाला पार्सल पकड़ा गया है। आप डिजिटल अरेस्ट में हैं। वीडियो कॉल न काटें।”',
    ),
    redFlags: [
      Tr(
        'There is no such thing as a digital arrest in Indian law.',
        'भारतीय क़ानून में “डिजिटल अरेस्ट” जैसा कुछ नहीं है।',
      ),
      Tr(
        'Uniforms, badges and a police-station background are easy to fake on video.',
        'वर्दी, बैज और थाने जैसा बैकग्राउंड वीडियो पर आसानी से नकली बनाए जा सकते हैं।',
      ),
      Tr(
        'They tell you not to tell your family. Real police never do that.',
        'वे कहते हैं कि परिवार को न बताएं। असली पुलिस ऐसा कभी नहीं कहती।',
      ),
    ],
    doThis: [
      Tr(
        'Hang up. You are allowed to.',
        'फ़ोन काट दीजिए। आपको इसका पूरा हक़ है।',
      ),
      Tr(
        'Tell a family member straight away.',
        'तुरंत परिवार के किसी सदस्य को बताइए।',
      ),
      Tr(
        'Report it on 1930 or cybercrime.gov.in.',
        '1930 या cybercrime.gov.in पर रिपोर्ट कीजिए।',
      ),
    ],
  ),
  Lesson(
    id: 'kyc',
    title: Tr('KYC “expired”', 'KYC “ख़त्म” हो गया'),
    hook: Tr(
      'A message says your bank account closes today unless you click.',
      'मैसेज कहता है कि लिंक न खोला तो आज ही खाता बंद हो जाएगा।',
    ),
    minutes: 2,
    example: Tr(
      '“Dear customer, your SBI KYC has expired. Update now bit.ly/sbi-kyc or your account will be blocked today.”',
      '“प्रिय ग्राहक, आपका SBI KYC समाप्त हो गया है। तुरंत bit.ly/sbi-kyc पर अपडेट करें वरना आज खाता बंद हो जाएगा।”',
    ),
    redFlags: [
      Tr(
        'Banks never ask you to update KYC through an SMS link.',
        'बैंक कभी SMS लिंक से KYC अपडेट नहीं करवाते।',
      ),
      Tr(
        'Short links like bit.ly hide where they really go.',
        'bit.ly जैसे छोटे लिंक असली पता छिपा लेते हैं।',
      ),
      Tr(
        '“Today” and “blocked” are there to rush you.',
        '“आज ही” और “बंद” लिखकर जल्दबाज़ी करवाई जाती है।',
      ),
    ],
    doThis: [
      Tr('Don’t open the link.', 'लिंक मत खोलिए।'),
      Tr(
        'If unsure, visit your branch or call the number on the back of your card.',
        'शक हो तो ब्रांच जाइए या कार्ड के पीछे लिखे नंबर पर फ़ोन कीजिए।',
      ),
      Tr(
        'Delete the message and report the sender.',
        'मैसेज डिलीट कीजिए और भेजने वाले को रिपोर्ट कीजिए।',
      ),
    ],
  ),
  Lesson(
    id: 'otp',
    title: Tr('OTP & UPI PIN', 'OTP और UPI PIN'),
    hook: Tr(
      'Your OTP is the key to your money. Nobody else needs it.',
      'OTP आपके पैसों की चाबी है। किसी और को इसकी ज़रूरत नहीं।',
    ),
    minutes: 2,
    example: Tr(
      '“Sir, I sent an OTP to your number by mistake. Please tell it to me, it is very urgent.”',
      '“सर, गलती से आपके नंबर पर OTP चला गया है। कृपया बता दीजिए, बहुत ज़रूरी है।”',
    ),
    redFlags: [
      Tr(
        'Anyone asking for an OTP, PIN or CVV is a scammer. No exceptions.',
        'जो भी OTP, PIN या CVV माँगे, वह धोखेबाज़ है। कोई अपवाद नहीं।',
      ),
      Tr(
        'You never need to enter your UPI PIN to receive money.',
        'पैसा पाने के लिए कभी UPI PIN नहीं डालना पड़ता।',
      ),
      Tr(
        'Genuine OTP messages always say “do not share”.',
        'असली OTP मैसेज हमेशा कहते हैं “किसी को न बताएं”।',
      ),
    ],
    doThis: [
      Tr(
        'Never read an OTP out to anyone, even “bank staff”.',
        'OTP किसी को न बताएं, “बैंक कर्मचारी” को भी नहीं।',
      ),
      Tr(
        'Decline any collect request you did not expect.',
        'जिस पैसे की माँग की उम्मीद न हो, वह रिक्वेस्ट ठुकरा दें।',
      ),
      Tr(
        'If you already shared it, call your bank and 1930 immediately.',
        'अगर बता दिया है, तो तुरंत बैंक और 1930 पर फ़ोन करें।',
      ),
    ],
  ),
  Lesson(
    id: 'electricity',
    title: Tr('Electricity cut tonight', 'आज रात बिजली कटेगी'),
    hook: Tr(
      'A threat to cut your power unless you call an “officer”.',
      '“अधिकारी” को फ़ोन न किया तो बिजली काटने की धमकी।',
    ),
    minutes: 2,
    example: Tr(
      '“Dear consumer, your power will be disconnected tonight at 9:30 PM. Call electricity officer 98XXXXXXXX.”',
      '“प्रिय उपभोक्ता, आज रात 9:30 बजे आपकी बिजली काट दी जाएगी। बिजली अधिकारी को 98XXXXXXXX पर कॉल करें।”',
    ),
    redFlags: [
      Tr(
        'Electricity boards don’t send personal mobile numbers to call.',
        'बिजली विभाग कॉल करने के लिए निजी मोबाइल नंबर नहीं भेजता।',
      ),
      Tr(
        'The “officer” will ask you to install an app or pay by UPI.',
        '“अधिकारी” कोई ऐप डलवाएगा या UPI से पैसे माँगेगा।',
      ),
    ],
    doThis: [
      Tr(
        'Check your bill in the official app or at the office.',
        'अपना बिल आधिकारिक ऐप या दफ़्तर में जाँचें।',
      ),
      Tr(
        'Never install apps a caller asks for.',
        'कॉल करने वाले के कहने पर कोई ऐप न डालें।',
      ),
    ],
  ),
  Lesson(
    id: 'new-number',
    title: Tr('“Mummy, it’s my new number”', '“मम्मी, यह मेरा नया नंबर है”'),
    hook: Tr(
      'Someone pretends to be your child and needs money urgently.',
      'कोई आपका बच्चा बनकर तुरंत पैसे माँगता है।',
    ),
    minutes: 2,
    example: Tr(
      '“Hi Mom, my phone broke, this is my new number. Send ₹15,000 to this UPI urgently, don’t call.”',
      '“मम्मी, मेरा फ़ोन खराब हो गया, यह नया नंबर है। ₹15,000 इस UPI पर तुरंत भेजो, कॉल मत करना।”',
    ),
    redFlags: [
      Tr(
        'A new number plus an urgent money request.',
        'नया नंबर और साथ में तुरंत पैसों की माँग।',
      ),
      Tr(
        '“Don’t call” is there so you can’t check.',
        '“कॉल मत करना” इसलिए कि आप सच न जाँच सकें।',
      ),
    ],
    doThis: [
      Tr(
        'Call your child on their old number first.',
        'पहले बच्चे के पुराने नंबर पर फ़ोन करें।',
      ),
      Tr(
        'Ask something only they would know.',
        'कुछ ऐसा पूछें जो सिर्फ़ वही जानते हों।',
      ),
    ],
  ),
  Lesson(
    id: 'easy-money',
    title: Tr('Easy money & prizes', 'आसान कमाई और इनाम'),
    hook: Tr(
      'Lotteries, “like videos and earn”, guaranteed returns.',
      'लॉटरी, “वीडियो लाइक करो और कमाओ”, पक्का मुनाफ़ा।',
    ),
    minutes: 3,
    example: Tr(
      '“Congratulations! You won ₹25,00,000 in the KBC lucky draw. Pay the processing fee to claim.”',
      '“बधाई हो! आपने KBC लकी ड्रॉ में ₹25,00,000 जीते हैं। इनाम पाने के लिए प्रोसेसिंग फ़ीस भरें।”',
    ),
    redFlags: [
      Tr(
        'You can’t win a lottery you never entered.',
        'जिस लॉटरी में आपने हिस्सा नहीं लिया, उसे आप जीत नहीं सकते।',
      ),
      Tr(
        'Paying a fee to receive money is always a trap.',
        'पैसे पाने के लिए फ़ीस भरना हमेशा जाल होता है।',
      ),
      Tr(
        'Nobody can guarantee returns on an investment.',
        'कोई भी निवेश पर पक्के मुनाफ़े की गारंटी नहीं दे सकता।',
      ),
    ],
    doThis: [
      Tr(
        'Don’t pay anything to claim a prize.',
        'इनाम के लिए कोई पैसा न भरें।',
      ),
      Tr(
        'Leave Telegram or WhatsApp “task” groups.',
        'टेलीग्राम या व्हाट्सएप के “टास्क” ग्रुप छोड़ दें।',
      ),
    ],
  ),
];

class QuizItem {
  const QuizItem({
    required this.message,
    required this.sender,
    required this.isScam,
    required this.why,
  });
  final Tr message;
  final String sender;
  final bool isScam;
  final Tr why;
}

const quiz = <QuizItem>[
  QuizItem(
    sender: 'VM-HDFCBK-S',
    message: Tr(
      '482913 is your OTP for a payment of Rs 1,250 at Amazon. Do not share it with anyone.',
      '482913 आपके ₹1,250 के Amazon भुगतान का OTP है। इसे किसी के साथ साझा न करें।',
    ),
    isScam: false,
    why: Tr(
      'A genuine OTP: registered bank sender, for a payment you made, and it tells you not to share it.',
      'असली OTP: बैंक का रजिस्टर्ड सेंडर, आपके अपने भुगतान के लिए, और यह न बताने को कहता है।',
    ),
  ),
  QuizItem(
    sender: '+91 98XXX XX721',
    message: Tr(
      'SBI: your YONO account is blocked. Update PAN at sbi-kyc-help.top within 2 hours.',
      'SBI: आपका YONO खाता बंद है। 2 घंटे में sbi-kyc-help.top पर PAN अपडेट करें।',
    ),
    isScam: true,
    why: Tr(
      'A bank never writes from a personal number, and that website is not sbi.co.in.',
      'बैंक कभी निजी नंबर से नहीं लिखता, और यह वेबसाइट sbi.co.in नहीं है।',
    ),
  ),
  QuizItem(
    sender: '+91 70XXX XX920',
    message: Tr(
      'Papa my phone fell in water, this is my new number. Send ₹8,000 on this UPI, will explain later.',
      'पापा मेरा फ़ोन पानी में गिर गया, यह नया नंबर है। ₹8,000 इस UPI पर भेज दो, बाद में बताऊँगा।',
    ),
    isScam: true,
    why: Tr(
      'New number + urgent money. Call your child on the old number first.',
      'नया नंबर + तुरंत पैसे। पहले बच्चे के पुराने नंबर पर फ़ोन करें।',
    ),
  ),
  QuizItem(
    sender: 'AX-SWIGGY',
    message: Tr(
      'Your order from Annapurna Bhojnalaya is out for delivery and will reach you in 15 minutes.',
      'अन्नपूर्णा भोजनालय से आपका ऑर्डर निकल चुका है और 15 मिनट में पहुँचेगा।',
    ),
    isScam: false,
    why: Tr(
      'A normal delivery update. No link, no request for money or details.',
      'एक सामान्य डिलीवरी अपडेट। न कोई लिंक, न पैसे या जानकारी की माँग।',
    ),
  ),
  QuizItem(
    sender: '+91 81XXX XX036',
    message: Tr(
      'Mumbai Police: an FIR is registered on your Aadhaar. Join the video call now or an arrest warrant will be issued.',
      'मुंबई पुलिस: आपके आधार पर FIR दर्ज है। अभी वीडियो कॉल पर जुड़ें वरना गिरफ़्तारी वारंट जारी होगा।',
    ),
    isScam: true,
    why: Tr(
      'Police never threaten arrest over a video call. This is the “digital arrest” scam.',
      'पुलिस वीडियो कॉल पर गिरफ़्तारी की धमकी नहीं देती। यह “डिजिटल अरेस्ट” धोखा है।',
    ),
  ),
];
