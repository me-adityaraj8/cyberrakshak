"""Train the CyberRakshak scam classifier and export it for the app.

    ml/.venv/bin/python ml/gen_dataset.py     # (re)build the starter dataset
    ml/.venv/bin/python ml/train.py           # evaluate, train, export

Model: logistic regression over hashed word/char n-gram features
(see featurize.py). Small, fast, explainable, and runs in pure Dart on
Android and on the web with no ML runtime.

Evaluation holds out whole TEMPLATES (GroupKFold), so the score reflects
messages worded differently from anything seen in training.
"""

import csv
import json
from pathlib import Path

import numpy as np
from scipy.sparse import csr_matrix
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix, f1_score, precision_score, recall_score
from sklearn.model_selection import GroupKFold

from featurize import NUM_BUCKETS, bucket_ids

ROOT = Path(__file__).parent
DATA = ROOT / "data"
EXPORT = ROOT.parent / "app" / "assets" / "model"
C = 4.0


def load():
    rows = []
    for name in ("starter_messages.csv", "collected.csv"):
        p = DATA / name
        if p.exists():
            with p.open(encoding="utf-8") as f:
                for r in csv.DictReader(f):
                    r["template"] = r.get("template") or f"{name}-{len(rows)}"
                    rows.append(r)
    return rows


def vectorize(texts):
    indptr, indices, data = [0], [], []
    for t in texts:
        ids = bucket_ids(t)
        v = 1.0 / np.sqrt(len(ids)) if ids else 0.0
        indices.extend(ids)
        data.extend([v] * len(ids))
        indptr.append(len(indices))
    return csr_matrix((data, indices, indptr), shape=(len(texts), NUM_BUCKETS))


def main():
    rows = load()
    texts = [r["text"] for r in rows]
    y = np.array([int(r["label"]) for r in rows])
    groups = [r["template"] for r in rows]
    cats = np.array([r["category"] for r in rows])
    X = vectorize(texts)
    print(f"{len(rows)} messages · {y.sum()} scam · {len(y) - y.sum()} safe")

    pred = np.zeros_like(y)
    for tr, te in GroupKFold(n_splits=5).split(X, y, groups):
        m = LogisticRegression(C=C, max_iter=2000, class_weight="balanced").fit(X[tr], y[tr])
        pred[te] = (m.predict_proba(X[te])[:, 1] >= 0.5).astype(int)

    tn, fp, fn, tp = confusion_matrix(y, pred).ravel()
    otp = cats == "bank_otp"
    report = {
        "messages": len(rows),
        "precision": round(float(precision_score(y, pred)), 3),
        "recall": round(float(recall_score(y, pred)), 3),
        "f1": round(float(f1_score(y, pred)), 3),
        "confusion": {"tn": int(tn), "fp": int(fp), "fn": int(fn), "tp": int(tp)},
        "false_positive_rate_bank_otp": round(float(pred[otp].mean()), 3) if otp.any() else None,
        "evaluation": "5-fold GroupKFold, unseen templates",
    }
    print(json.dumps(report, indent=2))

    model = LogisticRegression(C=C, max_iter=2000, class_weight="balanced").fit(X, y)
    w = model.coef_[0]
    weights = {str(i): round(float(w[i]), 5) for i in np.nonzero(np.abs(w) > 1e-6)[0]}
    EXPORT.mkdir(parents=True, exist_ok=True)
    (EXPORT / "scam_model.json").write_text(json.dumps({
        "version": 1,
        "buckets": NUM_BUCKETS,
        "bias": round(float(model.intercept_[0]), 5),
        "weights": weights,
        "metrics": report,
    }, separators=(",", ":")), encoding="utf-8")

    # parity fixtures: the Dart tests must reproduce these exactly
    samples = [
        "Dear customer, your SBI KYC has expired. Update now bit.ly/ab12x or account blocked today.",
        "482913 is your OTP for transaction of Rs 4,999 at Amazon. Do not share it with anyone. -HDFC",
        "आपका बिजली कनेक्शन आज रात काट दिया जाएगा, तुरंत कॉल करें +91 9876543210",
        "Mummy mera phone kharab ho gaya, urgent Rs 5000 bhejo",
        "Hi Priya, reached Patna safely. Will call you in the evening.",
        "",
    ]
    Xs = vectorize(samples)
    fixtures = [{"text": s, "buckets": bucket_ids(s), "prob": round(float(p), 6)}
                for s, p in zip(samples, model.predict_proba(Xs)[:, 1])]
    fx = ROOT.parent / "app" / "test" / "fixtures"
    fx.mkdir(parents=True, exist_ok=True)
    (fx / "model_parity.json").write_text(json.dumps(fixtures, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"exported {len(weights)} weights -> {EXPORT / 'scam_model.json'}")


if __name__ == "__main__":
    main()
