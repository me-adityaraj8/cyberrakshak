import 'tr.dart';

/// All interface copy, in both languages. Tone: calm, respectful, short.
/// Hindi uses "आप" throughout.
class S {
  // navigation
  static const navHome = Tr('Check', 'जाँचें');
  static const navLearn = Tr('Learn', 'सीखें');
  static const navHelp = Tr('Help', 'मदद');

  // language
  static const chooseLanguage = Tr('Choose your language', 'अपनी भाषा चुनें');
  static const chooseLanguageNote = Tr(
    'You can change this any time from Help.',
    'आप इसे कभी भी “मदद” में जाकर बदल सकते हैं।',
  );
  static const continueBtn = Tr('Continue', 'आगे बढ़ें');
  static const yourName = Tr(
    'What should we call you?',
    'हम आपको किस नाम से बुलाएँ?',
  );
  static const yourNameHint = Tr(
    'Your name (optional)',
    'आपका नाम (ज़रूरी नहीं)',
  );
  static const welcomeTitle = Tr(
    'A second pair of eyes on every message.',
    'हर संदेश पर एक भरोसेमंद नज़र।',
  );
  static const welcomeBody = Tr(
    'CyberRakshak checks messages, links and phone numbers for scams, right here on your phone. Nothing you check is sent anywhere.',
    'CyberRakshak संदेशों, लिंक और फ़ोन नंबरों में धोखा पहचानता है, यहीं आपके फ़ोन पर। आप जो जाँचते हैं, वह कहीं नहीं भेजा जाता।',
  );

  // home
  static const greeting = Tr('Namaste', 'नमस्ते');
  static const safeTodayNamed = Tr(
    '{name}, you’re protected today.',
    '{name} जी, आज आप सुरक्षित हैं।',
  );
  static const safeToday = Tr('You’re protected today.', 'आज आप सुरक्षित हैं।');
  static const onDevice = Tr(
    'Checks run on this phone · works offline',
    'जाँच इसी फ़ोन पर होती है · बिना इंटरनेट भी',
  );
  static const checkTitle = Tr('Something feels off?', 'कुछ गड़बड़ लग रहा है?');
  static const checkHint = Tr(
    'Paste a message, link or phone number',
    'संदेश, लिंक या फ़ोन नंबर यहाँ चिपकाएँ',
  );
  static const paste = Tr('Paste', 'चिपकाएँ');
  static const tryExample = Tr('Try an example', 'उदाहरण आज़माएँ');
  static const checkBtn = Tr('Check now', 'अभी जाँचें');
  static const reading = Tr('Reading it…', 'पढ़ रहे हैं…');
  static const checked = Tr('checked', 'जाँचे गए');
  static const caught = Tr('scams caught', 'धोखे पकड़े');
  static const thisWeek = Tr('THIS WEEK', 'इस हफ़्ते');
  static const minutes = Tr('{n} min read', '{n} मिनट');
  static const recent = Tr('RECENT CHECKS', 'हाल की जाँच');

  // verdict
  static const scamSeal = Tr('SCAM', 'धोखा');
  static const suspiciousSeal = Tr('CAREFUL', 'सावधान');
  static const safeSeal = Tr('LOOKS OK', 'ठीक है');
  static const scamHeadline = Tr(
    'Stop. This message is a scam.',
    'रुकिए। यह संदेश धोखा है।',
  );
  static const suspiciousHeadline = Tr(
    'Be careful with this one.',
    'इस संदेश से सावधान रहें।',
  );
  static const safeHeadline = Tr(
    'This looks like a normal message.',
    'यह एक सामान्य संदेश लगता है।',
  );
  static const scamSub = Tr(
    'Don’t open the link, call back or share anything.',
    'लिंक न खोलें, वापस फ़ोन न करें, कुछ भी न बताएं।',
  );
  static const suspiciousSub = Tr(
    'Some signs here are often used by scammers.',
    'इसमें कुछ बातें हैं जो अक्सर धोखेबाज़ इस्तेमाल करते हैं।',
  );
  static const safeSub = Tr(
    'We found no warning signs. Still, never share an OTP or PIN.',
    'हमें कोई ख़तरे का संकेत नहीं मिला। फिर भी OTP या PIN कभी न बताएं।',
  );
  static const whyTitle = Tr('WHY WE THINK SO', 'हमें ऐसा क्यों लगता है');
  static const goodSignsTitle = Tr('WHAT LOOKS GENUINE', 'क्या असली लगता है');
  static const whatNow = Tr('WHAT TO DO NOW', 'अब क्या करें');
  static const call1930 = Tr(
    'Call 1930 helpline',
    '1930 हेल्पलाइन पर कॉल करें',
  );
  static const tellFamily = Tr('Tell my family', 'परिवार को बताएं');
  static const reportIt = Tr('Report this scam', 'इस धोखे की रिपोर्ट करें');
  static const reported = Tr(
    'Reported. Thank you for protecting others.',
    'रिपोर्ट हो गई। दूसरों को बचाने के लिए धन्यवाद।',
  );
  static const sharedIn = Tr('Shared', 'शेयर से');
  static const shareTip = Tr(
    'In WhatsApp or SMS, long-press a message, tap Share, then pick CyberRakshak.',
    'WhatsApp या SMS में मैसेज को दबाकर रखें, शेयर दबाएँ, फिर CyberRakshak चुनें।',
  );
  static const likelihood = Tr('Scam likelihood', 'धोखे की संभावना');
  static const theMessage = Tr('THE MESSAGE', 'संदेश');
  static const theNumber = Tr('THE NUMBER', 'नंबर');
  static const learnMore = Tr(
    'Learn about this scam',
    'इस धोखे के बारे में सीखें',
  );
  static const marksNote = Tr(
    'Underlined: the words that gave it away.',
    'रेखांकित: वे शब्द जिनसे धोखा पकड़ा गया।',
  );
  static const checkAnother = Tr('Check another message', 'दूसरा संदेश जाँचें');
  static const familyMsg = Tr(
    'CyberRakshak warning: I received this scam message. Please be careful if you get something similar.\n\n“{msg}”',
    'CyberRakshak चेतावनी: मुझे यह धोखे वाला संदेश मिला है। ऐसा कुछ आए तो सावधान रहें।\n\n“{msg}”',
  );

  // learn
  static const learnTitle = Tr(
    'Know the tricks before they reach you.',
    'धोखे की चालें पहले से पहचानिए।',
  );
  static const learnSub = Tr(
    'Short lessons on the scams Indians face most.',
    'उन धोखों पर छोटे पाठ जो भारत में सबसे ज़्यादा होते हैं।',
  );
  static const quizCardTitle = Tr('Real or fake?', 'असली या नकली?');
  static const quizCardBody = Tr(
    'Five real-looking messages. Can you spot the scams?',
    'पाँच असली जैसे संदेश। क्या आप धोखा पहचान सकते हैं?',
  );
  static const startQuiz = Tr('Start', 'शुरू करें');
  static const collection = Tr('YOUR STAMP COLLECTION', 'आपका टिकट संग्रह');
  static const collectionCount = Tr(
    '{n} of {total} collected',
    '{total} में से {n} जमा',
  );
  static const collectionNote = Tr(
    'Finish a lesson to cancel its stamp.',
    'पाठ पूरा करें और टिकट पर मुहर लगाएँ।',
  );
  static const stampDone = Tr('DONE', 'पूरा');
  static const lessonsLabel = Tr('LESSONS', 'पाठ');
  static const done = Tr('Done', 'पूरा हुआ');
  static const completed = Tr('Completed', 'पूरा');
  static const howItLooks = Tr('HOW IT REACHES YOU', 'यह आप तक कैसे आता है');
  static const redFlags = Tr('RED FLAGS', 'ख़तरे के संकेत');
  static const doThis = Tr('WHAT TO DO', 'क्या करें');

  // practice call
  static const practiceCardTitle = Tr(
    'Practice a scam call',
    'धोखे वाली कॉल का अभ्यास',
  );
  static const practiceCardBody = Tr(
    'A scam call, step by step. Can you hang up in time?',
    'धोखे वाली कॉल, क़दम दर क़दम। क्या आप समय पर फ़ोन काट पाएँगे?',
  );
  static const practiceStart = Tr('Answer', 'उठाएँ');
  static const practiceLabel = Tr('PRACTICE CALLS', 'अभ्यास कॉल');
  static const practiceCallTag = Tr('PRACTICE CALL', 'अभ्यास कॉल');
  static const practiceNote = Tr(
    'This is a practice call. Nothing is real and nothing is sent.',
    'यह सिर्फ़ अभ्यास है। कुछ भी असली नहीं है, कुछ भी भेजा नहीं जाता।',
  );
  static const incomingCall = Tr('Incoming call…', 'कॉल आ रही है…');
  static const answer = Tr('Answer', 'उठाएँ');
  static const decline = Tr('Decline', 'काटें');
  static const hangUp = Tr('Hang up', 'फ़ोन काटें');
  static const yourReply = Tr(
    'YOUR REPLY · {n} OF {total}',
    'आपका जवाब · {n} / {total}',
  );
  static const callSafeSeal = Tr('SAFE', 'बचे');
  static const callLostSeal = Tr('LOST', 'ठगे');
  static const callWonHead = Tr('You stopped the scam.', 'आपने धोखा रोक दिया।');
  static const callWonSub = Tr(
    'You ended it at step {n} of {total}. That is exactly what to do.',
    'आपने {total} में से क़दम {n} पर ही कॉल ख़त्म कर दी। बिल्कुल यही करना चाहिए।',
  );
  static const callDeclinedHead = Tr('Good instinct.', 'अच्छी समझ।');
  static const callDeclinedSub = Tr(
    'Unknown callers can wait. Here is what this one would have tried.',
    'अनजान कॉल इंतज़ार कर सकती है। यह कॉल करने वाला क्या करता, वह देखिए।',
  );
  static const callLostHead = Tr(
    'This time, the scammer won.',
    'इस बार धोखेबाज़ जीत गया।',
  );
  static const tricksInCall = Tr('THE TRICKS IN THIS CALL', 'इस कॉल की चालें');
  static const remember = Tr('REMEMBER', 'याद रखें');
  static const tryOtherCall = Tr('Next call: {name}', 'अगली कॉल: {name}');
  static const callPassed = Tr('Passed', 'पास');
  static const callsPassedCount = Tr(
    '{n} of {total} passed',
    '{total} में से {n} पास',
  );
  static const practiceCardNext = Tr('Up next: {name}', 'अगली: {name}');

  // quiz
  static const quizQ = Tr(
    'Is this message real or a scam?',
    'यह संदेश असली है या धोखा?',
  );
  static const quizScam = Tr('Scam', 'धोखा');
  static const quizReal = Tr('Real', 'असली');
  static const correct = Tr('Correct', 'सही');
  static const notQuite = Tr('Not quite', 'यह गलत है');
  static const next = Tr('Next', 'अगला');
  static const finish = Tr('See result', 'नतीजा देखें');
  static const quizResult = Tr(
    'You spotted {n} of {total}.',
    'आपने {total} में से {n} सही पहचाने।',
  );
  static const quizGreat = Tr(
    'Excellent. Share this with someone who needs it.',
    'बहुत बढ़िया। इसे किसी ऐसे को दिखाइए जिसे इसकी ज़रूरत है।',
  );
  static const quizKeep = Tr(
    'Good start. The lessons will sharpen your eye.',
    'अच्छी शुरुआत। पाठ पढ़कर आपकी नज़र और तेज़ होगी।',
  );
  static const tryAgain = Tr('Try again', 'फिर से कोशिश करें');
  static const backToLearn = Tr('Back to lessons', 'पाठों पर वापस');
  static const question = Tr('Question {n} of {total}', 'सवाल {n} / {total}');

  // help
  static const helpTitle = Tr('Help is one tap away.', 'मदद बस एक टैप दूर है।');
  static const helplineTitle = Tr(
    'National Cyber Crime Helpline',
    'राष्ट्रीय साइबर अपराध हेल्पलाइन',
  );
  static const helplineBody = Tr(
    'Lost money? Call within the first hour. The faster you report, the more can be frozen.',
    'पैसे गए? पहले घंटे में कॉल करें। जितनी जल्दी रिपोर्ट, उतना ज़्यादा पैसा रोका जा सकता है।',
  );
  static const portalTitle = Tr('Report online', 'ऑनलाइन रिपोर्ट करें');
  static const portalBody = Tr(
    'File a complaint on the government portal.',
    'सरकारी पोर्टल पर शिकायत दर्ज करें।',
  );
  static const reportNumberTitle = Tr(
    'Report a scam number',
    'धोखेबाज़ नंबर रिपोर्ट करें',
  );
  static const reportNumberBody = Tr(
    'Warn the community. Cyber Sakhis verify each report.',
    'समुदाय को सावधान करें। साइबर सखी हर रिपोर्ट की जाँच करती हैं।',
  );
  static const numberHint = Tr('Phone number', 'फ़ोन नंबर');
  static const report = Tr('Report', 'रिपोर्ट करें');
  static const familyTitle = Tr('Family contact', 'परिवार का संपर्क');
  static const warnTitle = Tr('Warn your family', 'परिवार को सावधान करें');
  static const warnBody = Tr(
    'Send them this message so they don’t fall for the same scam.',
    'उन्हें यह संदेश भेजें ताकि वे इस धोखे में न फँसें।',
  );
  static const warnTo = Tr('To', 'किसे');
  static const warnNumberHint = Tr(
    'Family number (optional)',
    'परिवार का नंबर (वैकल्पिक)',
  );
  static const change = Tr('Change', 'बदलें');
  static const sendWhatsApp = Tr('Send on WhatsApp', 'WhatsApp पर भेजें');
  static const sendSms = Tr('Send as SMS', 'SMS से भेजें');
  static const copyMsg = Tr('Copy message', 'संदेश कॉपी करें');
  static const copied = Tr('Message copied', 'संदेश कॉपी हो गया');
  static const openFailed = Tr(
    'Couldn’t open the app, so the message is copied. Paste it in any chat.',
    'ऐप नहीं खुला, इसलिए संदेश कॉपी कर दिया है। किसी भी चैट में पेस्ट करें।',
  );
  static const familyBody = Tr(
    'We’ll help you alert them when a scam reaches you.',
    'जब कोई धोखा आए, तो हम उन्हें बताने में मदद करेंगे।',
  );
  static const familyHint = Tr('Their mobile number', 'उनका मोबाइल नंबर');
  static const save = Tr('Save', 'सहेजें');
  static const saved = Tr('Saved', 'सहेज लिया');
  static const settings = Tr('SETTINGS', 'सेटिंग');
  static const language = Tr('Language', 'भाषा');
  static const name = Tr('Name', 'नाम');
  static const privacyNote = Tr(
    'Messages you check never leave this phone. Only reports you choose to send are shared.',
    'आप जो संदेश जाँचते हैं, वे इस फ़ोन से बाहर नहीं जाते। सिर्फ़ वही रिपोर्ट भेजी जाती है जो आप ख़ुद भेजें।',
  );
  static const invalidNumber = Tr(
    'Please enter a valid 10-digit Indian mobile number.',
    'कृपया सही 10 अंकों का भारतीय मोबाइल नंबर डालें।',
  );
}

String fill(String s, Map<String, Object> values) {
  var out = s;
  values.forEach((k, v) => out = out.replaceAll('{$k}', '$v'));
  return out;
}
