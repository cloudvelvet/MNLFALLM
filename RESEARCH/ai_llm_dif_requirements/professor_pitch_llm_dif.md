# 교수님 면담용: LLM-assisted DIF Hypothesis Generation

## 한 줄 요약

LLM을 DIF의 최종 판정자로 쓰는 것이 아니라, MAPS 다문화 패널 문항에서 DIF 가능성이 있는 item-covariate 조합을 먼저 제안하게 하고, 최종 판단은 MNLFA 또는 ordinal DIF model로 검증하는 workflow를 생각하고 있습니다.

## 30초 버전

교수님, MAPS 다문화 패널 자료에서 LLM을 이용해 DIF 후보를 생성하는 아이디어를 생각해봤습니다.

핵심은 LLM이 DIF를 판정한다는 것이 아니라, 문항 내용과 covariate 맥락을 보고 "어떤 문항이 왜 DIF 후보가 될 수 있는지"를 먼저 제안하게 하는 것입니다. 그다음 실제 DIF 여부는 MNLFA나 ordinal DIF model로 검증하려고 합니다.

즉, LLM은 통계모형을 대체하는 도구가 아니라, 문항 의미 기반 가설 생성 단계에서 연구자 검토를 보완하는 도구입니다. 제가 보고 싶은 것은 LLM이 제안한 후보가 empirical DIF 결과와 어느 정도 맞는지, 그리고 어디서 latent mean difference를 DIF처럼 오해하는지입니다.

## 2-3분 설명 버전

교수님, 제가 구상하는 연구는 MAPS 다문화 패널 자료를 활용해서 LLM-assisted DIF hypothesis generation이 가능한지 보는 것입니다.

DIF를 검토할 때 보통 연구자가 문항 내용을 읽고, 특정 집단이나 covariate에 따라 문항이 다르게 작동할 가능성이 있는지 이론적으로 가설을 세우게 됩니다. 이 과정은 꼭 필요하지만, 문항 수와 covariate 조합이 많아지면 모든 item-covariate 조합을 사람이 균형 있게 검토하기가 쉽지 않다고 생각했습니다.

그래서 LLM을 최종 판정자가 아니라, 문항 의미 기반 후보 생성 도구로만 사용해보려 합니다. 예를 들어 문항 텍스트, 척도 맥락, covariate 정보를 주고, "같은 잠재특성 수준에서도 이 문항의 threshold가 달라질 만한 이유가 있는지"를 평가하게 하는 방식입니다.

그 이후에는 LLM 결과를 그대로 믿지 않고, MNLFA 또는 ordinal DIF model로 검증합니다. 즉, 잠재특성 수준을 통제한 뒤에도 차별경험, 한국어 능력, 소득, 연령 같은 covariate가 문항 threshold나 loading에 영향을 주는지를 확인하는 구조입니다.

예비적으로 Gemini를 이용해 일부 item-covariate pair를 돌려보니, 차별경험처럼 문항 내용과 직접 연결되는 경우에는 높은 DIF 가능성을 주는 경향이 있었습니다. 반면 age 같은 covariate에서는 실제 DIF라기보다 발달 차이나 경험 차이를 DIF처럼 과해석하는 경향도 보였습니다. 그래서 이 연구의 포인트는 "LLM이 DIF를 잘 맞춘다"가 아니라, LLM이 어떤 조건에서 유용한 후보를 만들고 어떤 조건에서 심리측정적으로 위험한 오해를 하는지 평가하는 데 있다고 생각합니다.

가능하다면 전체 item-covariate 조합으로 확장해서, LLM score가 empirical DIF label을 얼마나 예측하는지, keyword baseline보다 나은지, 그리고 covariate별로 성능과 false positive 패턴이 어떻게 다른지 보고 싶습니다.

## 연구질문

1. LLM은 MAPS 다문화 패널 문항에서 의미 기반 DIF 후보를 생성할 수 있는가?
2. LLM이 생성한 후보는 keyword baseline이나 연구자 직관 기반 후보보다 추가적인 정보를 제공하는가?
3. LLM의 판단은 discrimination, Korean proficiency, income, age처럼 covariate 성격에 따라 다르게 작동하는가?
4. LLM은 latent mean difference와 true measurement DIF를 어디서 혼동하는가?
5. LLM-assisted screening과 MNLFA/ordinal DIF model을 결합하면, 다문화 longitudinal measurement invariance 검토 workflow로 쓸 수 있는가?

## 분석 계획

1. MAPS 문항 catalog와 covariate catalog를 정리합니다.
2. 각 item-covariate pair에 대해 LLM이 threshold DIF 가능성, 방향, 이유를 생성하게 합니다.
3. keyword baseline을 만들어 LLM이 단순 단어 매칭을 넘어서는지 비교합니다.
4. proxy-theta ordinal logit screening으로 provisional DIF label을 만듭니다.
5. 주요 척도에 대해서는 MNLFA 또는 ordinal DIF model로 정식 검증합니다.
6. LLM, keyword baseline, empirical DIF 결과를 비교합니다.
7. LLM의 false positive와 false negative를 질적으로 분석합니다.

## 예비결과를 말할 때

현재 예비결과에서는 LLM이 차별경험과 직접 연결되는 문항에서는 높은 DIF 가능성을 제안했습니다. 예를 들어 외국 출신, 편견, 무시, 차별 경험과 직접 관련된 문항에서 높은 점수를 주는 경향이 있었습니다.

하지만 모든 결과가 통계적 DIF와 일치한 것은 아니었습니다. 특히 age와 같은 covariate에서는 실제 문항 기능 차이라기보다 발달적 차이나 경험 차이를 DIF처럼 설명하는 경향이 있었습니다. 이 점은 LLM을 최종 판정자가 아니라 후보 생성 도구로 제한해야 한다는 근거가 됩니다.

따라서 현재 해석은 "LLM이 DIF를 자동 탐지한다"가 아니라, "LLM이 의미 기반 DIF 후보를 생성할 수는 있지만, psychometric validation이 반드시 필요하다"입니다.

## 피해야 할 표현

- LLM이 DIF를 찾아낸다.
- LLM이 편향 문항을 자동 검출한다.
- LLM이 전문가보다 더 잘 찾는다.
- 통계모형 없이도 문항 의미만으로 DIF를 판단할 수 있다.
- 유의한 DIF는 곧 문항 불공정성을 의미한다.
- 유의한 DIF가 없으면 측정불변성이 확보되었다.

## 안전한 표현

- LLM은 DIF 후보 가설을 생성하는 보조 도구입니다.
- 최종 검증은 MNLFA 또는 ordinal DIF model로 수행합니다.
- 목적은 자동 판정이 아니라 전문가 검토의 우선순위를 정하는 것입니다.
- DIF는 측정 비동일성의 신호일 수 있지만, 곧바로 문항 불공정성으로 해석하지는 않습니다.
- LLM의 실패 양상도 중요한 연구 결과입니다.

## 교수님께 여쭤볼 질문

1. 이 아이디어를 방법론 논문으로 가져갈 수 있을지, 아니면 MAPS 실증 논문의 보조 분석으로 두는 것이 좋을지 궁금합니다.
2. gold standard를 proxy-theta ordinal screening으로 둘 수 있을지, 아니면 주요 척도는 반드시 MNLFA로 확인해야 할지 조언을 받고 싶습니다.
3. LLM 비교 기준으로 keyword baseline, naive prompt, psychometric guardrail prompt를 두는 설계가 적절한지 궁금합니다.
4. covariate는 discrimination, Korean proficiency, income, age를 우선 보려고 하는데, 어떤 covariate가 이론적으로 가장 방어 가능한지 의견을 듣고 싶습니다.
5. LLM 결과의 재현성을 위해 모델 버전, temperature, prompt, item text source를 모두 고정하고 기록하려고 하는데, 추가로 필요한 통제 조건이 있을지 여쭤보고 싶습니다.

## 교수님이 물을 수 있는 질문과 답변

### Q1. LLM이 왜 필요한가?

문항 수와 covariate 조합이 많아질 때 사람이 모든 조합을 균형 있게 검토하기 어렵습니다. LLM은 최종 판정자가 아니라, 검토할 후보를 넓게 생성하고 그 이유를 문서화하는 도구로 쓸 수 있습니다. 따라서 효율성뿐 아니라 가설 생성 과정의 재현성과 투명성을 높이는 데 의미가 있습니다.

### Q2. LLM이 그냥 고정관념을 재생산하는 것 아닌가?

그 위험이 있습니다. 그래서 LLM output을 그대로 쓰지 않고, empirical DIF model과 전문가 해석으로 검증합니다. 또한 false positive와 stereotyped rationale 자체를 분석 대상으로 삼아, LLM이 어디서 심리측정적으로 위험한 결론을 내리는지 보고자 합니다.

### Q3. DIF와 집단의 실제 latent trait 차이는 어떻게 구분하나?

프롬프트에서도 "같은 latent trait 수준에서 threshold가 달라지는가"를 명시하고, 통계 분석에서는 theta proxy 또는 latent factor를 통제한 ordinal DIF/MNLFA를 사용하려 합니다. 이 구분을 못하는 LLM 판단은 false positive로 기록합니다.

### Q4. MNLFA를 꼭 써야 하나?

MAPS처럼 covariate가 연속형 또는 time-varying이고, 집단도 단순 이분집단이 아닌 경우 MNLFA가 유연합니다. 다만 첫 screening은 ordinal logit으로 하고, 주요 척도와 핵심 covariate에 대해서 MNLFA로 확인하는 단계적 접근이 현실적일 것 같습니다.

### Q5. 이게 논문 기여가 있나?

기여는 LLM 자체 성능 주장보다, LLM을 심리측정 workflow 안에 제한적으로 배치하는 데 있습니다. 즉, AI-assisted item review를 empirical DIF validation과 결합하고, LLM이 latent difference를 measurement DIF로 오해하는 실패 양상을 체계적으로 보여줄 수 있습니다.

## 최종 한 문장

이 연구는 LLM으로 DIF를 자동 판정하려는 것이 아니라, LLM을 문항 의미 기반 DIF 가설 생성 도구로 제한하고, 그 후보를 MNLFA/ordinal DIF model로 검증함으로써 다문화 패널 자료의 측정불변성 검토를 보완하려는 시도입니다.
