"""Build a MAPS wave-6 single-wave item-response file for LLM-DIF evaluation.

This script does not alter the original pooled 1-5 wave outputs. It creates
separate wave-6 outputs used to evaluate the already-generated LLM predictions
against a cleaner single-wave provisional DIF screen.
"""

from pathlib import Path

import numpy as np
import pandas as pd


OUT_DIR = Path("llm_dif_output")
SOURCE_ROOT = Path("MAPS 2기 패널_Data_CSV (1)")
WAVE = 6
SUFFIX = f"_w{WAVE}"


def valid_ord(x):
    out = pd.to_numeric(x, errors="coerce")
    out = out.where(out.isin([1, 2, 3, 4, 5]))
    return out


def valid_positive(x):
    out = pd.to_numeric(x, errors="coerce")
    out = out.where(out >= 0)
    return out


def valid_int(x):
    return pd.to_numeric(x, errors="coerce").astype("Int64")


def first_existing(df, candidates, default=np.nan):
    for c in candidates:
        if c in df.columns:
            return df[c]
    return pd.Series([default] * len(df), index=df.index)


def row_mean_existing(df, candidates):
    hit = [c for c in candidates if c in df.columns]
    if not hit:
        return pd.Series([np.nan] * len(df), index=df.index)
    mat = pd.concat([valid_ord(df[c]) for c in hit], axis=1)
    return mat.mean(axis=1, skipna=True)


def recode_yes_no(x):
    raw = pd.to_numeric(x, errors="coerce")
    out = pd.Series([np.nan] * len(raw), index=raw.index)
    out[raw == 1] = 1
    out[raw == 2] = 0
    return out


def zscore(x):
    x = pd.to_numeric(x, errors="coerce")
    sd = x.std(skipna=True)
    if pd.isna(sd) or sd == 0:
        return pd.Series([np.nan] * len(x), index=x.index)
    return (x - x.mean(skipna=True)) / sd


def find_file(kind):
    files = list(SOURCE_ROOT.rglob(f"*{kind} 6차년도.xlsx"))
    if len(files) != 1:
        raise FileNotFoundError(f"Expected one {kind} 6차년도 xlsx, found {len(files)}")
    return files[0]


def build_rows(df, item_catalog, respondent_type, base):
    rows = []
    sub = item_catalog[item_catalog["respondent_type"] == respondent_type].copy()
    for _, item in sub.iterrows():
        col = f"{item['item_stem']}{SUFFIX}"
        if col not in df.columns:
            continue
        resp = valid_ord(df[col])
        temp = base.copy()
        temp["scale_id"] = item["scale_id"]
        temp["scale_name"] = item["scale_name"]
        temp["item_stem"] = item["item_stem"]
        temp["item_variable"] = col
        temp["item_id"] = item["item_id"]
        temp["item_text"] = item.get("item_text", np.nan)
        temp["item_text_status"] = item.get("item_text_status", np.nan)
        temp["resp"] = resp
        temp = temp[temp["resp"].notna()]
        rows.append(temp)
    if not rows:
        return pd.DataFrame()
    return pd.concat(rows, ignore_index=True)


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    item_catalog = pd.read_csv(OUT_DIR / "maps_llm_item_catalog_filled.csv")

    parent_file = find_file("학부모")
    youth_file = find_file("청소년")
    parent = pd.read_excel(parent_file, sheet_name="Sheet1")
    youth = pd.read_excel(youth_file, sheet_name="Sheet1")

    parent_income = valid_positive(first_existing(parent, [f"income_a01{SUFFIX}"]))
    parent_korean = row_mean_existing(parent, [f"ko_language_c{i}{SUFFIX}" for i in range(1, 5)])
    parent_base = pd.DataFrame({
        "respondent_type": "parent",
        "source_file": parent_file.name,
        "ID": valid_int(parent["ID"]).astype(float),
        "person_id": "parent_" + parent["ID"].astype(str),
        "wave": WAVE,
        "age": valid_positive(first_existing(parent, [f"par_age_1{SUFFIX}"])),
        "gender": np.nan,
        "nation": valid_int(first_existing(parent, [f"par_nat_1{SUFFIX}"])).astype(float),
        "education": valid_int(first_existing(parent, [f"par_edu_1{SUFFIX}"])).astype(float),
        "income": parent_income,
        "log_income": np.log(np.maximum(parent_income, 1)),
        "korean_score": parent_korean,
        "discrim_any": recode_yes_no(first_existing(parent, [f"p_discrim_a01{SUFFIX}"])),
    })

    youth_income = valid_positive(first_existing(youth, [f"income_a01{SUFFIX}"]))
    youth_korean = row_mean_existing(youth, [f"korean_ab_b0{i}{SUFFIX}" for i in range(1, 5)])
    gender_raw = pd.to_numeric(first_existing(youth, [f"S_GENDER{SUFFIX}"]), errors="coerce")
    gender01 = pd.Series([np.nan] * len(gender_raw), index=gender_raw.index)
    gender01[gender_raw == 1] = 0
    gender01[gender_raw == 2] = 1
    youth_base = pd.DataFrame({
        "respondent_type": "youth",
        "source_file": youth_file.name,
        "ID": valid_int(youth["ID"]).astype(float),
        "person_id": "youth_" + youth["ID"].astype(str),
        "wave": WAVE,
        "age": valid_positive(first_existing(youth, [f"S_AGE{SUFFIX}"])),
        "gender": gender01,
        "nation": valid_int(first_existing(youth, [f"par_nat_1{SUFFIX}"])).astype(float),
        "education": valid_int(first_existing(youth, [f"par_edu_1{SUFFIX}"])).astype(float),
        "income": youth_income,
        "log_income": np.log(np.maximum(youth_income, 1)),
        "korean_score": youth_korean,
        "discrim_any": recode_yes_no(first_existing(youth, [f"s_discrim_a01{SUFFIX}"])),
    })

    longdat = pd.concat([
        build_rows(parent, item_catalog, "parent", parent_base),
        build_rows(youth, item_catalog, "youth", youth_base),
    ], ignore_index=True)

    for resp, idx in longdat.groupby("respondent_type").groups.items():
        longdat.loc[idx, "age_c"] = zscore(longdat.loc[idx, "age"])
        longdat.loc[idx, "income_c"] = zscore(longdat.loc[idx, "log_income"])
        longdat.loc[idx, "korean_c"] = zscore(longdat.loc[idx, "korean_score"])

    longdat = longdat.sort_values(["respondent_type", "person_id", "scale_id", "item_stem"])
    longdat.to_csv(OUT_DIR / "maps_multiscale_long_w6.csv", index=False, encoding="utf-8-sig")

    qc = (
        longdat.groupby(["respondent_type", "scale_id", "scale_name"])
        .agg(
            persons=("person_id", "nunique"),
            waves=("wave", "nunique"),
            items=("item_id", "nunique"),
            rows=("resp", "size"),
            missing_discrim_rows=("discrim_any", lambda s: s.isna().sum()),
            missing_korean_rows=("korean_score", lambda s: s.isna().sum()),
            missing_income_rows=("log_income", lambda s: s.isna().sum()),
        )
        .reset_index()
    )
    qc.to_csv(OUT_DIR / "maps_multiscale_qc_w6.csv", index=False, encoding="utf-8-sig")
    print("Saved", OUT_DIR / "maps_multiscale_long_w6.csv", longdat.shape)
    print("Saved", OUT_DIR / "maps_multiscale_qc_w6.csv")
    print(qc.to_string(index=False))


if __name__ == "__main__":
    main()
