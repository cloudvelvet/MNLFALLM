from __future__ import annotations

import re
from pathlib import Path

from docx import Document
from docx.enum.text import WD_BREAK
from docx.shared import Pt


IN = Path(r"C:\chen_bauer_2024\docx_work\input.docx")
OUT = Path(r"C:\chen_bauer_2024\docx_work\ssci_reframed.docx")


def set_para_text(paragraph, text: str) -> None:
    """Replace paragraph text while preserving the paragraph style."""
    for run in list(paragraph.runs):
        run.text = ""
    if paragraph.runs:
        paragraph.runs[0].text = text
    else:
        paragraph.add_run(text)


def replace_text_in_container(container, replacements: list[tuple[str, str]]) -> None:
    for p in container.paragraphs:
        text = p.text
        new = text
        for old, repl in replacements:
            new = new.replace(old, repl)
        if new != text:
            set_para_text(p, new)
    for tbl in container.tables:
        for row in tbl.rows:
            for cell in row.cells:
                replace_text_in_container(cell, replacements)


def insert_paragraph_after(paragraph, text: str, style=None):
    new_p = paragraph._p.addnext(paragraph._p.__class__())
    # The line above creates an empty lxml element but not a valid paragraph object.
    # Use the safer helper below instead.


def add_after(paragraph, text: str, style=None):
    from docx.oxml import OxmlElement
    from docx.text.paragraph import Paragraph

    new_p = OxmlElement("w:p")
    paragraph._p.addnext(new_p)
    p = Paragraph(new_p, paragraph._parent)
    if style is not None:
        p.style = style
    p.add_run(text)
    return p


doc = Document(IN)

# Title and subtitle: scope the paper to the actual single-model case.
set_para_text(
    doc.paragraphs[0],
    "Gemini 2.5 Flash는 순서형 DIF 후보를 전문가 어휘 기준보다 효과적으로 우선순위화하는가?",
)
set_para_text(
    doc.paragraphs[1],
    "다문화청소년패널 문항-공변량 조합의 조건부 벤치마크 분석",
)

# Abstracts.
set_para_text(
    doc.paragraphs[4],
    "본 연구는 다문화청소년패널(MAPS) 2기 자료의 청소년 및 보호자 문항을 대상으로, Gemini 2.5 Flash가 순서형 DIF 검토를 위한 문항-공변량 후보를 전문가 어휘 기준보다 효과적으로 우선순위화할 수 있는지 평가하였다. 분석 단위는 문항-공변량 조합이었다. Gemini 2.5 Flash에는 문항 문장, 구인 맥락, 응답 범주, 공변량 정의를 제공하되, 경험적 DIF 선별 결과, p값, 효과크기, 문항 통계량, 어휘 기준 점수는 제공하지 않았다. 비교 기준은 연구자가 사전에 구성한 이분형 전문가 어휘 기준, TF-IDF n-gram 의미 유사도 기준, 그리고 잠정적 순서형 DIF 선별 기준이었다.",
)
set_para_text(
    doc.paragraphs[5],
    "평가는 평균 정밀도(AP)와 상위 후보 정밀도(P@5, P@10)를 함께 사용하였다. 1-5차년도 pooled 주 분석에서 Gemini의 AP는 기본 지시문 .382, 엄격 지시문 .405였고, 이분형 전문가 어휘 기준의 평균 AP는 각각 .375와 .384였다. 그러나 문항 단위 bootstrap 구간은 0을 포함했고, paired permutation test에서도 Gemini의 우위는 통계적으로 뚜렷하지 않았다. 또한 엄격 지시문에서는 AP가 소폭 증가했지만 P@5와 P@10은 낮아졌으며, 6차년도 단일 wave 민감도 분석에서는 전문가 어휘 기준이 Gemini보다 높은 AP를 보였다. 따라서 본 연구의 결과는 잠정적 선별 기준 아래에서 Gemini가 전문가 어휘 기준을 안정적으로 능가했다는 결론을 지지하지 않는다.",
)
set_para_text(
    doc.paragraphs[6],
    "이 결과는 Gemini 2.5 Flash를 DIF 판정 도구로 사용하는 것을 지지하지 않는다. 본 연구의 핵심 결론은 생성형 언어모형의 일반적 우수성이 아니라, 단일 상용 LLM을 DIF 후보 생성에 사용할 때 나타나는 조건과 한계이다. Gemini는 문항-공변량 조합에 대한 구조화된 설명을 생성할 수 있었지만, 그 점수와 상위 후보 목록은 지시문 조건과 잠정적 경험 기준에 민감하였다. 따라서 LLM 산출물은 단독 판단 근거가 아니라, 전문가 어휘 기준, 경험적 선별, 전문가 내용 검토, 후속 심리측정 모형과 함께 사용되는 보조적 가설 자료로 다루어져야 한다.",
)
set_para_text(
    doc.paragraphs[7],
    "주요어: 차별기능문항, Gemini 2.5 Flash, 다문화청소년패널, 전문가 어휘 기준, 지시문 민감도, 심리측정 벤치마크",
)
set_para_text(
    doc.paragraphs[9],
    "This study examined whether Gemini 2.5 Flash can prioritize item-covariate combinations for ordinal differential item functioning (DIF) review better than an expert lexical benchmark. The analysis used youth and caregiver items from the second Multicultural Adolescents Panel Study (MAPS). Gemini 2.5 Flash received item wording, construct context, response categories, and covariate definitions, but no empirical DIF screening results, p values, effect sizes, item statistics, or lexical benchmark scores. Its rankings were compared with a pre-specified binary expert lexical benchmark, a TF-IDF n-gram similarity benchmark, and a provisional ordinal DIF screening criterion.",
)
set_para_text(
    doc.paragraphs[10],
    "Average precision (AP) and top-candidate precision (P@5 and P@10) were treated as complementary prioritization indices. In the pooled Wave 1-5 analysis, Gemini AP was .382 under the original prompt and .405 under the strict prompt, whereas the binary expert lexical benchmark yielded mean AP values of .375 and .384, respectively. However, item-cluster bootstrap intervals included zero, and paired permutation tests did not show a statistically clear advantage for Gemini. Under the strict prompt, AP improved slightly but P@5 and P@10 declined; in the Wave 6 single-wave sensitivity analysis, the lexical benchmark outperformed Gemini in AP.",
)
set_para_text(
    doc.paragraphs[11],
    "The findings do not support using Gemini 2.5 Flash as a DIF decision tool. Conditional on the provisional screening criterion used here, Gemini produced structured and reviewable hypotheses but did not show a stable advantage over the expert lexical benchmark. The results instead identify boundary conditions for LLM-assisted DIF candidate generation: prompt sensitivity, divergence between global AP and top-k utility, dependence on covariate type, and the need to treat rationale audit as exploratory failure-mode evidence rather than validated qualitative interpretation.",
)

# Global wording corrections.
replacements = [
    ("생성형 대규모 언어모형", "Gemini 2.5 Flash"),
    ("대규모 언어모형(LLM)", "Gemini 2.5 Flash"),
    ("대규모 언어모형", "Gemini 2.5 Flash"),
    ("투명한 어휘 기반 비교 기준", "전문가 어휘 기준"),
    ("투명한 키워드 기준", "전문가 어휘 기준"),
    ("단순 이분형 키워드 기준", "이분형 전문가 어휘 기준"),
    ("이분형 키워드 기준", "이분형 전문가 어휘 기준"),
    ("키워드 비교 기준", "전문가 어휘 기준"),
    ("키워드 기준", "전문가 어휘 기준"),
    ("키워드 점수", "어휘 기준 점수"),
    ("키워드 사전", "어휘 사전"),
    ("키워드 포함", "어휘 포함"),
    ("LLM-키워드", "LLM-전문가 어휘"),
    ("LLM과 키워드", "LLM과 전문가 어휘 기준"),
    ("focal triangulation", "illustrative focal probe"),
    ("Focal 후보 사례", "Illustrative focal 후보 사례"),
    ("focal random-intercept probe", "illustrative random-intercept probe"),
    ("참조 준거(reference standard)", "잠정적 평가 기준(provisional criterion)"),
]
replace_text_in_container(doc, replacements)

# Section-specific replacements by heading/prefix.
for p in doc.paragraphs:
    t = p.text.strip()
    if t == "2.3 전문가 어휘 기준":
        continue
    if t == "2.3 키워드 비교 기준":
        set_para_text(p, "2.3 전문가 어휘 기준")
    elif t.startswith("LLM 산출물이 문항의 표면 어휘를 넘어"):
        set_para_text(
            p,
            "Gemini 산출물이 문항의 표면 어휘를 넘어 추가적인 정보를 제공하는지 확인하기 위해 이분형 전문가 어휘 기준을 구성하였다. 이 기준은 무작위 또는 naive baseline이 아니라, DIF 내용 검토에서 연구자가 실제로 사용할 법한 어휘 단서를 사전에 명시한 hand-crafted lexical benchmark이다. 문항 텍스트에 공변량 관련 핵심어가 하나 이상 포함되는지를 기준으로 점수화하였고, LLM 출력, 경험적 선별 결과, 응답 분포, 문항 통계량은 사용하지 않았다. 따라서 이 기준은 단순하지만 약한 기준은 아니다. 차별 경험이나 한국어 능력처럼 표면 단서가 강한 공변량에서는 오히려 매우 경쟁적인 비교 기준으로 작동할 수 있다.",
        )
    elif t.startswith("연구질문 2:"):
        set_para_text(
            p,
            "연구질문 2: Gemini가 산출한 DIF 가능성 점수는 이분형 전문가 어휘 기준보다 잠정적 경험 DIF 후보를 더 효율적으로 우선순위화하는가?",
        )
    elif t.startswith("연구질문 4:"):
        set_para_text(
            p,
            "연구질문 4: 실제 차이(impact)와 문항 기능 차이(DIF)의 구분을 명시적으로 제약한 엄격한 지시문(strict prompt)은 기본 지시문(base prompt)에 비해 Gemini의 우선순위화 성능과 상위 후보 목록의 안정성을 개선하는가? 판단 근거 분석은 타당성 검증이 아니라, 지시문 조건에 따라 설명에서 나타나는 보조적 failure-mode 신호가 어떻게 달라지는지 살펴보는 탐색적 audit로 제한한다.",
        )
    elif t.startswith("본 연구에서는 우선순위화 성능을 평가하기 위해 AP"):
        set_para_text(
            p,
            "본 연구에서는 우선순위화 성능을 평가하기 위해 평균 정밀도(Average Precision; AP)와 상위 후보 정밀도(P@5, P@10)를 함께 사용하였다. AP는 전체 순위에서 잠정적 경험 DIF 후보가 얼마나 앞쪽에 배치되는지를 요약한다. 반면 P@5와 P@10은 연구자가 실제로 먼저 검토할 가능성이 높은 최상위 후보 목록의 유용성을 보여준다. 두 지표는 서로 다른 질문에 답한다. AP가 높아도 최상위 후보의 정밀도가 낮을 수 있고, 반대로 전체 순위가 완벽하지 않아도 상위 후보 목록은 실무적으로 유용할 수 있다. 따라서 본 연구는 AP와 P@k를 상호 보완적인 주요 지표로 해석하였다.",
        )
    elif t.startswith("본 연구는 다문화청소년패널(MAPS) 2기 자료를 대상으로, 생성형"):
        set_para_text(
            p,
            "본 연구는 다문화청소년패널(MAPS) 2기 자료를 대상으로, Gemini 2.5 Flash가 경험적 DIF 스크리닝 결과를 제공받지 않은 상태에서 문항-공변량 조합의 순서형 DIF 후보를 얼마나 효과적으로 우선순위화할 수 있는지 평가하였다. 이하에서는 잠정적 선별 기준 아래에서 나타난 결과를 연구질문별로 정리하고, 그 해석 범위를 명확히 제한한다.",
        )
    elif t.startswith("첫째, 전체 분석 결과"):
        set_para_text(
            p,
            "첫째, 전체 분석 결과 Gemini가 제안한 검토 후보의 평균 정밀도(AP)는 기본 지시문 조건에서 .382, 엄격 지시문 조건에서 .405로 산출되어 이분형 전문가 어휘 기준(.376 및 .384)을 소폭 상회하였다. 그러나 이 차이는 안정적인 우위로 해석하기 어렵다. 문항 단위 bootstrap 신뢰구간은 0을 포함했고, paired permutation test에서도 통계적으로 뚜렷한 차이가 확인되지 않았다. 따라서 본 연구의 결과는 Gemini가 전문가 어휘 기준을 일관되게 능가했다는 결론보다, 잠정적 경험 기준 아래에서 두 기준의 차이가 작고 불확실하다는 결론을 지지한다.",
        )
    elif t.startswith("특히 6차년도 단일 wave"):
        set_para_text(
            p,
            "특히 6차년도 단일 wave 민감도 분석에서는 전문가 어휘 기준의 AP가 Gemini를 상회하였다. 이는 1-5차년도 pooled 자료에서 관찰된 소폭의 AP 우위가 단일 시점 자료에서 재현되지 않았음을 의미한다. 다만 6차년도 결과 역시 잠정적 선별 기준에 의존하므로, 이를 Gemini의 실패로 단정하기보다 후보 우선순위화 결과가 자료 구성과 criterion 정의에 민감하다는 증거로 해석하는 것이 적절하다.",
        )
    elif t.startswith("둘째, 지시문 조건에 따른 상위 후보군"):
        set_para_text(
            p,
            "둘째, 지시문 조건에 따른 상위 후보군(top-k)의 민감도는 Gemini 기반 DIF 후보 생성의 중요한 경계조건으로 확인되었다. 기본 지시문과 엄격 지시문 조건 간 Spearman 순위상관은 .571이었고, top-5와 top-10의 중복 비율은 모두 0이었다. 엄격 지시문에서 전체 AP가 소폭 개선되었음에도 P@5와 P@10이 낮아진 결과는, 지시문 강화가 전체 순위의 일부 신호를 조정할 수는 있지만 실제 검토 대상이 되는 최상위 목록을 안정화하지는 못했음을 보여준다. 따라서 prompt engineering만으로 신뢰할 만한 후보 목록을 얻는다는 주장은 본 자료에서 지지되지 않는다.",
        )
    elif t.startswith("셋째, LLM의 추론 성능"):
        set_para_text(
            p,
            "셋째, 성능은 공변량의 특성과 응답자 유형에 따라 달랐다. 차별 경험과 같이 문항 내용이 공변량의 의미와 직접 맞닿아 있는 경우 엄격 지시문 조건에서 Gemini AP가 전문가 어휘 기준을 상회하였다. 반면 한국어 능력이나 연령처럼 문항 내 표면 어휘와 공변량의 일치가 빈번한 경우에는 전문가 어휘 기준이 더 강하게 작동하였다. 응답자 유형별로는 청소년 문항보다 보호자 문항에서 Gemini의 AP 이점이 크게 나타났지만, 이 결과 역시 잠정적 선별 기준과 문항 pool 구성에 의존한다. 특히 가구소득은 양성 후보 수가 매우 적어 공변량별 AP를 안정적인 성능 추정치로 해석하기 어렵다.",
        )
    elif t.startswith("넷째, 판단 근거에 대한 질적 검토"):
        set_para_text(
            p,
            "넷째, 판단 근거 분석은 본문 핵심 타당성 검증이 아니라 보조적 failure-mode audit로 해석되어야 한다. 엄격한 DIF 구분 지시문은 Gemini가 '동일한 잠재특성 수준' 조건이나 응답 과정 관련 표현을 더 자주 사용하도록 만들었다. 그러나 이러한 형식적 개선이 상위 후보 정밀도 개선으로 이어지지는 않았다. 또한 성별·연령에 관한 일반적 설명이나 실제 잠재특성 차이(impact)를 문항 기능 차이(DIF)처럼 서술하는 위험 신호가 여전히 관찰되었다. 따라서 본 연구의 판단 근거 분석은 설명의 타당성을 입증하는 결과가 아니라, LLM 설명을 사용할 때 확인해야 할 오류 유형을 탐색적으로 요약한 결과로 보아야 한다.",
        )
    elif t.startswith("본 연구의 학술적 기여는"):
        set_para_text(
            p,
            "본 연구의 학술적 기여는 Gemini의 성능을 단순 예측률로 제시하는 데 있지 않다. 본 연구는 경험적 DIF label을 학습하거나 관찰하지 않은 조건에서, 단일 상용 LLM이 전문가 어휘 기준과 TF-IDF 의미 유사도 기준을 상대로 어떤 추가 가치를 갖는지 조건부로 평가하였다. 이 설계는 LLM을 DIF 판정자가 아니라 후보 가설 생성 장치로 배치하고, 그 산출물이 잠정적 경험 기준, 상위 후보 유용성, 지시문 민감도라는 서로 다른 기준에서 어떻게 달라지는지 보여준다는 점에서 의의가 있다.",
        )
    elif t.startswith("실무적 관점에서"):
        set_para_text(
            p,
            "실무적 관점에서 본 연구의 결과는 Gemini를 단독적인 DIF 탐색 도구로 사용하는 것을 지지하지 않는다. 보다 방어 가능한 활용 방식은 다단계 절차이다. 먼저 전문가 어휘 기준으로 표면 단서가 분명한 조합을 확인하고, 그 다음 Gemini 산출물을 어휘 단서가 약하지만 의미적 관련성이 의심되는 조합을 설명적으로 정리하는 보조 자료로 사용한다. 마지막으로 high-risk 후보는 순서형 DIF 모형, IRT 기반 절차, MNLFA 등 별도의 심리측정 모형과 전문가 내용 검토를 통해 확인해야 한다.",
        )
    elif t.startswith("끝으로, 판단 근거 코딩은"):
        set_para_text(
            p,
            "끝으로, 판단 근거 audit는 자동 규칙 기반으로 수행되었으며 독립적인 수동 코딩을 대체하지 않는다. 따라서 본 연구는 rationale의 질적 타당성을 확정적으로 주장하지 않는다. 자동 audit는 Gemini 설명에서 나타나는 위험 신호의 분포를 탐색적으로 요약하기 위한 절차이며, 후속 연구에서는 전문가 맹검 코딩이나 인지면담 자료와의 대조를 통해 설명의 실제 검토 가능성을 평가할 필요가 있다.",
        )

# Add response-process bridge after the paragraph that discusses LLM risks.
for idx, p in enumerate(doc.paragraphs):
    if p.text.strip().startswith("물론 LLM의 추론 결과를 심리측정 분야에 적용할 때는"):
        add_after(
            p,
            "이 점은 응답 과정 타당도(response process validity)의 관점에서도 중요하다. DIF 후보 설명이 설득력을 가지려면 문항 표현, 응답 범주 사용, 문화·언어적 맥락이 실제 응답 과정에서 어떻게 작동할 수 있는지를 구분해야 한다. 그러나 LLM은 응답자의 실제 사고 과정, 인지면담 자료, 문항 개발 기록을 관찰하지 않는다. LLM이 제공하는 것은 응답 과정에 대한 직접 증거가 아니라 문항과 공변량의 의미적 관련성에 관한 구조화된 추정이다. 따라서 본 연구는 LLM 설명을 타당도 증거로 취급하지 않고, 후속 검토가 필요한 후보 설명으로 제한하여 평가한다.",
            style=p.style,
        )
        break

# Ensure references include works cited in the manuscript and response-process bridge.
ref_texts = [p.text for p in doc.paragraphs]
refs_to_add = [
    "Camilli, G., & Shepard, L. A. (1994). *Methods for identifying biased test items*. Sage.",
    "Clauser, B. E., & Mazor, K. M. (1998). Using statistical procedures to identify differentially functioning test items. *Educational Measurement: Issues and Practice, 17*(1), 31-44.",
    "Kane, M. T. (2013). Validating the interpretations and uses of test scores. *Journal of Educational Measurement, 50*(1), 1-73.",
    "Messick, S. (1995). Validity of psychological assessment: Validation of inferences from persons' responses and performances as scientific inquiry into score meaning. *American Psychologist, 50*(9), 741-749.",
    "Swaminathan, H., & Rogers, H. J. (1990). Detecting differential item functioning using logistic regression procedures. *Journal of Educational Measurement, 27*(4), 361-370.",
    "Zumbo, B. D. (1999). *A handbook on the theory and methods of differential item functioning: Logistic regression modeling as a unitary framework for binary and Likert-type item scores*. Directorate of Human Resources Research and Evaluation, Department of National Defense.",
]
if any(p.text.strip() == "References" for p in doc.paragraphs):
    # Add only missing references before the first Korean reference or at the end.
    existing = "\n".join(ref_texts)
    insert_at = None
    for i, p in enumerate(doc.paragraphs):
        if p.text.strip().startswith("신동훈"):
            insert_at = i
            break
    if insert_at is None:
        insert_at = len(doc.paragraphs)
    anchor = doc.paragraphs[insert_at - 1]
    for ref in refs_to_add:
        key = ref.split(".")[0]
        if key not in existing:
            anchor = add_after(anchor, ref, style=doc.paragraphs[insert_at - 1].style)

# Add concise appendices if not already present.
if not any(p.text.strip().startswith("부록 A") for p in doc.paragraphs):
    last = doc.paragraphs[-1]
    p = add_after(last, "부록 A. LLM 지시문 요약", style=doc.styles["Heading 1"])
    p.runs[0].add_break(WD_BREAK.PAGE)
    add_after(
        p,
        "기본 지시문은 문항 문장, 구인 설명, 응답 범주, 공변량 정의를 함께 제시한 뒤, 해당 문항-공변량 조합에서 순서형 DIF 후보 가능성, 예상 방향, 확신도, 판단 근거를 JSON 형식으로 산출하도록 요구하였다. 엄격한 DIF 구분 지시문은 여기에 실제 잠재특성 차이(impact)와 같은 잠재특성 수준에서의 문항 기능 차이(DIF)를 구분하라는 조건을 추가하였다. 특히 단순한 집단 평균 차이, 일반적 위험요인, 사회적 배경 차이를 DIF의 근거로 사용하지 말고, 문항 표현이나 응답 과정이 응답 범주 사용의 차이로 이어질 수 있을 때만 높은 점수를 부여하도록 지시하였다.",
        style=doc.styles["Normal"],
    )
    h = add_after(p, "부록 B. JSON 출력 schema", style=doc.styles["Heading 1"])
    add_after(
        h,
        "LLM 출력은 다음 필드를 포함하도록 제한하였다: custom_id, model, scale_id, item_id, covariate, threshold_dif_probability_0_100, expected_direction, confidence_0_100, rationale, parse_status. Probability와 confidence는 0-100 범위의 정수로 기록하였고, expected_direction은 positive, negative, unclear 중 하나로 제한하였다. Parsing 실패, 누락 필드, 범위 밖 점수는 별도로 표시하고 분석에서 제외하거나 보정 규칙에 따라 처리하였다.",
        style=doc.styles["Normal"],
    )

# Light style consistency.
for p in doc.paragraphs:
    if p.style.name == "Normal":
        for run in p.runs:
            run.font.size = Pt(10.5)

doc.save(OUT)
print(OUT)
