# Agent 3: 심사자 관점 비판 및 방어 전략

## 총평

이 연구의 가장 큰 위험은 LLM을 사용했다는 사실 자체가 새로움으로 과대 포장되는 순간 발생한다. 심사자는 곧바로 “이것은 DIF 방법론 논문이 아니라 MAPS 문항에 LLM을 적용해 본 application 논문 아닌가”, “LLM이 그럴듯한 설명을 만든 것을 empirical screening과 사후적으로 맞춰 본 것 아닌가”, “계량심리학적 기여가 어디에 있는가”라고 물을 수 있다. 현재 pilot 30 결과만 보면 이 비판은 완전히 부당하지 않다. 전체 AP 차이는 LLM 쪽으로 조금 높지만 bootstrap CI가 0을 포함하고, keyword baseline과 precision@5, precision@10이 동일하다. 따라서 논문의 방어선은 “LLM이 keyword보다 전반적으로 우수하다”가 아니라 “LLM의 유용성은 공변량과 문항 의미 구조에 따라 달라지며, 이 차이를 psychometric triage workflow 안에서 검증 가능하게 드러냈다”가 되어야 한다.

## 취약점 1. “그냥 application 논문 아닌가?”

가장 강한 비판은 이 연구가 새로운 DIF 검정법도 아니고, 새로운 추정 모형도 아니며, 특정 자료에 LLM을 적용해 본 사례 연구에 머문다는 것이다. 특히 KCI 수준에서는 application 논문으로 받아들여질 수 있지만, 계량심리 또는 심리측정 방법론 기여를 주장하려면 단순 적용 이상의 구조가 필요하다.

방어 문장:

본 연구의 목적은 새로운 DIF 검정통계량을 제안하는 것이 아니라, 경험적 DIF 검정 이전 단계에서 문항-공변량 조합을 우선순위화하는 재현 가능한 가설 생성 절차를 제안하고 평가하는 데 있다. 따라서 기여는 특정 LLM의 성능 주장에 있지 않고, blind generation, prompt 기록, baseline 비교, provisional empirical screening, rationale coding, 후속 MNLFA-style validation으로 이어지는 psychometric triage workflow의 명세화에 있다.

실제 보완 분석:

- 전체 105문항 prompt sensitivity를 완료하여 pilot 30의 우연성을 줄인다.
- original, strict DIF, response-process prompt 간 AP, precision@k, top-k overlap, score correlation을 비교한다.
- 단일 결과표가 아니라 “어떤 prompt 조건에서 후보 순위가 안정적인가”를 제시한다.
- 결과 해석을 전체 평균 성능보다 공변량별 성능 패턴으로 이동시킨다.
- 논문 제목과 초록에서 “DIF detection”을 피하고 “DIF candidate hypothesis generation” 또는 “item-covariate triage”로 제한한다.

## 취약점 2. “LLM이 그럴듯한 말만 만든 것 아닌가?”

LLM rationale은 설득력 있어 보이지만, 그것이 심리측정 근거가 되는 것은 아니다. 심사자는 LLM이 문항 내용을 실제로 이해했다기보다 차별, 언어, 성별, 연령 같은 단어에서 사회적으로 그럴듯한 이야기를 생성했다고 볼 수 있다. 특히 age와 income에서 LLM이 일반론을 만들 가능성이 크다는 점은 현재 결과에서도 드러난다.

방어 문장:

본 연구는 LLM rationale을 DIF의 증거로 사용하지 않는다. Rationale은 LLM이 어떤 의미 연결을 구성했는지 보여주는 분석 대상이며, 그 타당성은 empirical screening, keyword baseline, 그리고 별도의 rationale coding을 통해 평가된다. 특히 impact를 DIF로 오인하는 rationale과 성별·연령 고정관념에 의존하는 rationale은 성공 사례가 아니라 실패 사례로 코딩된다.

실제 보완 분석:

- rationale coding을 실제로 수행한다.
- 코딩 범주는 최소한 다음을 포함해야 한다: wording 기반, response process 기반, 문화·언어 맥락 기반, impact를 DIF로 오인, 성별·연령 고정관념, 문항 무관 일반론, 방향성 근거 부족.
- 각 범주의 빈도를 prompt version 및 공변량별로 제시한다.
- false positive와 false negative 사례를 5개씩 제시해 LLM의 실패 양상을 투명하게 보여준다.
- strict DIF prompt가 impact 오인 비율을 줄이는지 검증한다.

## 취약점 3. “전체 성능이 별로 강하지 않다”

Pilot 30 기준 전체 AP 차이는 LLM이 keyword보다 높지만 CI가 0을 포함한다. precision@5와 precision@10도 동일하다. 이 상태에서 “LLM이 더 낫다”고 주장하면 심사자가 쉽게 공격할 수 있다.

방어 문장:

Pilot 결과는 LLM의 전반적 우월성을 보여주기보다, LLM의 유용성이 공변량의 의미 구조에 따라 달라진다는 점을 보여준다. 전체 평균에서는 불확실성이 크지만, 한국어 능력 공변량에서는 LLM의 AP advantage가 bootstrap CI와 permutation test에서 비교적 안정적으로 나타났다. 반대로 차별 경험에서는 keyword baseline이 충분히 강했고, 연령과 소득에서는 LLM의 과잉 일반화 위험이 관찰되었다.

실제 보완 분석:

- 전체 평균을 주 결과로 두지 말고 공변량별 결과를 중심에 둔다.
- `korean_c` 결과를 핵심 positive case로 제시한다.
- `discrim_any`는 keyword baseline이 강한 negative/control case로 제시한다.
- `age_c`, `income_c`는 LLM failure/guardrail case로 제시한다.
- bootstrap CI와 permutation test를 전체 105문항으로 다시 계산한다.
- AUROC만 쓰지 말고 AP, AUPRC, precision@k, recall@k, NDCG를 함께 보고한다.

## 취약점 4. “Provisional DIF label을 ground truth처럼 쓰는 것 아닌가?”

경험적 DIF screening은 표본, anchor, 모형, 보정 기준, 효과크기 기준에 따라 달라질 수 있다. 이를 최종 정답처럼 사용하면 연구 전체가 불안정해진다.

방어 문장:

본 연구의 empirical screening 결과는 최종 ground truth가 아니라 provisional criterion이다. 이 기준은 LLM 산출물의 최종 진위 판정이 아니라, 후속 psychometric validation에서 우선 검토할 후보를 얼마나 앞쪽에 배치하는지 평가하기 위한 임시 기준으로 사용된다.

실제 보완 분석:

- 본문 전체에서 ground truth 대신 provisional label, screening criterion, empirical candidate라는 표현을 사용한다.
- empirical screening 방법을 자세히 명시한다: matching variable, ordinal model, threshold DIF 정의, p-value/effect size 기준, multiple testing correction, 결측 처리, 공변량 처리 방식.
- 가능하면 기준을 2개 이상 사용한다: 완화 기준과 엄격 기준.
- 결과가 기준 변화에 얼마나 민감한지 sensitivity analysis를 추가한다.
- 최종 논의에서 “empirical screening 자체도 검증 대상”임을 명시한다.

## 취약점 5. “Keyword baseline이 너무 약하거나 자의적이다”

Keyword baseline이 부실하면 LLM이 이겨도 의미가 없다. 반대로 keyword baseline이 강한 공변량에서는 LLM이 별로 이기지 못한다. 심사자는 baseline 설계가 연구자에게 유리하게 만들어졌는지 의심할 수 있다.

방어 문장:

Keyword baseline은 LLM을 이기기 어려운 강한 모델로 설계된 것이 아니라, 문항 텍스트의 표면 단서만으로 가능한 최소한의 우선순위화를 평가하기 위한 해석 가능한 기준선이다. 따라서 본 연구의 핵심 비교는 LLM이 모든 baseline을 압도하는지가 아니라, 표면 단서가 약하고 response process가 중요한 공변량에서 단순 lexical cue를 넘어서는 추가 정보를 제공하는지에 있다.

실제 보완 분석:

- 키워드 사전을 사전 정의하고 부록에 제시한다.
- 키워드 선택이 empirical DIF 결과를 본 뒤 만들어진 것이 아님을 명시한다.
- TF-IDF lexical baseline, embedding similarity baseline, sentence-transformer baseline을 추가한다.
- 각 baseline이 사용하는 정보량을 구분한다: 문항 텍스트만, 문항+공변량 정의, 문항+구인 설명.
- LLM의 비교 대상을 keyword 하나로 제한하지 말고 “interpretable lexical baseline family”로 확장한다.

## 취약점 6. “심리측정학/계량심리 기여가 약하다”

이 비판이 가장 중요하다. 연구가 LLM 활용 사례로만 보이면 심리학과, 특히 계량심리 전공 논문으로서의 설득력이 약해진다. 따라서 기여를 AI 성능이 아니라 측정 검증 과정의 문제로 재정의해야 한다.

방어 문장:

본 연구의 계량심리학적 기여는 DIF 검정 이후의 해석 부담을 경험적으로 다루는 데 있다. 기존 DIF 절차는 문항 기능 차이를 탐지할 수 있지만, 다수의 문항-공변량 조합에서 어떤 조합을 먼저 내용 검토와 validation 대상으로 삼을지에 대한 절차는 상대적으로 덜 명세화되어 있다. 본 연구는 LLM을 검정자가 아니라 가설 생성 도구로 제한하고, 그 산출물을 baseline 및 empirical screening과 분리하여 평가함으로써 DIF source investigation의 재현 가능한 전처리 단계를 제안한다.

실제 보완 분석:

- 논문 서론과 논의에서 “DIF source investigation”을 중심 개념으로 세운다.
- LLM 결과를 measurement invariance, response process validity, item bias review와 연결한다.
- Targeted MNLFA validation을 최소한 일부 후보에 적용한다.
- LLM high-score 후보 중 empirical positive/negative 사례를 골라 MNLFA에서 threshold effect가 유지되는지 확인한다.
- 반대로 keyword high-score 후보와 LLM-only 후보를 비교해 어떤 후보가 더 psychometric validation으로 이어지는지 확인한다.
- 최종 기여를 “LLM 활용”이 아니라 “문항-공변량 단위 DIF 가설 생성과 검증 우선순위화 절차”로 쓴다.

## 취약점 7. “MAPS와 다문화 청소년 맥락이 약하다”

현재 심리측정 배경은 강하지만, 왜 MAPS이고 왜 한국어 능력, 차별 경험, 소득, 성별, 연령인지가 약하면 연구는 데이터가 우연히 붙은 느낌이 된다.

방어 문장:

MAPS는 다문화 청소년과 보호자의 발달, 문화적응, 가족·사회적 경험을 장기간 추적하는 자료이므로, 문항 의미가 언어 능력, 차별 경험, 사회경제적 조건, 발달 단계와 맞물릴 가능성이 큰 연구 맥락을 제공한다. 따라서 본 연구에서 공변량은 단순 통제변수가 아니라 response process와 item functioning을 동시에 흔들 수 있는 조건으로 다루어진다.

실제 보완 분석:

- MAPS 패널, wave, 응답자, 표본 N, 구인, 문항 수, 응답 범주, 결측, 가중치를 표로 제시한다.
- 각 공변량이 왜 DIF 후보 공변량인지 1문단씩 근거를 붙인다.
- 특히 한국어 능력은 문항 이해와 응답 범주 사용, 차별 경험은 item content salience, 소득은 impact와 DIF 혼동 위험, 성별·연령은 stereotype rationale 위험으로 위치づけ한다.

## 취약점 8. “Prompt에 따라 결과가 흔들리면 연구가 불안정하다”

LLM 결과가 prompt wording에 민감하면 재현성이 낮다는 비판을 받을 수 있다. 현재 전체 prompt sensitivity가 진행 중이므로, 이것은 위험이면서 동시에 좋은 보완 포인트다.

방어 문장:

Prompt sensitivity는 본 연구의 약점을 숨기기 위한 부가 분석이 아니라, 폐쇄형 LLM을 심리측정 workflow에 사용할 때 반드시 확인해야 할 재현성 조건이다. 본 연구는 prompt별 결과 차이를 실패로만 보지 않고, 어떤 instruction이 impact-DIF 구분을 개선하거나 악화시키는지 평가한다.

실제 보완 분석:

- prompt별 AP, P@k, 공변량별 AP를 비교한다.
- prompt 간 top-10 overlap과 Spearman rank correlation을 제시한다.
- strict DIF prompt가 age/income false positive를 줄이는지 본다.
- response-process prompt가 korean_c 후보를 더 안정적으로 올리는지 본다.
- prompt 간 공통으로 상위권에 드는 후보를 “stable candidate”로 정의한다.

## 취약점 9. “사람 전문가 평가가 없다”

LLM rationale이 그럴듯한지 여부는 empirical DIF label만으로 평가하기 어렵다. 경험적 screening이 provisional이라면, 인간 전문가의 plausibility rating이 논문 방어력을 크게 높인다.

방어 문장:

Empirical screening은 후보의 통계적 관련성을 제공하지만, rationale의 내용 타당성을 직접 평가하지는 않는다. 따라서 본 연구는 LLM rationale을 별도의 expert plausibility rating 대상으로 삼아, psychometric evidence와 content-based judgment를 분리한다.

실제 보완 분석:

- 심리측정 또는 다문화 청소년 연구 경험이 있는 2명 이상에게 상위 후보와 실패 후보를 blind rating하게 한다.
- 평정 문항: DIF mechanism plausibility, impact-DIF distinction, item-content relevance, stereotype risk, validation priority.
- Cohen's kappa 또는 ICC를 보고한다.
- 전문가 평정과 LLM score, empirical screening label의 관계를 제시한다.

## 최종 방어 전략

이 논문은 “LLM이 DIF를 잘 찾는다”로 쓰면 약하다. “LLM이 언제 DIF 후보 생성에 도움이 되고, 언제 impact와 stereotype을 DIF처럼 말하는지 계량심리 workflow 안에서 검증했다”로 쓰면 기여가 생긴다. 즉, 좋은 결과만 보여주는 논문이 아니라 LLM을 심리측정 연구에 들여올 때 필요한 guardrail을 실증적으로 보여주는 논문으로 포지셔닝해야 한다.

가장 강한 논문 문장은 다음과 같다.

본 연구는 LLM을 DIF 판정자가 아니라 문항-공변량 단위의 blind hypothesis generator로 제한하고, 그 산출물을 keyword baseline, provisional empirical screening, prompt sensitivity, rationale coding, targeted validation과 분리하여 평가한다. 이 접근은 LLM의 전반적 우월성을 주장하기보다, 의미 기반 후보 생성이 response process와 문화·언어 맥락이 중요한 공변량에서 유용할 수 있으며, 연령·소득처럼 일반론이 쉽게 개입되는 공변량에서는 impact-DIF 혼동과 고정관념적 rationale을 낳을 수 있음을 보여준다. 따라서 본 연구의 기여는 자동 DIF 탐지가 아니라, DIF source investigation 앞단에서 재현 가능한 triage와 실패 진단 절차를 제안한다는 데 있다.

