import csv
import math
import random
from collections import defaultdict
from pathlib import Path


ROOT = Path(r"C:\chen_bauer_2024\MNLFALLM")
OUT = ROOT / "llm_dif_output"
SEED = 20260531


def read_rows(path):
    with open(path, newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


def write_rows(path, rows, fieldnames):
    with open(path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(rows)


def as_label(value):
    text = str(value).strip().lower()
    if text in {"true", "t", "1", "yes"}:
        return 1
    if text in {"false", "f", "0", "no", ""}:
        return 0
    return int(float(value))


def average_precision(labels, scores):
    positives = sum(labels)
    if positives == 0:
        return float("nan")
    order = sorted(range(len(labels)), key=lambda i: scores[i], reverse=True)
    hits = 0
    total = 0.0
    for rank, i in enumerate(order, start=1):
        if labels[i]:
            hits += 1
            total += hits / rank
    return total / positives


def precision_at_k(labels, scores, k):
    if not labels:
        return float("nan")
    order = sorted(range(len(labels)), key=lambda i: scores[i], reverse=True)
    top = order[: min(k, len(order))]
    return sum(labels[i] for i in top) / len(top)


def tie_random_metric(labels, scores, metric, reps=100, seed=SEED):
    """Average a ranking metric over random permutations within tied score groups."""
    rnd = random.Random(seed)
    groups = defaultdict(list)
    for i, score in enumerate(scores):
        groups[score].append(i)
    keys = sorted(groups, reverse=True)
    vals = []
    for _ in range(reps):
        order = []
        for key in keys:
            group = list(groups[key])
            rnd.shuffle(group)
            order.extend(group)
        ordered_labels = [labels[i] for i in order]
        descending = list(range(len(order), 0, -1))
        if metric == "ap":
            vals.append(average_precision(ordered_labels, descending))
        elif metric == "p5":
            vals.append(sum(ordered_labels[:5]) / min(5, len(ordered_labels)))
        elif metric == "p10":
            vals.append(sum(ordered_labels[:10]) / min(10, len(ordered_labels)))
        else:
            raise ValueError(metric)
    return sum(vals) / len(vals)


def quantile(vals, q):
    vals = sorted(v for v in vals if not math.isnan(v))
    if not vals:
        return float("nan")
    pos = (len(vals) - 1) * q
    lo = math.floor(pos)
    hi = math.ceil(pos)
    if lo == hi:
        return vals[lo]
    return vals[lo] + (vals[hi] - vals[lo]) * (pos - lo)


def row_vectors(rows, label_col="dif_label"):
    kw_col = "keyword_score_0_100" if "keyword_score_0_100" in rows[0] else "keyword_binary_score"
    labels = [as_label(r[label_col]) for r in rows]
    llm = [float(r["threshold_dif_probability_0_100"]) for r in rows]
    kw = [float(r[kw_col]) for r in rows]
    return labels, llm, kw


def metrics(rows, tie_reps=200):
    labels, llm, kw = row_vectors(rows)
    return {
        "n": len(rows),
        "positive_n": sum(labels),
        "positive_rate": sum(labels) / len(labels),
        "llm_ap": average_precision(labels, llm),
        "keyword_ap": tie_random_metric(labels, kw, "ap", reps=tie_reps),
        "delta_ap": average_precision(labels, llm) - tie_random_metric(labels, kw, "ap", reps=tie_reps),
        "llm_p5": precision_at_k(labels, llm, 5),
        "keyword_p5": tie_random_metric(labels, kw, "p5", reps=tie_reps),
        "llm_p10": precision_at_k(labels, llm, 10),
        "keyword_p10": tie_random_metric(labels, kw, "p10", reps=tie_reps),
    }


def cluster_bootstrap(rows, n_boot=500, tie_reps=20, seed=SEED):
    rnd = random.Random(seed)
    item_ids = sorted({r["item_id"] for r in rows})
    by_item = defaultdict(list)
    for r in rows:
        by_item[r["item_id"]].append(r)

    deltas = []
    llm_aps = []
    kw_aps = []
    for b in range(n_boot):
        sampled = [rnd.choice(item_ids) for _ in item_ids]
        boot = []
        for item in sampled:
            boot.extend(by_item[item])
        labels, llm, kw = row_vectors(boot)
        llm_ap = average_precision(labels, llm)
        kw_ap = tie_random_metric(labels, kw, "ap", reps=tie_reps, seed=seed + b)
        llm_aps.append(llm_ap)
        kw_aps.append(kw_ap)
        deltas.append(llm_ap - kw_ap)
    return {
        "llm_ap_ci_low": quantile(llm_aps, .025),
        "llm_ap_ci_high": quantile(llm_aps, .975),
        "keyword_ap_ci_low": quantile(kw_aps, .025),
        "keyword_ap_ci_high": quantile(kw_aps, .975),
        "delta_ci_low": quantile(deltas, .025),
        "delta_ci_high": quantile(deltas, .975),
    }


def paired_permutation(rows, n_perm=1000, tie_reps=10, seed=SEED):
    rnd = random.Random(seed)
    labels, llm, kw = row_vectors(rows)
    obs_llm = average_precision(labels, llm)
    obs_kw = tie_random_metric(labels, kw, "ap", reps=200, seed=seed)
    obs_delta = obs_llm - obs_kw
    perm_deltas = []
    for p in range(n_perm):
        pll = []
        pkw = []
        for a, b in zip(llm, kw):
            if rnd.random() < .5:
                pll.append(a)
                pkw.append(b)
            else:
                pll.append(b)
                pkw.append(a)
        pll_ap = average_precision(labels, pll)
        pkw_ap = tie_random_metric(labels, pkw, "ap", reps=tie_reps, seed=seed + p)
        perm_deltas.append(pll_ap - pkw_ap)
    more_extreme = sum(abs(x) >= abs(obs_delta) for x in perm_deltas)
    greater = sum(x >= obs_delta for x in perm_deltas)
    return {
        "observed_delta": obs_delta,
        "perm_p_two_sided": (more_extreme + 1) / (n_perm + 1),
        "perm_p_greater": (greater + 1) / (n_perm + 1),
        "perm_delta_mean": sum(perm_deltas) / len(perm_deltas),
        "perm_delta_low": quantile(perm_deltas, .025),
        "perm_delta_high": quantile(perm_deltas, .975),
    }


def analyze_file(path, analysis_name):
    rows = [r for r in read_rows(path) if r.get("parse_status", "ok") == "ok"]
    out = []
    for prompt in ["original", "strict_dif"]:
        sub = [r for r in rows if r["prompt_version"] == prompt]
        if not sub:
            continue
        obs = metrics(sub, tie_reps=200)
        boot = cluster_bootstrap(sub)
        perm = paired_permutation(sub)
        rec = {
            "analysis": analysis_name,
            "prompt_version": prompt,
            **{k: f"{v:.6f}" if isinstance(v, float) else v for k, v in obs.items()},
            **{k: f"{v:.6f}" if isinstance(v, float) else v for k, v in boot.items()},
            **{k: f"{v:.6f}" if isinstance(v, float) else v for k, v in perm.items()},
            "bootstrap_unit": "item_id",
            "bootstrap_reps": 500,
            "permutation_reps": 1000,
            "keyword_tie_handling": "random tie-breaking average",
        }
        out.append(rec)
    return out


def main():
    all_rows = []
    all_rows.extend(analyze_file(OUT / "maps_llm_gemini_sensitivity_eval_joined_binary_keyword.csv", "pooled_w1_w5"))
    all_rows.extend(analyze_file(OUT / "maps_llm_gemini_sensitivity_eval_joined_binary_keyword_w6.csv", "wave6"))
    out_path = OUT / "maps_llm_uncertainty_bootstrap_permutation.csv"
    fieldnames = list(all_rows[0].keys())
    write_rows(out_path, all_rows, fieldnames)
    print(out_path)
    for row in all_rows:
        print(row["analysis"], row["prompt_version"], "delta", row["delta_ap"], "CI", row["delta_ci_low"], row["delta_ci_high"], "p2", row["perm_p_two_sided"])


if __name__ == "__main__":
    main()
