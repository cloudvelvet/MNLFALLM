from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


OUT = Path("RESEARCH/llm_dif_paper_pipeline/outputs/figures")
OUT.mkdir(parents=True, exist_ok=True)
DATA = Path("llm_dif_output")

plt.rcParams["font.family"] = "Malgun Gothic"
plt.rcParams["axes.unicode_minus"] = False
plt.rcParams["figure.dpi"] = 150


LABELS = {
    "overall": "전체",
    "covariate:discrim_any": "차별 경험",
    "covariate:korean_c": "한국어 능력",
    "covariate:gender": "성별",
    "covariate:age_c": "연령",
    "covariate:income_c": "가구소득",
}

ORDER = [
    "overall",
    "covariate:discrim_any",
    "covariate:korean_c",
    "covariate:gender",
    "covariate:age_c",
    "covariate:income_c",
]


def load_metric(path):
    df = pd.read_csv(path)
    return df[df["group"].isin(ORDER)].copy()


def metric_wide(df):
    rows = []
    for group in ORDER:
        sub = df[df["group"] == group]
        if sub.empty:
            continue
        original = sub[sub["prompt_version"] == "original"].iloc[0]
        strict = sub[sub["prompt_version"] == "strict_dif"].iloc[0]
        rows.append(
            {
                "group": group,
                "label": LABELS[group],
                "original_llm": original["llm_average_precision"],
                "strict_llm": strict["llm_average_precision"],
                "keyword": strict["keyword_average_precision"],
                "positives_original": int(original["positives"]),
                "positives_strict": int(strict["positives"]),
            }
        )
    return pd.DataFrame(rows)


def save_grouped_ap(df, path, title, subtitle=None):
    wide = metric_wide(df)
    x = np.arange(len(wide))
    width = 0.24

    fig, ax = plt.subplots(figsize=(10.8, 5.6))
    colors = ["#4C78A8", "#F58518", "#54A24B"]
    bars1 = ax.bar(x - width, wide["original_llm"], width, label="기본 지시문 LLM", color=colors[0])
    bars2 = ax.bar(x, wide["strict_llm"], width, label="엄격한 DIF 구분 지시문 LLM", color=colors[1])
    bars3 = ax.bar(x + width, wide["keyword"], width, label="키워드 비교 기준", color=colors[2])

    ax.set_ylim(0, max(0.75, float(wide[["original_llm", "strict_llm", "keyword"]].max().max()) + 0.08))
    ax.set_ylabel("Average precision (AP)")
    ax.set_xticks(x)
    ax.set_xticklabels(wide["label"], rotation=0)
    ax.set_title(title, fontsize=14, fontweight="bold", pad=12)
    if subtitle:
        ax.text(0, 1.02, subtitle, transform=ax.transAxes, fontsize=10, color="#444444")
    ax.grid(axis="y", color="#D9D9D9", linewidth=0.8)
    ax.spines[["top", "right"]].set_visible(False)
    ax.legend(frameon=False, ncol=3, loc="upper right")

    for bars in (bars1, bars2, bars3):
        for b in bars:
            val = b.get_height()
            ax.text(
                b.get_x() + b.get_width() / 2,
                val + 0.012,
                f"{val:.3f}".replace("0.", "."),
                ha="center",
                va="bottom",
                fontsize=8,
            )

    fig.tight_layout()
    fig.savefig(path, bbox_inches="tight", dpi=300)
    plt.close(fig)
    return wide


def save_workflow(path):
    fig, ax = plt.subplots(figsize=(13, 4.8))
    ax.axis("off")

    boxes = [
        ("MAPS 문항·공변량", "105개 문항\n문항-공변량 조합"),
        ("LLM 후보 생성", "기본 지시문\n엄격한 DIF 구분 지시문"),
        ("구조화된 출력", "문턱 DIF 가능성\n방향·확신도·판단 근거"),
        ("비교 기준", "키워드 비교 기준\n잠정적 경험 DIF 선별"),
        ("평가", "AP, P@5, P@10\n지시문 민감도"),
        ("해석", "판정이 아니라\n검증할 후보 가설"),
    ]

    x_positions = np.linspace(0.06, 0.94, len(boxes))
    y = 0.56
    w = 0.145
    h = 0.44
    colors = ["#E8F1FA", "#FFF0DC", "#EAF7EA", "#F4ECF7", "#FCEAEA", "#EEF0F2"]

    for i, ((heading, body), x, color) in enumerate(zip(boxes, x_positions, colors)):
        rect = plt.Rectangle((x - w / 2, y - h / 2), w, h, facecolor=color, edgecolor="#333333", linewidth=1.2)
        ax.add_patch(rect)
        ax.text(x, y + 0.095, heading, ha="center", va="center", fontsize=11, fontweight="bold")
        ax.text(x, y - 0.055, body, ha="center", va="center", fontsize=9, linespacing=1.45)
        if i < len(boxes) - 1:
            x2 = x_positions[i + 1]
            ax.annotate(
                "",
                xy=(x2 - w / 2 - 0.012, y),
                xytext=(x + w / 2 + 0.012, y),
                arrowprops=dict(arrowstyle="->", color="#333333", lw=1.4),
            )

    ax.text(
        0.5,
        0.12,
        "LLM 산출물은 DIF 판정 근거가 아니라, 키워드 기준과 경험적 선별 결과에 비추어 검토할 후보 가설로 해석한다.",
        ha="center",
        va="center",
        fontsize=10,
        color="#333333",
    )
    ax.set_title("LLM 기반 DIF 후보 가설 생성 및 평가 절차", fontsize=15, fontweight="bold", pad=14)
    fig.tight_layout()
    fig.savefig(path, bbox_inches="tight", dpi=300)
    plt.close(fig)


def save_prompt_scatter(path):
    joined = pd.read_csv(DATA / "maps_llm_gemini_sensitivity_eval_joined.csv")
    key_cols = ["scale_id", "item_id", "covariate"]
    orig = joined[joined["prompt_version"] == "original"][key_cols + ["threshold_dif_probability_0_100", "dif_label"]]
    strict = joined[joined["prompt_version"] == "strict_dif"][key_cols + ["threshold_dif_probability_0_100"]]
    m = orig.merge(strict, on=key_cols, suffixes=("_original", "_strict"))
    rho = m["threshold_dif_probability_0_100_original"].corr(
        m["threshold_dif_probability_0_100_strict"], method="spearman"
    )

    fig, ax = plt.subplots(figsize=(6.4, 6.2))
    colors = np.where(m["dif_label"].astype(str).str.upper() == "TRUE", "#D95F02", "#4C78A8")
    ax.scatter(
        m["threshold_dif_probability_0_100_original"],
        m["threshold_dif_probability_0_100_strict"],
        c=colors,
        alpha=0.58,
        s=26,
        edgecolors="white",
        linewidths=0.3,
    )
    ax.plot([0, 100], [0, 100], color="#555555", linestyle="--", linewidth=1)
    ax.set_xlim(-3, 103)
    ax.set_ylim(-3, 103)
    ax.set_xlabel("기본 지시문 LLM 점수")
    ax.set_ylabel("엄격한 DIF 구분 지시문 LLM 점수")
    ax.set_title("지시문 조건에 따른 LLM 점수 변화", fontsize=14, fontweight="bold", pad=12)
    ax.text(0.04, 0.94, f"Spearman ρ = {rho:.3f}\n공통 조합 = {len(m)}", transform=ax.transAxes, fontsize=10)
    ax.grid(color="#E1E1E1")
    ax.spines[["top", "right"]].set_visible(False)
    fig.tight_layout()
    fig.savefig(path, bbox_inches="tight", dpi=300)
    plt.close(fig)


def main():
    main_metrics = load_metric(DATA / "maps_llm_gemini_sensitivity_eval_metrics.csv")
    w6_metrics = load_metric(DATA / "maps_llm_gemini_sensitivity_eval_metrics_w6.csv")

    main_wide = save_grouped_ap(
        main_metrics,
        OUT / "figure1_main_ap_by_covariate.png",
        "주 분석: 공변량별 우선순위화 성능",
        "MAPS 2기 1-5차년도 pooled long 자료 기준",
    )
    w6_wide = save_grouped_ap(
        w6_metrics,
        OUT / "figure1b_w6_ap_by_covariate.png",
        "민감도 분석: 6차년도 단일 wave 우선순위화 성능",
        "MAPS 2기 6차년도 단일 wave 자료 기준",
    )
    save_workflow(OUT / "figure2_workflow.png")
    save_prompt_scatter(OUT / "figure3_prompt_sensitivity_scatter.png")

    main_wide.to_csv(OUT / "figure1_main_ap_values.csv", index=False, encoding="utf-8-sig")
    w6_wide.to_csv(OUT / "figure1b_w6_ap_values.csv", index=False, encoding="utf-8-sig")

    for p in sorted(OUT.glob("figure*.png")):
        print(p.resolve())


if __name__ == "__main__":
    main()
