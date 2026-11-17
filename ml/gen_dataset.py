"""Generate the STARTER dataset of scam and genuine messages.

This is a bootstrap so the app works end to end on day one. It is template
based, so it is easier than real life. The team should replace / extend it
with real collected messages in data/collected.csv (same columns); train.py
merges both files automatically.

Columns: text,label,category,language,template
  label: 1 = scam, 0 = safe
"""

import csv
import random
from pathlib import Path

random.seed(7)

BANKS = ["SBI", "HDFC", "ICICI", "PNB", "Axis", "Bank of Baroda", "Canara", "Kotak"]
SHORT = ["bit.ly/{x}", "tinyurl.com/{x}", "rb.gy/{x}", "cutt.ly/{x}", "{b}-kyc-update.xyz", "{b}-secure.top/verify", "{b}online-help.info", "kyc-{b}.site/login"]
AMOUNTS = ["4,999", "12,500", "25,00,000", "9,870", "1,50,000", "49,999", "2,350", "75,000"]
NAMES = ["Sunita", "Ramesh", "Priya", "Arjun", "Meena", "Rahul", "Kavita", "Imran", "Anjali", "Vikas"]
CITIES = ["Mumbai", "Delhi", "Patna", "Bhagalpur", "Lucknow", "Kolkata", "Pune"]
COURIERS = ["FedEx", "DHL", "BlueDart", "India Post", "DTDC"]
APPS = ["AnyDesk", "TeamViewer", "QuickSupport", "RustDesk"]
MERCH = ["Swiggy", "Zomato", "Amazon", "Flipkart", "Myntra", "BigBasket"]


def rnd_code(n=5):
    return "".join(random.choice("abcdefghjkmnpqrstuvwxyz23456789") for _ in range(n))


def link(bank):
    return random.choice(SHORT).format(x=rnd_code(), b=bank.lower().replace(" ", ""))


def phone():
    return f"+91 {random.randint(6, 9)}{random.randint(100000000, 999999999)}"


def otp():
    return str(random.randint(100000, 999999))


def acct():
    return f"XX{random.randint(1000, 9999)}"


# ---------------------------------------------------------------- SCAM ----
SCAM = {
    "kyc": [
        ("en", "Dear customer, your {bank} KYC has expired. Update now {link} or your account will be blocked today."),
        ("en", "{bank} ALERT: Your account will be suspended within 24 hours. Complete PAN KYC at {link}"),
        ("en", "Your {bank} YONO account is blocked due to pending KYC. Click {link} to reactivate immediately."),
        ("hi", "प्रिय ग्राहक, आपका {bank} KYC समाप्त हो गया है। तुरंत {link} पर अपडेट करें वरना आज खाता बंद हो जाएगा।"),
        ("hi", "{bank}: आपका खाता 24 घंटे में बंद कर दिया जाएगा। PAN कार्ड अपडेट करें {link}"),
        ("hx", "Aapka {bank} account aaj band ho jayega. KYC update karne ke liye turant {link} par click karein."),
        ("hx", "Dear user aapka {bank} KYC pending hai, account block hone se bachane ke liye {link} kholein"),
    ],
    "electricity": [
        ("en", "Dear consumer, your electricity power will be disconnected tonight at 9.30 PM because previous month bill was not updated. Call officer {phone}"),
        ("en", "Electricity bill unpaid. Your connection will be cut today. Contact electricity officer immediately {phone}"),
        ("hi", "प्रिय उपभोक्ता, आपका बिजली कनेक्शन आज रात 9:30 बजे काट दिया जाएगा। पिछला बिल अपडेट नहीं है। तुरंत अधिकारी को कॉल करें {phone}"),
        ("hx", "Aapki bijli aaj raat kaat di jayegi, pichla bill update nahi hua. Turant call karein {phone}"),
    ],
    "digital_arrest": [
        ("en", "This is CBI Cyber Cell. A parcel with drugs in your name was seized at {city}. You are under digital arrest. Do not disconnect the video call."),
        ("en", "Mumbai Police: an FIR is registered against your Aadhaar for money laundering. Join video call now or arrest warrant will be issued."),
        ("en", "TRAI notice: your mobile number will be blocked in 2 hours due to illegal activity. Press 9 to speak to the officer."),
        ("hi", "यह CBI साइबर सेल है। आपके नाम का ड्रग्स वाला पार्सल {city} में पकड़ा गया है। आप डिजिटल अरेस्ट में हैं, वीडियो कॉल न काटें।"),
        ("hi", "आपके आधार नंबर पर मनी लॉन्ड्रिंग का केस दर्ज है। तुरंत वीडियो कॉल पर जुड़ें वरना गिरफ्तारी वारंट जारी होगा।"),
        ("hx", "Aapke Aadhaar par police case darj hai. Abhi video call join karein warna arrest ho jayega. Kisi ko mat batana."),
    ],
    "courier": [
        ("en", "{courier}: your parcel is held at customs due to illegal items. Pay clearance fee Rs {amount} at {link} to avoid legal action."),
        ("en", "India Post: your package could not be delivered due to incomplete address. Update within 12 hours {link}"),
        ("hi", "{courier}: आपका पार्सल कस्टम में रोका गया है। कानूनी कार्रवाई से बचने के लिए ₹{amount} जमा करें {link}"),
        ("hx", "Aapka parcel customs mein ruka hai, Rs {amount} fees bharein {link} warna police case hoga"),
    ],
    "lottery": [
        ("en", "Congratulations! Your number has won Rs {amount} in KBC lucky draw. To claim, pay processing fee and call {phone}"),
        ("en", "You have won an iPhone 16 in the {merch} anniversary lucky draw! Claim your prize now at {link}"),
        ("hi", "बधाई हो! आपका नंबर KBC लॉटरी में ₹{amount} जीता है। इनाम पाने के लिए प्रोसेसिंग फीस भरें और {phone} पर कॉल करें।"),
        ("hx", "Badhai ho! Aapne KBC mein Rs {amount} jeete hain. Claim karne ke liye {phone} par WhatsApp karein."),
    ],
    "govt_scheme": [
        ("en", "PM Kisan: your installment of Rs {amount} is pending. Verify Aadhaar and bank details at {link} to receive money."),
        ("en", "Govt free laptop / ration scheme registration closing today. Apply now with Aadhaar and OTP {link}"),
        ("hi", "पीएम किसान: आपकी ₹{amount} की किस्त रुकी हुई है। पैसा पाने के लिए आधार और बैंक विवरण {link} पर सत्यापित करें।"),
        ("hi", "सरकारी योजना में आपका नाम आया है। ₹{amount} पाने के लिए अपना आधार नंबर और OTP भेजें।"),
        ("hx", "Sarkari yojana ke ₹{amount} aapke khate mein aane wale hain, Aadhaar aur OTP bhejein {phone}"),
    ],
    "job_task": [
        ("en", "Part time job: earn Rs 3000-8000 daily by liking YouTube videos. No investment. WhatsApp {phone}"),
        ("en", "Hello, I am HR from {merch}. Work from home, simple tasks, daily payment. Join Telegram to start {link}"),
        ("hi", "घर बैठे काम करें, रोज़ ₹5000 कमाएँ। सिर्फ़ वीडियो लाइक करने हैं। व्हाट्सएप करें {phone}"),
        ("hx", "Ghar baithe kamaayein Rs 5000 roz, bas task complete karna hai. Telegram join karein {link}"),
    ],
    "investment": [
        ("en", "Join our VIP stock tips group. Guaranteed 300% returns in 30 days. Limited seats {link}"),
        ("en", "Invest Rs 10,000 in crypto and get Rs 50,000 in one week. 100% safe and guaranteed. Contact {phone}"),
        ("hi", "सिर्फ़ 30 दिन में पैसा तीन गुना! क्रिप्टो में निवेश करें, 100% गारंटी। {link}"),
        ("hx", "Crypto mein invest karo, ek hafte mein paisa double guaranteed. Abhi join karo {link}"),
    ],
    "otp_share": [
        ("en", "Sir I mistakenly sent an OTP to your number, please share it with me urgently it is very important."),
        ("en", "{bank} customer care: to stop the unauthorised transaction of Rs {amount}, share the OTP you just received with our executive."),
        ("en", "To receive your refund of Rs {amount}, please enter your UPI PIN on the payment request we sent."),
        ("hi", "गलती से आपके नंबर पर OTP चला गया है, कृपया वह OTP मुझे बता दीजिए, बहुत ज़रूरी है।"),
        ("hi", "{bank} कस्टमर केयर: ₹{amount} का लेन-देन रोकने के लिए अभी आया OTP हमारे अधिकारी को बताएं।"),
        ("hx", "Bhaiya galti se OTP aapke number par chala gaya, please bata do urgent hai"),
        ("hx", "Refund ke liye UPI PIN daalein, paisa turant aapke account mein aa jayega"),
    ],
    "remote_access": [
        ("en", "{bank} support: to fix your net banking issue please install {app} and share the 9 digit code with our executive."),
        ("hi", "आपकी समस्या ठीक करने के लिए {app} ऐप डाउनलोड करें और कोड हमारे अधिकारी को बताएं।"),
        ("hx", "Problem solve karne ke liye {app} app install karke code share karein"),
    ],
    "loan": [
        ("en", "Instant loan approved Rs {amount} without CIBIL. Pay Rs 999 processing fee to get money in 10 minutes {link}"),
        ("hi", "बिना CIBIL ₹{amount} का लोन मंज़ूर! 10 मिनट में पैसा पाने के लिए ₹999 फीस भरें {link}"),
        ("hx", "Bina documents Rs {amount} ka loan turant, bas processing fees bharein {link}"),
    ],
    "family_impersonation": [
        ("en", "Hi Mom, this is my new number, my phone broke. I need Rs {amount} urgently, please send to this UPI and don't call."),
        ("hi", "पापा मेरा फ़ोन खराब हो गया, यह नया नंबर है। ₹{amount} तुरंत इस UPI पर भेज दो, कॉल मत करना।"),
        ("hx", "Mummy mera phone kharab ho gaya, ye naya number hai. Urgent Rs {amount} bhejo, call mat karna"),
    ],
}

# ---------------------------------------------------------------- SAFE ----
SAFE = {
    "bank_otp": [
        ("en", "{otp} is your OTP for transaction of Rs {amount} at {merch}. Valid for 10 mins. Do not share it with anyone. -{bank}"),
        ("en", "Your {bank} net banking login OTP is {otp}. Never share your OTP with anyone, bank officials never ask for it."),
        ("en", "OTP {otp} for your {merch} order verification. Do not share this code."),
        ("hi", "{otp} आपके ₹{amount} के लेन-देन का OTP है। इसे किसी के साथ साझा न करें। -{bank}"),
        ("hx", "{otp} aapka login OTP hai. Kisi ke saath share na karein. -{bank}"),
    ],
    "bank_alert": [
        ("en", "Rs {amount} debited from A/c {acct} on {date} to UPI {name}. Not you? Call {bank} official helpline."),
        ("en", "Your A/c {acct} is credited with Rs {amount} on {date} by NEFT. Available balance updated. -{bank}"),
        ("en", "Salary of Rs {amount} credited to your {bank} account {acct}."),
        ("hi", "आपके खाते {acct} से ₹{amount} {date} को डेबिट हुए। यह आपने नहीं किया? बैंक हेल्पलाइन पर संपर्क करें।"),
        ("hx", "Aapke account {acct} mein Rs {amount} credit hue hain. -{bank}"),
    ],
    "delivery": [
        ("en", "Your {merch} order has been shipped and will be delivered by tomorrow. Track it in the app."),
        ("en", "{courier}: your shipment is out for delivery today. Delivery agent will call before arriving."),
        ("en", "Your {merch} order was delivered. Rate your experience in the app."),
        ("hi", "आपका {merch} ऑर्डर भेज दिया गया है और कल तक पहुँच जाएगा।"),
        ("hx", "Aapka {merch} order kal tak deliver ho jayega."),
    ],
    "recharge_bill": [
        ("en", "Your recharge of Rs 299 is successful. Validity 28 days. Thank you for choosing us."),
        ("en", "Electricity bill of Rs {amount} for {city} account paid successfully. Receipt available in your app."),
        ("hi", "आपका ₹299 का रिचार्ज सफल रहा। वैधता 28 दिन।"),
        ("hx", "Aapka bijli bill Rs {amount} jama ho gaya hai, dhanyavaad."),
    ],
    "family": [
        ("en", "Hi {name}, reached {city} safely. Will call you in the evening."),
        ("en", "Don't forget to bring the vegetables on your way back home."),
        ("en", "Happy birthday {name}! Have a wonderful year ahead."),
        ("hi", "{name}, मैं {city} पहुँच गया हूँ। शाम को फ़ोन करूँगा।"),
        ("hi", "घर आते समय सब्ज़ी ले आना।"),
        ("hx", "{name} kal shaadi mein milte hain, time se aa jana"),
        ("hx", "Khana kha liya? Shaam ko baat karte hain"),
    ],
    "appointment": [
        ("en", "Your appointment with Dr. Sharma is confirmed for tomorrow at 11 AM at City Hospital."),
        ("en", "Parent teacher meeting is on Saturday at 10 AM. Please attend."),
        ("hi", "आपकी डॉक्टर से मुलाक़ात कल सुबह 11 बजे तय है।"),
        ("hx", "Kal school mein PTM hai 10 baje, zaroor aana"),
    ],
    "promo": [
        ("en", "{merch}: Flat 20% off on your next order this weekend. Offer valid in app only. T&C apply."),
        ("en", "Your {merch} wallet has cashback of Rs 50 that expires on Sunday. Use it on your next order in the app."),
        ("hi", "{merch} पर इस हफ़्ते 20% की छूट। ऐप में ऑफ़र देखें।"),
    ],
    "govt_info": [
        ("en", "PM Kisan installment of Rs 2,000 has been credited to your registered bank account. Check status on the official portal."),
        ("en", "Your Aadhaar was used for authentication on {date}. If not done by you, contact UIDAI on 1947."),
        ("hi", "पीएम किसान की ₹2,000 की किस्त आपके बैंक खाते में जमा कर दी गई है।"),
    ],
}


def fill(tpl):
    bank = random.choice(BANKS)
    return tpl.format(
        bank=bank, link=link(bank), amount=random.choice(AMOUNTS), phone=phone(),
        city=random.choice(CITIES), courier=random.choice(COURIERS), merch=random.choice(MERCH),
        app=random.choice(APPS), otp=otp(), acct=acct(), name=random.choice(NAMES),
        date=f"{random.randint(1, 28):02d}-{random.randint(1, 12):02d}-25",
    )


def main():
    rows = []
    for label, table in ((1, SCAM), (0, SAFE)):
        for cat, templates in table.items():
            for i, (lang, tpl) in enumerate(templates):
                tid = f"{cat}-{i}"
                seen = set()
                for _ in range(14):
                    text = fill(tpl)
                    if text not in seen:
                        seen.add(text)
                        rows.append({"text": text, "label": label, "category": cat, "language": lang, "template": tid})
    random.shuffle(rows)
    out = Path(__file__).parent / "data" / "starter_messages.csv"
    with out.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["text", "label", "category", "language", "template"])
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {len(rows)} rows -> {out}")


if __name__ == "__main__":
    main()
