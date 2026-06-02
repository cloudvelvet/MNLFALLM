import csv
from collections import defaultdict
from pathlib import Path


ROOT = Path(r"C:\chen_bauer_2024\MNLFALLM")
OUT = ROOT / "llm_dif_output"


def read_csv(path):
    with open(path, newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


def write_csv(path, rows, fieldnames):
    with open(path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(rows)


def lab(x):
    return 1 if str(x).strip().lower() in {"true", "t", "1", "yes"} else 0


def mean(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else float("nan")


def median(xs):
    xs = sorted(x for x in xs if x is not None)
    if not xs:
        return float("nan")
    mid = len(xs) // 2
    if len(xs) % 2:
        return xs[mid]
    return (xs[mid - 1] + xs[mid]) / 2


def f3(x):
    try:
        return f"{float(x):.3f}"
    except Exception:
        return ""


def quadrant(row):
    llm = float(row["threshold_dif_probability_0_100"])
    kw = lab(row.get("keyword_hit", "")) or float(row.get("keyword_score_0_100", 0)) >= 100
    if llm >= 70 and not kw:
        return "LLM-high / keyword-low"
    if llm <= 30 and kw:
        return "keyword-high / LLM-low"
    if llm >= 70 and kw:
        return "both-high"
    if llm <= 30 and not kw:
        return "both-low"
    return "middle"


def main():
    main_rows = read_csv(OUT / "maps_llm_gemini_sensitivity_eval_joined_binary_keyword.csv")
    cluster_rows = read_csv(OUT / "maps_llm_gemini_sensitivity_eval_joined_cluster_robust_full.csv")
    cluster_map = {
        (r["prompt_version"], r["scale_id"], r["item_id"], r["covariate"]): r
        for r in cluster_rows
    }

    groups = defaultdict(list)
    for r in main_rows:
        if r.get("parse_status", "ok") != "ok":
            continue
        q = quadrant(r)
        if q == "middle":
            continue
        key = (r["prompt_version"], q)
        cr = cluster_map.get((r["prompt_version"], r["scale_id"], r["item_id"], r["covariate"]))
        rec = dict(r)
        if cr:
            rec["dif_label_cluster"] = cr.get("dif_label_cluster", "")
            rec["p_fdr_cluster"] = cr.get("p_fdr_cluster", "")
            rec["beta_cluster"] = cr.get("beta", "")
        else:
            rec["dif_label_cluster"] = ""
            rec["p_fdr_cluster"] = ""
            rec["beta_cluster"] = ""
        groups[key].append(rec)

    out_rows = []
    order = ["LLM-high / keyword-low", "keyword-high / LLM-low", "both-high", "both-low"]
    for prompt in ["original", "strict_dif"]:
        for q in order:
            rows = groups.get((prompt, q), [])
            if not rows:
                continue
            main_pos = sum(lab(r["dif_label"]) for r in rows)
            cluster_pos = sum(lab(r.get("dif_label_cluster", "")) for r in rows)
            betas = [float(r["beta"]) for r in rows if r.get("beta", "") != ""]
            beta_clusters = [float(r["beta_cluster"]) for r in rows if r.get("beta_cluster", "") != ""]
            p_clusters = [float(r["p_fdr_cluster"]) for r in rows if r.get("p_fdr_cluster", "") != ""]
            out_rows.append({
                "prompt_version": prompt,
                "quadrant": q,
                "n": len(rows),
                "main_positive_n": main_pos,
                "main_positive_rate": f3(main_pos / len(rows)),
                "cluster_positive_n": cluster_pos,
                "cluster_positive_rate": f3(cluster_pos / len(rows)),
                "mean_beta_main": f3(mean(betas)),
                "mean_beta_cluster": f3(mean(beta_clusters)),
                "median_p_fdr_cluster": f3(median(p_clusters)),
            })

    out_path = OUT / "maps_llm_quadrant_validation_summary.csv"
    write_csv(out_path, out_rows, list(out_rows[0].keys()))
    print(out_path)
    for r in out_rows:
        print(r)


if __name__ == "__main__":
    main()
