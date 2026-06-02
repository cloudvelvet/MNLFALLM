"""Offline embedding/similarity baseline for MAPS LLM-DIF screening.

The script is intentionally API-free. It first looks for a locally cached
sentence-transformer model and uses it only when loading can be done in offline
mode. If no cached model is available, it falls back to a transparent TF-IDF
word/character n-gram cosine-similarity baseline.

Outputs are written with "embedding" in the filename so existing LLM, keyword,
and manuscript files are not touched.
"""

from __future__ import annotations

import os
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

import numpy as np
import pandas as pd


OUT_DIR = Path("llm_dif_output")
PAIRS_CSV = OUT_DIR / "maps_llm_full_item_covariate_pairs.csv"
MAIN_JOINED = OUT_DIR / "maps_llm_gemini_sensitivity_eval_joined_binary_keyword.csv"
W6_JOINED = OUT_DIR / "maps_llm_gemini_sensitivity_eval_joined_binary_keyword_w6.csv"


COVARIATE_DEFINITIONS: Dict[str, str] = {
    "age_c": (
        "respondent age; developmental stage; schooling grade; future plans; "
        "parenting age or child age; age-related social roles"
    ),
    "discrim_any": (
        "reported discrimination experience; unfair treatment; exclusion; "
        "being ignored, teased, rejected, or treated differently because of "
        "immigrant, ethnic, cultural, or national background"
    ),
    "gender": (
        "respondent gender; sex; male or female identity; gendered peer "
        "relations; body, appearance, dating, family roles, or gender norms"
    ),
    "income_c": (
        "household income; economic resources; financial hardship; material "
        "support; money, cost, housing, work, health care, school supplies, "
        "or affordability"
    ),
    "korean_c": (
        "Korean language and culture; Korean identity; Korean people; host "
        "society orientation; acculturation; communication in Korean; comfort "
        "with Korean friends, school, work, or community"
    ),
}


def text_or_blank(value: object) -> str:
    if pd.isna(value):
        return ""
    return str(value)


def build_item_context(row: pd.Series) -> str:
    parts = [
        f"respondent type: {text_or_blank(row.get('respondent_type'))}",
        f"scale id: {text_or_blank(row.get('scale_id'))}",
        f"scale name: {text_or_blank(row.get('scale_name'))}",
        f"item stem: {text_or_blank(row.get('item_stem'))}",
        f"item text: {text_or_blank(row.get('item_text'))}",
        f"response options: {text_or_blank(row.get('response_options'))}",
    ]
    return " | ".join(p for p in parts if p.strip())


def covariate_definition(row: pd.Series) -> str:
    covariate = text_or_blank(row.get("covariate"))
    label = text_or_blank(row.get("covariate_label"))
    applies_to = text_or_blank(row.get("applies_to"))
    definition = COVARIATE_DEFINITIONS.get(covariate, label)
    return (
        f"covariate: {covariate} | label: {label} | applies to: {applies_to} | "
        f"definition: {definition}"
    )


def usual_sentence_transformer_cache_roots() -> List[Path]:
    home = Path.home()
    return [
        home / ".cache" / "torch" / "sentence_transformers",
        home / ".cache" / "sentence_transformers",
        home / ".cache" / "huggingface" / "hub",
    ]


def cached_sentence_transformer_candidates() -> List[str]:
    candidates: List[str] = []
    for root in usual_sentence_transformer_cache_roots():
        if not root.exists():
            continue
        for config in root.rglob("config.json"):
            model_dir = config.parent
            if (model_dir / "modules.json").exists():
                candidates.append(str(model_dir))
    return sorted(set(candidates))


def try_sentence_transformer_similarity(
    item_contexts: List[str], covariate_contexts: List[str]
) -> Tuple[Optional[np.ndarray], str, str]:
    candidates = cached_sentence_transformer_candidates()
    if not candidates:
        return None, "tfidf_ngram_offline", "No cached sentence-transformer model found."

    os.environ.setdefault("HF_HUB_OFFLINE", "1")
    os.environ.setdefault("TRANSFORMERS_OFFLINE", "1")
    try:
        from sentence_transformers import SentenceTransformer
    except Exception as exc:  # pragma: no cover - depends on local environment
        return None, "tfidf_ngram_offline", f"sentence_transformers import failed: {exc}"

    for model_path in candidates:
        try:
            model = SentenceTransformer(model_path, local_files_only=True)
            item_emb = model.encode(
                item_contexts, normalize_embeddings=True, show_progress_bar=False
            )
            cov_emb = model.encode(
                covariate_contexts, normalize_embeddings=True, show_progress_bar=False
            )
            similarity = np.sum(np.asarray(item_emb) * np.asarray(cov_emb), axis=1)
            return (
                similarity,
                "sentence_transformer_cached",
                f"Loaded cached sentence-transformer model: {model_path}",
            )
        except Exception as exc:  # pragma: no cover - depends on local environment
            last_error = f"Cached model load failed for {model_path}: {exc}"

    return None, "tfidf_ngram_offline", last_error


def tfidf_ngram_similarity(
    item_contexts: List[str], covariate_contexts: List[str]
) -> np.ndarray:
    from scipy.sparse import hstack
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.preprocessing import normalize

    corpus = item_contexts + covariate_contexts
    n_items = len(item_contexts)

    word_vec = TfidfVectorizer(
        analyzer="word",
        ngram_range=(1, 2),
        lowercase=True,
        min_df=1,
        token_pattern=r"(?u)\b\w+\b",
        norm="l2",
    )
    char_vec = TfidfVectorizer(
        analyzer="char_wb",
        ngram_range=(3, 5),
        lowercase=True,
        min_df=1,
        norm="l2",
    )
    word_x = word_vec.fit_transform(corpus)
    char_x = char_vec.fit_transform(corpus)
    x = normalize(hstack([word_x, char_x], format="csr"), norm="l2")

    item_x = x[:n_items]
    cov_x = x[n_items:]
    return np.asarray(item_x.multiply(cov_x).sum(axis=1)).ravel()


def scale_to_0_100(values: Iterable[float]) -> np.ndarray:
    arr = np.asarray(list(values), dtype=float)
    if arr.size == 0:
        return arr
    lo = np.nanmin(arr)
    hi = np.nanmax(arr)
    if not np.isfinite(lo) or not np.isfinite(hi) or hi == lo:
        return np.zeros_like(arr)
    return (arr - lo) / (hi - lo) * 100.0


def average_precision(label: pd.Series, score: pd.Series) -> float:
    ok = label.notna() & score.notna()
    y = label[ok].astype(bool).to_numpy()
    s = score[ok].astype(float).to_numpy()
    if len(y) == 0 or y.sum() == 0:
        return np.nan
    order = np.argsort(-s, kind="mergesort")
    y = y[order]
    precision = np.cumsum(y) / np.arange(1, len(y) + 1)
    return float(precision[y].sum() / y.sum())


def precision_at_k(label: pd.Series, score: pd.Series, k: int) -> float:
    ok = label.notna() & score.notna()
    y = label[ok].astype(bool).to_numpy()
    s = score[ok].astype(float).to_numpy()
    if len(y) == 0:
        return np.nan
    k = min(k, len(y))
    order = np.argsort(-s, kind="mergesort")[:k]
    return float(y[order].mean())


def metric_one(df: pd.DataFrame, group: str, prompt_version: str, model: str) -> dict:
    return {
        "prompt_version": prompt_version,
        "model": model,
        "group": group,
        "n_pairs": len(df),
        "n_items": df["item_id"].nunique(),
        "positives": int(df["dif_label"].fillna(False).astype(bool).sum()),
        "positive_prevalence": df["dif_label"].astype(float).mean(),
        "mean_llm_score": df["threshold_dif_probability_0_100"].mean(),
        "keyword_hit_rate": df["keyword_hit"].astype(float).mean(),
        "mean_embedding_score": df["embedding_score_0_100"].mean(),
        "llm_average_precision": average_precision(
            df["dif_label"], df["threshold_dif_probability_0_100"]
        ),
        "llm_precision_at_5": precision_at_k(
            df["dif_label"], df["threshold_dif_probability_0_100"], 5
        ),
        "llm_precision_at_10": precision_at_k(
            df["dif_label"], df["threshold_dif_probability_0_100"], 10
        ),
        "keyword_average_precision": average_precision(
            df["dif_label"], df["keyword_score_0_100"]
        ),
        "keyword_precision_at_5": precision_at_k(
            df["dif_label"], df["keyword_score_0_100"], 5
        ),
        "keyword_precision_at_10": precision_at_k(
            df["dif_label"], df["keyword_score_0_100"], 10
        ),
        "embedding_average_precision": average_precision(
            df["dif_label"], df["embedding_score_0_100"]
        ),
        "embedding_precision_at_5": precision_at_k(
            df["dif_label"], df["embedding_score_0_100"], 5
        ),
        "embedding_precision_at_10": precision_at_k(
            df["dif_label"], df["embedding_score_0_100"], 10
        ),
    }


def evaluate_joined(joined_path: Path, suffix: str, predictions: pd.DataFrame) -> pd.DataFrame:
    joined = pd.read_csv(joined_path, encoding="utf-8")
    joined = joined.merge(
        predictions[
            [
                "scale_id",
                "item_id",
                "covariate",
                "item_context_for_embedding",
                "covariate_definition_for_embedding",
                "embedding_similarity",
                "embedding_score_0_100",
                "embedding_method",
            ]
        ],
        on=["scale_id", "item_id", "covariate"],
        how="left",
    )
    joined["dif_label"] = joined["dif_label"].astype(bool)
    joined["keyword_hit"] = joined["keyword_hit"].astype(bool)

    rows = []
    for prompt_version in sorted(joined["prompt_version"].dropna().unique()):
        prompt_df = joined[joined["prompt_version"] == prompt_version]
        for model in sorted(prompt_df["model"].dropna().unique()):
            one = prompt_df[prompt_df["model"] == model]
            rows.append(metric_one(one, "overall", prompt_version, model))
            for covariate in sorted(one["covariate"].dropna().unique()):
                rows.append(
                    metric_one(
                        one[one["covariate"] == covariate],
                        f"covariate:{covariate}",
                        prompt_version,
                        model,
                    )
                )

    metrics = pd.DataFrame(rows)
    joined_out = OUT_DIR / f"maps_llm_embedding_eval_joined{suffix}.csv"
    metrics_out = OUT_DIR / f"maps_llm_embedding_eval_metrics{suffix}.csv"
    joined.to_csv(joined_out, index=False, encoding="utf-8")
    metrics.to_csv(metrics_out, index=False, encoding="utf-8")
    return metrics


def write_notes(method: str, detail: str, n_pairs: int) -> None:
    note_path = OUT_DIR / "maps_llm_embedding_similarity_notes.txt"
    roots = usual_sentence_transformer_cache_roots()
    lines = [
        "MAPS offline embedding/similarity baseline",
        "",
        f"Method used: {method}",
        f"Pairs scored: {n_pairs}",
        f"Method detail: {detail}",
        "",
        "Offline policy:",
        "- No API calls are made.",
        "- sentence_transformers is used only when a local model is found and can be loaded offline.",
        "- Otherwise, scores are TF-IDF word/character n-gram cosine similarities between item/scale context and a covariate definition.",
        "",
        "Checked local cache roots:",
        *[f"- {root} (exists={root.exists()})" for root in roots],
    ]
    note_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    if not PAIRS_CSV.exists():
        raise FileNotFoundError(f"Missing input file: {PAIRS_CSV}")
    if not MAIN_JOINED.exists():
        raise FileNotFoundError(f"Missing input file: {MAIN_JOINED}")
    if not W6_JOINED.exists():
        raise FileNotFoundError(f"Missing input file: {W6_JOINED}")

    pairs = pd.read_csv(PAIRS_CSV, encoding="utf-8")
    pairs["item_context_for_embedding"] = pairs.apply(build_item_context, axis=1)
    pairs["covariate_definition_for_embedding"] = pairs.apply(covariate_definition, axis=1)

    item_contexts = pairs["item_context_for_embedding"].tolist()
    covariate_contexts = pairs["covariate_definition_for_embedding"].tolist()

    similarity, method, detail = try_sentence_transformer_similarity(
        item_contexts, covariate_contexts
    )
    if similarity is None:
        similarity = tfidf_ngram_similarity(item_contexts, covariate_contexts)
        method = "tfidf_ngram_offline"

    pairs["embedding_similarity"] = similarity
    pairs["embedding_score_0_100"] = scale_to_0_100(similarity)
    pairs["embedding_method"] = method

    pred_out = OUT_DIR / "maps_llm_embedding_similarity_predictions.csv"
    pairs.to_csv(pred_out, index=False, encoding="utf-8")
    write_notes(method, detail, len(pairs))

    main_metrics = evaluate_joined(MAIN_JOINED, "", pairs)
    w6_metrics = evaluate_joined(W6_JOINED, "_w6", pairs)

    summary_cols = [
        "prompt_version",
        "group",
        "embedding_average_precision",
        "embedding_precision_at_5",
        "embedding_precision_at_10",
        "llm_average_precision",
        "keyword_average_precision",
    ]
    print("Embedding/similarity baseline method:", method)
    print("\nMain overall metrics:")
    print(main_metrics[main_metrics["group"] == "overall"][summary_cols].to_string(index=False))
    print("\nWave-6 overall metrics:")
    print(w6_metrics[w6_metrics["group"] == "overall"][summary_cols].to_string(index=False))


if __name__ == "__main__":
    main()
