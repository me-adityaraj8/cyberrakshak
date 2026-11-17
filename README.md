# CyberRakshak · साइबर रक्षक

A bilingual (Hindi / English) app that checks messages, links and phone numbers
for scams on the phone itself, explains why, and helps the user act: call 1930,
alert family, report the scammer, and learn the tricks.

Team project · IIIT Bhagalpur.

**Live:** https://cyberrakshak-iiitbh.vercel.app

## What it does

- **Check a message, link or number** — paste it, or on Android share it
  straight from WhatsApp/SMS (or select text → "Check with CyberRakshak").
- **Explains the verdict** — underlines the words that gave the scam away and
  names fake links that copy a bank or brand ("sbi-kyc-update.in is not SBI;
  the real site is onlinesbi.sbi").
- **Acts on it** — call 1930, warn family on WhatsApp/SMS, report the scam.
- **Practice calls** — four scam calls (bank OTP, "digital arrest", wrong UPI
  transfer, electricity cut-off) where you pick replies and learn the tricks.
- **Lessons and a quiz**, all in Hindi and English, all offline.

## Layout

```
app/   Flutter app (Android APK + website from the same code)
ml/    dataset + training for the scam classifier
```

## How detection works

1. **Model** (`ml/train.py`): logistic regression over hashed word and
   character n-grams. Trained in Python, exported to
   `app/assets/model/scam_model.json`, and run in **pure Dart**
   (`app/lib/detection/`), so it works offline on Android *and* on the web.
2. **Rules** (`app/lib/detection/rules.dart`): hand-written red flags
   (asks for OTP, short links, "digital arrest", fee to receive money, …).
   They add to the model's score and give the user the *reasons*.
3. **Verdict**: `score = sigmoid(model log-odds + rule weights)`;
   ≥ 0.75 scam, ≥ 0.45 careful, otherwise looks OK.

Nothing the user checks leaves the phone.

## Run

```bash
# app
cd app
flutter pub get
flutter run -d chrome          # website
flutter build apk --release    # Android APK
flutter test                   # detection + parity tests

# publish the website (needs `vercel login` once)
scripts/deploy_web.sh

# model
python3 -m venv ml/.venv && ml/.venv/bin/pip install numpy scikit-learn
ml/.venv/bin/python ml/gen_dataset.py
cd ml && .venv/bin/python train.py
```

## Dataset

`ml/data/starter_messages.csv` is generated from templates so the app works on
day one. It is easier than real life. Add real collected messages (remove
personal details) to `ml/data/collected.csv` with the same columns
(`text,label,category,language,template`) and re-run `train.py`; it merges
both files and reports precision, recall, F1 and the false-positive rate on
genuine bank OTPs, evaluated on wordings the model has not seen.

If you change `ml/featurize.py`, make the same change in
`app/lib/detection/featurizer.dart`; `flutter test` checks they agree.

## Fonts

Tiro Devanagari Hindi and Mukta, both under the SIL Open Font License
(`app/assets/fonts/OFL-*.txt`).
