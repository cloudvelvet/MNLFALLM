from docx import Document
from docx.oxml.ns import qn
from docx.shared import Pt, RGBColor


SRC = r"N:\개인\다음논문\LLM_DIF_full_manuscript_draft_psychometric_style_정리본_rationale낮춤_최종.docx"
OUT = r"N:\개인\다음논문\LLM_DIF_full_manuscript_draft_psychometric_style_정리본_주요리뷰반영.docx"


TITLE = "Gemini 2.5 Flash는 순서형 DIF 후보를 전문가 어휘 기준보다 효과적으로 우선순위화하는가?"
SUBTITLE = "다문화청소년패널 문항-공변량 조합의 조건부 벤치마크 분석"


def set_text(p, text, size=10.5, bold=False, color=(0, 0, 0)):
    p.clear()
    r = p.add_run(text)
    r.font.name = "맑은 고딕"
    r._element.rPr.rFonts.set(qn("w:eastAsia"), "맑은 고딕")
    r.font.size = Pt(size)
    r.bold = bold
    r.font.color.rgb = RGBColor(*color)


def style_runs(p):
    txt = p.text.strip()
    for r in p.runs:
        r.font.name = "맑은 고딕"
        r._element.rPr.rFonts.set(qn("w:eastAsia"), "맑은 고딕")
        if txt == TITLE:
            r.font.size = Pt(15)
            r.bold = True
            r.font.color.rgb = RGBColor(31, 55, 99)
        elif txt == SUBTITLE:
            r.font.size = Pt(10.5)
            r.bold = False
            r.font.color.rgb = RGBColor(89, 89, 89)
        elif txt in {"국문초록", "English Abstract", "1. 서론", "2. 연구방법", "3. 결과", "4. 논의", "References"}:
            r.font.size = Pt(13)
            r.bold = True
            r.font.color.rgb = RGBColor(31, 55, 99)
        elif txt.startswith(tuple(f"{i}." for i in range(1, 7))):
            r.font.size = Pt(11)
            r.bold = True
            r.font.color.rgb = RGBColor(31, 55, 99)
        elif txt.startswith("표 ") or txt.startswith("주."):
            r.font.size = Pt(9.2)
            r.bold = txt.startswith("표 ")
            r.font.color.rgb = RGBColor(68, 68, 68)
        else:
            r.font.size = Pt(10.5)
            r.bold = False
            r.font.color.rgb = RGBColor(0, 0, 0)


def replace_terms(text):
    text = text.replace("이분형 키워드 기준", "전문가 어휘 기준")
    text = text.replace("키워드 비교 기준", "전문가 어휘 기준")
    text = text.replace("키워드 기준", "전문가 어휘 기준")
    text = text.replace("투명한 어휘 기준", "전문가가 구성한 명시적 어휘 기준")
    text = text.replace("transparent lexical benchmark", "domain-expert lexical benchmark")
    text = text.replace("binary keyword benchmark", "domain-expert lexical benchmark")
    text = text.replace("keyword benchmark", "expert lexical benchmark")
    text = text.replace("lexical benchmark", "expert lexical benchmark")
    text = text.replace("경계조건", "조건부 벤치마크 결과")
    text = text.replace("boundary conditions", "conditional benchmark evidence")
    return text


def main():
    doc = Document(SRC)

    set_text(doc.paragraphs[0], TITLE, size=15, bold=True, color=(31, 55, 99))
    set_text(doc.paragraphs[1], SUBTITLE, size=10.5, color=(89, 89, 89))

    replacements = {
        4: "본 연구는 다문화청소년패널(MAPS) 2기 자료의 청소년 및 보호자 문항을 대상으로, Gemini 2.5 Flash가 순서형 DIF 검토를 위한 문항-공변량 후보를 전문가 어휘 기준보다 효과적으로 우선순위화할 수 있는지 평가하였다. 분석 단위는 문항-공변량 조합이었다. Gemini 2.5 Flash에는 문항 문장, 구인 맥락, 응답 범주, 공변량 정의를 제공하되, 경험적 DIF 선별 결과, p값, 효과크기, 문항 통계량은 제공하지 않았다. LLM 산출물은 기본 지시문과 엄격한 DIF 구분 지시문 조건에서 생성되었고, 전문가 어휘 기준, TF-IDF n-gram cosine similarity 기준, 잠정적 순서형 DIF 선별 결과와 비교하였다.",
        5: "주 분석에서 Gemini 2.5 Flash의 AP는 기본 지시문 .382, 엄격 지시문 .405였으며, 전문가 어휘 기준의 평균 AP는 각각 .375와 .384였다. 그러나 문항 단위 bootstrap 구간은 0을 포함했고, paired permutation test에서도 LLM의 우위는 통계적으로 뚜렷하지 않았다. 6차년도 단일 wave 민감도 분석에서는 오히려 전문가 어휘 기준이 LLM보다 높은 AP를 보였다. 또한 두 지시문 조건의 상위 후보 목록은 크게 달랐으며, top-5와 top-10 overlap은 모두 0이었다. P@5와 P@10도 지시문 조건에 따라 상반된 양상을 보였으므로, AP와 top-k 지표를 함께 해석해야 한다.",
        6: "이 결과는 Gemini 2.5 Flash를 DIF 판정 도구로 사용하는 것을 지지하지 않는다. 또한 모든 성능 평가는 잠정적 순서형 DIF 선별 기준에 조건화된 결과이므로, LLM 산출물과 선별 기준의 불일치를 LLM 실패로만 해석할 수는 없다. 본 연구의 핵심 결론은 Gemini 2.5 Flash가 전문가가 구성한 명시적 어휘 기준을 안정적으로 넘어서는 독립적 검토 신호를 제공하지 못했고, 상위 후보 목록이 지시문 조건에 크게 민감했다는 것이다. 따라서 LLM 산출물은 단독 판단 근거가 아니라, 전문가 어휘 기준, 경험적 screening, 불확실성 평가, 후속 심리측정 검증과 함께 제한적으로 사용해야 할 후보 가설 자료로 해석되어야 한다.",
        7: "주요어: 차별기능문항, Gemini 2.5 Flash, 다문화청소년패널, 전문가 어휘 기준, 지시문 민감도, 조건부 벤치마크",
        9: "This study evaluated whether Gemini 2.5 Flash can prioritize item-covariate combinations for ordinal differential item functioning (DIF) review more effectively than a domain-expert lexical benchmark. The analysis used youth and caregiver items from the second cohort of the Multicultural Adolescents Panel Study (MAPS). Gemini 2.5 Flash received item text, construct context, response categories, and covariate definitions, but not empirical DIF screening results, p-values, effect sizes, or item statistics. Outputs were generated under an original prompt and a stricter DIF-guardrail prompt, then compared with a domain-expert lexical benchmark, a TF-IDF n-gram cosine-similarity benchmark, and provisional ordinal DIF screening labels.",
        10: "In the pooled Wave 1-5 analysis, Gemini 2.5 Flash average precision (AP) was .382 under the original prompt and .405 under the strict prompt, whereas the domain-expert lexical benchmark yielded mean AP values of .375 and .384, respectively. These apparent advantages were not statistically stable: item-cluster bootstrap intervals included zero, and paired permutation tests did not indicate reliable differences. In the Wave 6 single-wave sensitivity analysis, the expert lexical benchmark outperformed the LLM. The top-ranked LLM candidate lists were also highly prompt-sensitive, with zero overlap in the top 5 and top 10 candidates across prompt conditions. These findings should be interpreted jointly with P@5 and P@10, which showed different practical implications across prompt conditions.",
        11: "The findings do not support using Gemini 2.5 Flash as a DIF decision tool. All performance claims are conditional on the provisional ordinal DIF screening criterion, whose false-positive and false-negative rates are unknown. The study therefore cannot determine whether LLM-criterion disagreement reflects LLM failure, criterion noise, or both. Its contribution is more limited and more precise: under the present MAPS item-covariate task, Gemini 2.5 Flash did not provide a statistically reliable ranking signal beyond a domain-expert lexical benchmark, and its top-ranked candidate lists were prompt-sensitive.",
        12: "Keywords: differential item functioning, Gemini 2.5 Flash, multicultural adolescents, expert lexical benchmark, prompt sensitivity, conditional benchmarking",
    }
    for idx, text in replacements.items():
        set_text(doc.paragraphs[idx], text)

    for p in doc.paragraphs:
        txt = p.text.strip()

        if txt.startswith("최근 Transformer 기반 언어모형"):
            set_text(
                p,
                "최근 Transformer 기반 언어모형을 심리측정 문항 설계 및 검토에 접목하려는 연구가 시작되었다. 예컨대 자동 문항 생성 및 문항 품질 자동 검토(Attali et al., 2022; Hommel et al., 2022)나, AI 생성 문항의 공정성 검토(Belzak et al., 2023) 등이 논의되었다. 또한 LLM을 주석 및 분류 과제에 활용하려는 연구는 모델 산출물이 인간 판단을 일부 보조할 수 있음을 보여주지만, 동시에 검증 없는 자동 주석의 위험도 지적한다(Gilardi et al., 2023; Pangakis et al., 2023). DIF와 보다 직접적으로 관련하여 Maeda와 Lu(2025)는 인코더 기반 Transformer를 활용해 문항 텍스트로부터 경험적 DIF 여부를 직접 예측하고 설명 가능한 인공지능 기법으로 기여 단어를 탐색하였다. 그러나 기존 연구들은 주로 경험적 DIF 레이블이 사전에 존재하는 상태에서 이를 예측하는 지도학습 모델링에 가까웠다. 반면 본 연구는 경험적 통계 결과를 보지 않은 Gemini 2.5 Flash가 문항-공변량 의미 추론만으로 후보 가설을 사전에 도출하고 우선순위화할 수 있는지를 평가한다는 점에서 차별성을 가진다.",
            )

        elif txt.startswith("물론 LLM의 추론 결과"):
            set_text(
                p,
                "물론 LLM의 추론 결과를 심리측정 분야에 적용할 때는 엄격한 제한 조건이 필요하다. DIF 후보 우선순위화는 단순한 의미 유사도 과제가 아니다. 이 과제는 문항 표현과 공변량의 의미적 관련성, 응답자가 문항을 이해하고 응답 범주를 사용하는 과정, 그리고 실제 잠재특성 차이(impact)와 문항 기능 차이(DIF)의 구분을 함께 요구한다. 이러한 요구는 응답 과정 타당도와 DIF content review의 문제와 맞닿아 있다(Messick, 1995; Zumbo, 1999). LLM은 자연스러운 설명을 생성할 수 있지만, 잠재특성의 실제 집단 차이를 문항 기능의 왜곡처럼 서술하거나, 성별·연령에 대한 일반론적인 사회적 고정관념을 그럴듯한 DIF 기제로 둔갑시킬 위험이 있다. 또한 폐쇄형 LLM의 경우 훈련 데이터에 심리측정학 문헌이 포함되어 있어 유사 맥락의 연구 흐름을 학습했을 가능성도 배제하기 어렵다.",
            )

        elif txt.startswith("본 연구는 MAPS 청소년 및 보호자 응답 문항을 대상으로, 순서형 로지스틱"):
            set_text(
                p,
                "본 연구는 MAPS 청소년 및 보호자 응답 문항을 대상으로, 순서형 로지스틱 회귀에 기반한 잠정적 DIF 선별 결과를 비교 기준으로 삼아 Gemini 2.5 Flash의 우선순위화 성능을 평가한다. 이 선별 결과는 최종 DIF 판정이나 참값이 아니라, LLM 산출물과 전문가 어휘 기준이 경험적 선별 신호와 어느 정도 정렬되는지 평가하기 위한 provisional criterion이다. 따라서 본 연구의 모든 성능 해석은 이 잠정적 기준의 한계에 조건화된다. 구체적인 연구 질문은 다음과 같다.",
            )

        elif txt.startswith("연구질문 2:"):
            set_text(p, "연구질문 2: Gemini 2.5 Flash가 산출한 DIF 가능성 점수는 전문가 어휘 기준보다 잠정적 경험 DIF 후보를 더 효율적으로 우선순위화하는가?")
        elif txt.startswith("연구질문 4:"):
            set_text(p, "연구질문 4: 실제 차이(impact)와 문항 기능 차이(DIF)의 구분을 명시적으로 제약한 엄격한 지시문(strict prompt)은 기본 지시문(base prompt)에 비해 Gemini 2.5 Flash의 우선순위화 성능과 상위 후보 목록의 안정성을 개선하는가? 판단 근거 분석은 이 질문에 대한 타당성 검증이 아니라, 지시문 조건에 따라 LLM 설명에서 나타나는 보조적 failure-mode 신호가 어떻게 달라지는지 기술하기 위한 부가 분석으로 다룬다.")
        elif txt == "2.3 키워드 비교 기준":
            set_text(p, "2.3 전문가 어휘 기준")
        elif txt.startswith("LLM 산출물이 문항의 표면 어휘"):
            set_text(
                p,
                "LLM 산출물이 문항의 표면 어휘를 넘어 추가적인 정보를 제공하는지 확인하기 위해 전문가 어휘 기준을 구성하였다. 이 기준은 문항 텍스트에 공변량 관련 핵심어가 하나 이상 포함되는지를 기준으로 점수화하였다. LLM 출력, 경험적 선별 결과, 응답 분포, 문항 통계량은 사용하지 않았다. 다만 이 기준은 무작위 또는 비전문가 기준이 아니다. 공변량 선택과 키워드 목록은 연구자의 측정 및 MAPS 문항 맥락에 대한 사전 지식을 반영한다. 따라서 본 연구의 비교는 Gemini 2.5 Flash와 단순한 naive baseline의 비교가 아니라, LLM의 암묵적 의미 추론과 연구자가 명시적으로 구성한 전문가 어휘 규칙의 비교로 해석한다.",
            )
        elif txt.startswith("차별 경험에는"):
            set_text(
                p,
                "차별 경험에는 다른 대우, 편견, 무시, 위축, 사회적 지위, 따돌, 못살게, 외국, 욕, 놀림, 소문을 포함하였다. 한국어 능력에는 한국어, 한국문화, 한국 사람, 한국사람, 한국에, 한국의, 모국, 외국, 문화, 언어를 포함하였다. 가구소득, 성별, 연령에 대해서도 각각 경제적 조건, 또래 관계와 외모, 발달 단계와 진로에 관련된 핵심어를 지정하였다. 키워드 목록은 LLM 결과와 경험적 선별 결과를 보지 않은 상태에서 구성하였다.",
            )
        elif txt.startswith("점수화는 의도적으로 단순하게 하였다."):
            set_text(
                p,
                "점수화는 의도적으로 단순하게 하였다. 각 문항-공변량 조합에 대해 해당 공변량의 키워드가 하나 이상 발견되면 100점, 발견되지 않으면 0점을 부여하였다. 문자열 탐색은 고정 문자열 일치 방식으로 수행하였고, 형태소 분석, 동의어 확장, 문항 빈도 가중은 사용하지 않았다. 이 기준은 전문가 지식이 명시적으로 들어간 강한 어휘 기준이므로, LLM이 이를 안정적으로 능가하지 못했다는 결과는 LLM의 약점만이 아니라 명시적 전문가 규칙의 실용적 강점을 보여주는 결과로 해석한다.",
            )
        elif txt == "표 4. 공변량별 키워드 비교 기준 규칙":
            set_text(p, "표 4. 공변량별 전문가 어휘 기준 규칙")
        elif txt.startswith("주요 평가지표는 average precision"):
            set_text(
                p,
                "주요 평가지표는 average precision(AP), precision@5(P@5), precision@10(P@10)이다. AP는 선별 양성 조합이 전체 점수 순위의 상위에 얼마나 집중되는지를 평가하는 precision-recall 기반 지표이며(Davis & Goadrich, 2006), P@5와 P@10은 실제 전문가 검토에서 먼저 확인할 최상위 후보 목록의 유용성을 보여준다. 따라서 본 연구는 AP와 top-k 정밀도를 함께 주요 지표로 해석한다. AP는 전체 순위의 평균적 정렬을 보여주는 반면, P@k는 제한된 검토 자원을 어디에 배분할지에 더 직접적으로 연결된다. 두 지표가 서로 다른 방향을 보이는 경우에는 LLM 후보 목록의 실무적 안정성이 낮은 것으로 해석하였다.",
            )
        elif txt.startswith("또한 기본 지시문과 엄격한 DIF"):
            set_text(
                p,
                "또한 기본 지시문과 엄격한 DIF 구분 지시문의 산출물이 얼마나 안정적인지 확인하기 위해 Spearman 순위상관과 상위 후보 overlap을 계산하였다. LLM 점수와 전문가 어휘 기준에는 동점이 존재할 수 있으므로 top-k overlap은 고정 정렬 규칙에 따른 기술적 지표로 해석하였다. 전문가 어휘 기준은 동점이 많이 발생하므로, 결과표에서는 AP와 P@k를 무작위 동점 해소를 2,000회 반복한 평균으로 제시하였다.",
            )
        elif txt.startswith("또한 단순 어휘 기준과 LLM 사이"):
            set_text(
                p,
                "또한 전문가 어휘 기준과 LLM 사이에 또 다른 비교 기준을 두기 위해 API를 사용하지 않는 의미 유사도 기준을 구성하였다. TF-IDF n-gram cosine similarity는 정확한 어휘 일치보다 넓은 표면 단어 분포를 포착하되, 사전 학습된 언어모형을 필요로 하지 않는 투명한 비전문가 기준으로 포함하였다. 본 분석에서는 문항 텍스트와 공변량 정의를 대상으로 단어 및 문자 n-gram 기반 TF-IDF 벡터를 구성하고 cosine similarity를 산출하였다. 이 기준은 dense embedding이나 생성형 추론을 사용하지 않으므로, Gemini 2.5 Flash와 전문가 어휘 기준 사이에 위치한 중간 수준의 의미 유사도 benchmark로 해석한다.",
            )
        elif txt.startswith("표 5는 주 분석"):
            set_text(
                p,
                "표 5는 주 분석에서 Gemini 2.5 Flash 점수와 전문가 어휘 기준의 우선순위화 성능을 비교한 결과이다. 기본 지시문 조건에서 분석 가능한 조합은 486개였고, 이 중 잠정적 경험 DIF 후보는 128개였다. 엄격 지시문 조건에서는 482개 조합 중 127개가 잠정적 경험 DIF 후보로 분류되었다. 양성 비율은 두 조건 모두 약 .263이었다.",
            )
        elif txt.startswith("기본 지시문 조건에서 LLM의 AP"):
            set_text(
                p,
                "기본 지시문 조건에서 Gemini 2.5 Flash의 AP는 .382였고, 전문가 어휘 기준의 평균 AP는 .376이었다. 엄격 지시문 조건에서는 Gemini 2.5 Flash의 AP가 .405, 전문가 어휘 기준의 평균 AP가 .384였다. 즉 전체 AP만 보면 Gemini 2.5 Flash는 전문가 어휘 기준을 소폭 상회하였다. 그러나 이 차이는 작고, 3.10절의 bootstrap 및 permutation test에서 통계적으로 안정적인 차이로 확인되지 않았다.",
            )
        elif txt.startswith("기본 지시문에서 LLM의 P@5"):
            set_text(
                p,
                "P@k 결과는 AP보다 더 분절적인 양상을 보였다. 기본 지시문에서 Gemini 2.5 Flash의 P@5와 P@10은 모두 .600으로 전문가 어휘 기준보다 높았다. 반면 엄격 지시문에서는 AP가 높아졌지만 P@5는 .400, P@10은 .300으로 낮아져 전문가 어휘 기준보다 낮았다. 이는 평균적 순위 성능과 실제 상위 검토 목록의 유용성이 항상 같은 방향으로 움직이지 않음을 보여준다. 따라서 본 연구의 실무적 해석에서는 AP와 P@k를 함께 고려해야 한다.",
            )
        elif txt.startswith("공변량별 결과는"):
            set_text(
                p,
                "공변량별 결과는 Gemini 2.5 Flash의 성능이 공변량의 성격에 따라 달라짐을 보여준다(표 6). 차별 경험에서는 기본 지시문에서 Gemini 2.5 Flash AP(.612)가 전문가 어휘 기준(.620)과 거의 같았고, 엄격 지시문에서는 Gemini 2.5 Flash AP(.681)가 전문가 어휘 기준(.620)을 넘어섰다. 이는 차별 경험처럼 문항 내용과 공변량의 의미가 직접 맞물리는 경우, 엄격한 DIF 구분 지시문이 일부 도움이 될 수 있음을 시사한다.",
            )
        elif txt.startswith("성별에서는 기본 지시문"):
            set_text(
                p,
                "성별에서는 기본 지시문 LLM이 전문가 어휘 기준보다 약간 높았으나, 엄격 지시문에서는 그 차이가 사라졌다. 가구소득은 잠정적 경험 후보가 세 개뿐이어서 AP가 매우 불안정하므로 강한 해석을 피해야 한다. 따라서 가구소득 결과는 공변량별 성능의 주된 근거가 아니라 탐색적 참고값으로만 다룬다.",
            )
        elif txt.startswith("LLM의 우선순위화 성능도 제한적이었다."):
            set_text(
                p,
                "Gemini 2.5 Flash의 우선순위화 성능은 조건부로만 해석되어야 한다. 1-5차년도 pooled 분석에서는 AP가 전문가 어휘 기준을 소폭 상회했지만, 문항 단위 bootstrap 구간은 0을 포함했고 permutation test에서도 차이가 뚜렷하지 않았다. 6차년도 단일 wave 분석에서는 전문가 어휘 기준이 Gemini 2.5 Flash보다 높은 AP를 보였다. 따라서 본 연구는 Gemini 2.5 Flash가 전문가 어휘 기준보다 우수하다는 결론을 지지하지 않는다. 동시에 이 결과는 잠정적 순서형 DIF 선별 기준에 조건화된 것이므로, LLM과 선별 기준의 불일치를 LLM 실패로만 해석할 수도 없다. 더 적절한 해석은, 본 자료와 본 선별 기준 아래에서 Gemini 2.5 Flash의 추가 신호가 전문가 어휘 기준을 안정적으로 넘어서는 수준으로 확인되지 않았다는 것이다.",
            )
        elif txt.startswith("사분면 분석은 실무적 사용 조건"):
            set_text(
                p,
                "사분면 분석은 실무적 사용 조건을 더 분명하게 보여준다. Gemini 2.5 Flash와 전문가 어휘 기준이 모두 높은 both-high 영역은 경험적 양성률이 가장 높았고, both-low 영역은 가장 낮았다. 반면 LLM-high/keyword-low 영역은 both-high만큼 강한 후보군을 만들지 못했다. keyword-high/LLM-low 영역에서도 양성 사례가 적지 않았다. 따라서 LLM 점수만으로 전문가 어휘 후보를 배제하거나, LLM 단독 고득점 후보를 우선 검토 대상으로 삼는 전략은 조심해야 한다. 보다 방어 가능한 절차는 전문가 어휘 기준으로 명시적 1차 후보를 만들고, LLM을 이용해 그 후보의 설명 가능성과 우선순위를 보조적으로 검토하는 방식이다.",
            )
        elif txt.startswith("본 연구의 학술적 기여는"):
            set_text(
                p,
                "본 연구의 학술적 기여는 LLM의 성능을 단순 예측률로 제시하는 데 있지 않다. 본 연구는 Gemini 2.5 Flash의 zero-shot 후보 우선순위화가 전문가 어휘 기준, TF-IDF 유사도 기준, top-k 정밀도, 지시문 민감도, 불확실성 평가와 함께 평가될 때 어떤 한계를 보이는지 경험적으로 제시하였다. 특히 전문가 어휘 기준은 naive baseline이 아니라 도메인 지식이 명시적으로 압축된 operational benchmark이다. 따라서 본 연구의 실무적 결론은 LLM이 아무 가치가 없다는 것이 아니라, 전문가가 구성한 어휘 규칙을 안정적으로 넘어서는 독립적 신호를 제공하려면 더 강한 모델, 더 안정적인 prompt ensemble, 더 엄격한 심리측정 준거가 필요하다는 것이다.",
            )
        elif txt.startswith("첫째, 전체 분석 결과"):
            set_text(
                p,
                "첫째, 전체 분석 결과 Gemini 2.5 Flash가 제안한 검토 후보의 AP는 기본 지시문 조건에서 .382, 엄격 지시문 조건에서 .405로 산출되어 전문가 어휘 기준(.376 및 .384)을 소폭 상회하였으나 통계적으로 안정적인 차이를 보이지 않았다. Bootstrap 신뢰구간이 0을 포함하고 순열 검정에서도 유의한 차이가 관찰되지 않은 결과는, Gemini 2.5 Flash가 전문가 어휘 기준을 일관되게 능가한다고 보기 어렵다는 점을 보여준다.",
            )

        # Generic term cleanup for untouched paragraphs.
        if p.text.strip():
            cleaned = replace_terms(p.text)
            if cleaned != p.text:
                set_text(p, cleaned)
        style_runs(p)

    # Table captions/headers cleanup.
    for p in doc.paragraphs:
        txt = p.text.strip()
        if txt == "표 4. 공변량별 키워드 비교 기준 규칙":
            set_text(p, "표 4. 공변량별 전문가 어휘 기준 규칙")
        elif txt == "표 7. 응답자 유형별 LLM과 키워드 기준의 AP 비교":
            set_text(p, "표 7. 응답자 유형별 Gemini 2.5 Flash와 전문가 어휘 기준의 AP 비교")
        elif txt == "표 16. LLM과 키워드 기준 AP 차이에 대한 bootstrap 및 permutation 결과":
            set_text(p, "표 16. Gemini 2.5 Flash와 전문가 어휘 기준 AP 차이에 대한 bootstrap 및 permutation 결과")
        elif txt == "표 18. LLM 점수와 키워드 기준의 사분면별 경험적 선별 양상":
            set_text(p, "표 18. Gemini 2.5 Flash 점수와 전문가 어휘 기준의 사분면별 경험적 선별 양상")
        style_runs(p)

    # Rename selected table headers.
    header_maps = {
        4: ["지시문 조건", "분석 조합 수", "선별 양성 수", "양성 비율", "Gemini AP", "전문가 어휘 AP", "Gemini P@5", "전문가 어휘 P@5", "Gemini P@10", "전문가 어휘 P@10"],
        5: ["공변량", "지시문 조건", "분석 조합 수", "선별 양성 수", "양성 비율", "Gemini AP", "전문가 어휘 AP"],
        6: ["지시문 조건", "응답자 유형", "분석 조합 수", "선별 양성 수", "양성 비율", "Gemini AP", "전문가 어휘 AP", "AP 차이"],
        15: ["분석", "지시문", "Gemini AP", "전문가 어휘 AP", "AP 차이", "Bootstrap 95% 구간", "Permutation p"],
    }
    for idx, headers in header_maps.items():
        if idx < len(doc.tables):
            row = doc.tables[idx].rows[0]
            for j, h in enumerate(headers):
                if j < len(row.cells):
                    row.cells[j].text = h

    # Add notes for household income and tie-breaking if absent.
    for i, p in enumerate(doc.paragraphs):
        if p.text.strip() == "표 6. 공변량별 AP":
            # Insert after the paragraph following the table is difficult in docx API; add note immediately after caption.
            new = p.insert_paragraph_before("")
            # keep no-op; notes are better in prose already.
        style_runs(p)

    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for para in cell.paragraphs:
                    for r in para.runs:
                        r.font.name = "맑은 고딕"
                        r._element.rPr.rFonts.set(qn("w:eastAsia"), "맑은 고딕")
                        r.font.size = Pt(8.2)

    doc.save(OUT)
    print(OUT)


if __name__ == "__main__":
    main()
