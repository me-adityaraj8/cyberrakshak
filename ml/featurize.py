"""Feature extraction shared by training (Python) and the app (Dart).

The Dart port lives in app/lib/detection/featurizer.dart and MUST stay
byte-for-byte identical in behaviour. Any change here needs the same change
there, and `python ml/export_fixtures.py` regenerates the parity fixtures the
Dart tests check against.

Pipeline:
  1. normalize: lowercase, URLs -> "urltok", every digit -> "0"
  2. tokenize: runs of letters, combining marks and digits (works for Hindi)
  3. features: word unigrams, word bigrams, char 3-grams inside each word
  4. hash each feature string with FNV-1a (32-bit, web-safe arithmetic)
     into NUM_BUCKETS buckets; vector is binary presence, L2-normalised
"""

import re
import unicodedata

NUM_BUCKETS = 1 << 14  # 16384

_URL = re.compile(r"(https?://\S+|www\.\S+|\b[a-z0-9-]+\.(?:ly|in|com|xyz|top|info|link|site|online|co|net|org|me|io|app)(?:/\S*)?)", re.ASCII)
_DIGIT = re.compile(r"[0-9०-९]")  # ASCII + Devanagari digits


def normalize(text: str) -> str:
    t = text.lower()
    t = _URL.sub(" urltok ", t)
    t = _DIGIT.sub("0", t)
    return t


def _is_token_char(ch: str) -> bool:
    cat = unicodedata.category(ch)
    return cat[0] in ("L", "M", "N")


def tokenize(text: str) -> list[str]:
    tokens, cur = [], []
    for ch in normalize(text):
        if _is_token_char(ch):
            cur.append(ch)
        elif cur:
            tokens.append("".join(cur))
            cur = []
    if cur:
        tokens.append("".join(cur))
    return tokens


def features(text: str) -> list[str]:
    toks = tokenize(text)
    out = [f"w:{t}" for t in toks]
    out += [f"b:{a} {b}" for a, b in zip(toks, toks[1:])]
    for t in toks:
        padded = f" {t} "
        for i in range(len(padded) - 2):
            out.append(f"c:{padded[i:i + 3]}")
    return out


def fnv1a(s: str) -> int:
    h = 2166136261
    for byte in s.encode("utf-8"):
        h ^= byte
        # h * 16777619 mod 2^32, split so it never exceeds 2^53 (JS-safe)
        h = ((h & 0xFF) * 16777216 + h * 403) % 4294967296
    return h


def bucket_ids(text: str) -> list[int]:
    return sorted({fnv1a(f) % NUM_BUCKETS for f in features(text)})
