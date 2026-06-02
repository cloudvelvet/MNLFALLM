# LLM-DIF MAPS 연구 현재 브리핑

## 연구 프레이밍

본 연구는 LLM을 DIF 검정기나 자동 판정기로 사용하는 연구가 아니다. 핵심은 다문화청소년패널(MAPS) 문항을 대상으로, 경험적 DIF 결과를 보지 않은 LLM이 문항-공변량 단위의 threshold DIF 후보 가설을 생성하고, 그 후보를 후속 심리측정 검증 전에 얼마나 유용하게 우선순위화하는지 평가하는 것이다.

따라서 모든 해석에서 다음 표현을 피한다.

- LLM이 DIF를 탐지했다.
- LLM이 편향 문항을 판정했다.
- LLM이 공정성을 보장한다.
- 경험적 screening 결과를 최종 ground truth로 간주한다.

권장 표현은 다음과 같다.

- blind DIF hypothesis generation
- item-covariate triage
- provisional empirical DIF screening
- psychometric validation before substantive interpretation
- LLM output as hypothesis, not evidence

## 현재 완료된 분석

Gemini 2.5 Flash를 사용한 30개 문항 pilot이 완료되었다. 출력은 모두 JSON으로 파싱되었고, 총 137개 item-covariate prediction이 생성되었다. 이 중 provisional empirical DIF positive는 45개였다. 부모 문항에는 gender 공변량을 적용하지 않는 규칙 때문에 `pilot_006 x gender`는 not applicable/missing으로 처리되었다.

## Pilot 30 핵심 결과

전체 성능:

- 분석 단위: 137 item-covariate pairs
- provisional DIF positives: 45
- LLM average precision: 0.5339
- keyword baseline average precision: 0.4689
- LLM precision@5: 0.60
- keyword precision@5: 0.60
- LLM precision@10: 0.70
- keyword precision@10: 0.70

공변량별 결과:

- `korean_c`: n=30, positives=13, LLM AP=0.691, keyword AP=0.347
- `discrim_any`: n=30, positives=20, LLM AP=0.678, keyword AP=0.737
- `gender`: n=17, positives=5, LLM AP=0.362, keyword AP=0.283
- `age_c`: n=30, positives=6, LLM AP=0.162, keyword AP=0.306
- `income_c`: n=30, positives=1, LLM AP=0.033, keyword AP=0.500, 단 positive가 1개라 해석 제한

해석:

- LLM의 가장 강한 장점은 `korean_c`에서 나타났다. 한국어 능력은 문항 이해, 응답 범주 해석, 한국 사회·문화 맥락과 연결되므로 단순 keyword보다 LLM의 의미 기반 추론이 더 잘 작동한 사례로 볼 수 있다.
- `discrim_any`에서는 keyword baseline이 더 높았다. 차별, 무시, 외국인, 따돌림 같은 표면 단서가 문항에 직접 등장하는 경우가 많아 lexical baseline만으로도 후보를 잘 잡았기 때문이다.
- `age_c`와 `income_c`는 LLM이 취약했다. 특히 age와 income은 실제 잠재특성 차이, 발달 단계, 사회경제적 조건을 DIF처럼 서술하기 쉬운 공변량이다. 이 결과는 LLM guardrail과 rationale coding의 필요성을 보여준다.
- `gender`는 작지만 LLM이 keyword보다 높았다. 다만 표본 수가 17개라 강한 결론은 어렵다.

## API-free robustness 결과

추가 분석은 API 없이 완료되었다.

- valid pairs: 136
- positives: 45
- cluster bootstrap by `custom_id`: 2000 reps
- paired permutation: 5000 reps

전체:

- AP difference, LLM - keyword: 0.065
- bootstrap CI: [-0.069, 0.163]
- permutation two-sided p=.386
- 해석: 전체적으로 LLM이 더 높아 보이나, pilot 30 기준으로는 불확실성이 크다.

`korean_c`:

- AP difference: 0.344
- bootstrap CI: [0.015, 0.490]
- permutation p=.017
- 해석: 가장 설득력 있는 LLM advantage. 논문 결과에서 가장 강조 가능한 부분.

`discrim_any`:

- AP difference: -0.059
- bootstrap CI: [-0.123, 0.098]
- permutation p=.584
- 해석: keyword가 높아 보이나 안정적 우위라고 보기는 어렵다. 표면 단서가 강한 공변량에서는 LLM의 추가 가치가 제한될 수 있다는 방향으로 해석.

`age_c`:

- AP difference: -0.144
- bootstrap CI: [-0.614, 0.044]
- permutation p=.061
- 해석: keyword 우세 경향이 있으나 불확실성이 큼. age는 LLM failure/overgeneralization 사례로 다루기 적합.

`income_c`:

- positive가 1개뿐이라 사실상 정량 해석을 피해야 한다.

Threshold metrics:

- cutoff >=50: TP=30, FP=41, FN=15, TN=50, precision=.423, recall=.667, specificity=.549, F1=.517
- cutoff >=70: TP=20, FP=14, FN=25, TN=77, precision=.588, recall=.444, specificity=.846, F1=.506

해석:

- cutoff 50은 recall 중심 triage에 적합하다.
- cutoff 70은 더 엄격한 후보 목록을 만들 때 적합하다.
- 본 연구 목적이 최종 분류가 아니라 우선순위화라면 AP, P@k, top-k 검토율을 중심 지표로 두는 것이 좋다.

추가 lexical baseline:

- TF-IDF lexical baseline overall AP=0.265
- TF-IDF Korean AP=0.403
- 해석: 단순 lexical similarity 계열 baseline은 전체적으로 약했고, 특히 `korean_c`에서 LLM이 더 강했다.

## 현재 진행 중인 전체 prompt sensitivity

전체 105문항에 대해 prompt sensitivity를 무료 또는 저비용 방식으로 chunk 실행 중이다.

프롬프트 버전:

- `original`
- `strict_dif`
- `response_process`

각 버전은 105 prompts를 갖는다. 부모 문항에는 gender가 자동 제외된다. 현재 `original` 1-35 chunk가 실행 중이며, 무료 quota/rate limit 때문에 429가 발생하고 있다. 503은 일시적 서버 오류였고 재시도 후 성공했다. 429는 quota/rate limit 문제이며 스크립트가 자동 backoff한다.

실행 스크립트:

- `run_maps_llm_gemini_sensitivity.ps1`
- `maps_llm_build_sensitivity_prompts.R`
- `maps_llm_parse_sensitivity_results.R`
- `maps_llm_eval_sensitivity.R`

결과 파일:

- `llm_dif_output/maps_llm_gemini_sensitivity_original_gemini-2.5-flash.jsonl`
- `llm_dif_output/maps_llm_gemini_sensitivity_strict_dif_gemini-2.5-flash.jsonl`
- `llm_dif_output/maps_llm_gemini_sensitivity_response_process_gemini-2.5-flash.jsonl`
- `llm_dif_output/maps_llm_gemini_sensitivity_predictions_flat.csv`
- `llm_dif_output/maps_llm_gemini_sensitivity_eval_metrics.csv`
- `llm_dif_output/maps_llm_gemini_sensitivity_rank_overlap.csv`

## 논문상 핵심 논의 방향

가장 방어 가능한 논지는 다음과 같다.

첫째, LLM은 전체적으로 keyword baseline을 압도하지는 않는다. Pilot 30에서 전체 AP 차이는 LLM 쪽으로 양수였지만 CI가 0을 포함했다. 따라서 “LLM이 더 우수하다”가 아니라 “LLM의 유용성은 공변량과 문항 단서의 성격에 따라 달라진다”가 핵심 결론이다.

둘째, LLM의 장점은 표면 단어보다 response process와 문화·언어 맥락이 중요한 공변량에서 나타났다. `korean_c` 결과가 이를 뒷받침한다. 한국어 능력은 문항 이해, 한국사회 맥락, 응답 범주 사용과 연결되므로 단순 keyword baseline보다 의미 기반 rationale이 유리할 수 있다.

셋째, 표면 단서가 강한 공변량에서는 LLM의 추가 가치가 제한적일 수 있다. `discrim_any`에서 keyword baseline이 강했던 이유는 문항 자체에 차별, 무시, 외국인, 따돌림 같은 단서가 직접 등장하기 때문이다.

넷째, LLM은 impact와 DIF를 혼동할 위험이 있다. `age_c`, `income_c`에서 이러한 위험이 특히 크다. 나이, 소득, 성별은 문항 단서가 약해도 그럴듯한 사회적 설명을 만들기 쉬운 공변량이다. 따라서 LLM rationale은 증거가 아니라 실패 유형까지 포함해 코딩해야 할 분석 대상이다.

다섯째, 본 연구의 기여는 새로운 DIF 검정법이 아니라 검증 앞단의 재현 가능한 가설 생성 workflow다. Prompt 보존, raw response 저장, keyword baseline 비교, empirical screening과의 분리, 후속 MNLFA-style validation이 핵심 guardrail이다.

## 방법론 보완 필요 항목

남은 보완 항목:

- 전체 105문항 prompt sensitivity 완료
- prompt version 간 top-k overlap 및 score correlation
- human expert plausibility rating 설계
- targeted MNLFA validation 대상 선정
- rationale coding 실제 적용
- MAPS 자료 정보 표 정리: 패널, wave, 응답자, 표본 N, 구인, 문항 수, 결측, 가중치
- keyword baseline 사전과 점수 규칙 명시
- empirical ordinal DIF screening의 provisional 성격 명시

## Subagent별 요청

### Agent 1: 결과와 논의

현재 pilot 30 및 robustness 결과를 바탕으로 논문 결과/논의 파트를 한국어 줄글로 구성하라. 과장된 표현을 피하고, LLM의 조건부 유용성, `korean_c`에서의 강점, `discrim_any`에서 keyword baseline의 강점, `age_c`/`income_c`에서의 실패 가능성을 중심으로 정리하라.

### Agent 2: 방법론과 추가 분석

현재 연구를 KCI 또는 짧은 방법론 application 논문으로 방어 가능하게 만들기 위한 추가 분석 설계를 제안하라. 특히 prompt sensitivity, bootstrap/permutation, human plausibility rating, targeted MNLFA validation, rationale coding, 추가 baseline을 우선순위별로 정리하라.

### Agent 3: 심사자 관점 비판

이 연구가 “그냥 application 논문” 또는 “LLM으로 그럴듯한 말 시킨 것”이라는 비판을 받을 때 가장 취약한 지점을 찾아라. 각 취약점에 대해 방어 문장과 실제 보완 분석을 제안하라.
