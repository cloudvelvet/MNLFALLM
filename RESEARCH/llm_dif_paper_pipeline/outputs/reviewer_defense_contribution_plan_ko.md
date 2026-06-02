# 심사자 방어 및 기여점 재정의 메모

## 1. 논문의 중심 주장을 어떻게 바꿀 것인가

현재 결과는 "LLM이 keyword baseline보다 우수하다"는 논문으로 쓰기 어렵다. 전체 105문항 분석에서 original prompt의 전체 average precision은 .382였고, strict_dif prompt는 .405로 개선되었지만 keyword baseline의 .441-.445를 넘지 못했다. 따라서 논문의 중심 주장은 성능 우위가 아니라 절차적 기여로 재정의해야 한다.

방어 가능한 핵심 주장은 다음과 같다.

본 연구는 LLM을 DIF 자동 탐지기로 제안하지 않는다. 오히려 LLM이 문항-공변량 조합의 의미적 관련성을 넓게 생성할 수 있지만, 그 관련성이 반드시 같은 잠재특성 수준에서의 문항 기능 차이를 뜻하지는 않음을 보인다. 따라서 LLM-DIF 활용의 핵심은 모델의 단독 성능이 아니라, blind generation, keyword baseline 비교, prompt sensitivity 점검, rationale coding, empirical screening, 후속 validation을 결합한 검증 앞단의 workflow를 구성하는 데 있다.

## 2. 예상 비판별 방어 논리

### 비판 1. "그냥 application 논문 아닌가?"

이 연구는 특정 자료에 LLM을 적용했다는 데서 끝나지 않는다. 연구의 초점은 MAPS 문항 자체가 아니라, 문항-공변량 단위 DIF source investigation에서 LLM 산출물을 어떻게 제한하고 평가해야 하는가에 있다. 즉 자료 적용은 workflow를 시험하기 위한 사례이고, 기여는 LLM을 심리측정 검증 절차 안에서 어떤 위치에 놓아야 하는지 보여주는 데 있다.

논문용 문장:

> 본 연구의 기여는 특정 패널 자료에 LLM을 적용한 사례 보고에 그치지 않는다. 본 연구는 LLM 산출물을 DIF 판정이 아니라 검증 가능한 후보 가설로 제한하고, 그 후보가 단순 lexical baseline 및 provisional empirical screening과 어떻게 정렬되거나 어긋나는지를 평가하는 절차를 제안한다. 이 절차는 DIF source investigation의 해석 부담을 줄이기 위한 사전 triage workflow로 이해될 수 있다.

### 비판 2. "LLM이 keyword보다 못한데 왜 의미 있나?"

바로 그 결과가 중요하다. LLM이 항상 더 낫지 않다는 점은 LLM 도입 연구에서 반드시 보여줘야 하는 guardrail이다. 차별 경험처럼 표면 단서가 강한 공변량에서는 keyword가 강했다. 반대로 strict_dif prompt가 original보다 개선된 점은 LLM 출력이 프롬프트의 심리측정적 제약에 반응한다는 것을 보여준다. 따라서 의미 있는 발견은 "LLM의 일반적 우위"가 아니라 "LLM의 조건부 유용성과 실패 조건"이다.

논문용 문장:

> 전체 분석에서 LLM은 keyword baseline을 일관되게 능가하지 못했다. 그러나 이 결과는 LLM-DIF 접근의 실패라기보다, LLM 산출물을 단순 성능 지표만으로 정당화해서는 안 된다는 점을 보여준다. 표면 어휘 단서가 강한 조합에서는 단순 keyword baseline이 강력한 비교 기준이 되었고, LLM의 추가 가치는 이러한 baseline으로 설명되지 않는 경우에만 주장될 수 있다. 따라서 본 연구는 LLM의 무조건적 우위를 주장하기보다, LLM이 어떤 조건에서 유용하고 어떤 조건에서 불필요하거나 위험한지를 구분하는 데 초점을 둔다.

### 비판 3. "prompt에 민감하면 신뢰할 수 없지 않나?"

맞다. 그래서 prompt sensitivity 자체가 결과다. original과 strict_dif의 Spearman 상관은 약 .571이었지만 top-5와 top-10 후보 overlap은 0이었다. 이는 LLM 후보 목록이 prompt에 민감하다는 강한 증거다. 논문에서는 이를 약점으로 숨기지 말고, LLM-DIF 연구에서 단일 prompt 결과를 안정적 결과로 제시하면 안 된다는 방법론적 시사점으로 써야 한다.

논문용 문장:

> original prompt와 strict_dif prompt 사이의 상위 후보 목록은 크게 달라졌다. 이는 LLM 기반 DIF 후보 생성이 프롬프트 조건에 민감하며, 단일 프롬프트의 산출물을 안정적인 심리측정적 근거로 해석해서는 안 됨을 의미한다. 본 연구에서 prompt sensitivity는 부수적 한계가 아니라 핵심 평가 대상이다. LLM-DIF workflow는 최소한 복수 프롬프트 조건에서의 결과 안정성, baseline 대비 성능, rationale의 심리측정적 타당성을 함께 점검해야 한다.

### 비판 4. "계량심리 기여가 약하다."

새 검정법을 제안하는 논문은 아니다. 대신 계량심리적 기여는 DIF detection 이후의 source investigation과 validation prioritization에 있다. 특히 impact와 DIF의 구분을 LLM rationale 평가의 중심 기준으로 삼는 점이 중요하다. LLM이 일반적 집단 차이를 threshold DIF처럼 말하는지를 분석하는 것은 측정동일성 연구에서 직접적으로 의미가 있다.

논문용 문장:

> 본 연구는 새로운 DIF 검정 통계량을 제안하지 않는다. 그보다 본 연구는 DIF detection과 해석 사이의 간극, 즉 통계적 flag가 생성된 이후 어떤 문항-공변량 조합을 먼저 검토해야 하는지의 문제를 다룬다. 특히 LLM rationale이 impact를 DIF로 오인하는지, 문항 wording 또는 response process에 근거한 threshold mechanism을 제시하는지를 구분함으로써, LLM을 psychometric validation의 전단계에서 어떻게 제한적으로 사용할 수 있는지 검토한다.

## 3. 권장 논문 구성

### 제목

대규모 언어모형을 활용한 다문화청소년패널 문항의 DIF 후보 가설 생성: 프롬프트 민감도와 baseline 비교를 중심으로

### 연구질문

1. LLM은 경험적 DIF 결과를 보지 않은 상태에서 문항-공변량 단위의 threshold DIF 후보 가설을 구조화할 수 있는가.
2. LLM의 우선순위화 성능은 keyword baseline과 비교해 어떤 양상을 보이는가.
3. strict DIF guardrail prompt는 original prompt에 비해 후보 우선순위화와 rationale의 심리측정적 적합성을 개선하는가.
4. LLM은 어떤 조건에서 impact를 DIF로 오인하거나 고정관념적 rationale을 생성하는가.

### 결과 서술 순서

1. 분석 자료와 예측 산출물 수: original 486 pairs, strict_dif 482 pairs.
2. 전체 성능: original .382, strict .405, keyword .441-.445.
3. 공변량별 성능: discrim_any는 keyword 강함, gender는 LLM 약간 우위, age는 strict가 keyword 수준, income은 positive가 적어 해석 제한, korean_c는 pilot과 달리 전체에서는 keyword 강함.
4. prompt sensitivity: top-5/top-10 overlap 0, Spearman .571.
5. qualitative rationale: impact-DIF 혼동, response process 근거, 표면 단서 기반 후보를 구분.

## 4. 논의의 핵심 문단

본 연구의 결과는 LLM이 DIF 후보를 안정적으로 자동 탐지할 수 있음을 보여주지 않는다. 오히려 전체 문항으로 확장했을 때 LLM은 keyword baseline을 일관되게 능가하지 못했고, prompt 조건에 따라 상위 후보 목록도 크게 달라졌다. 그러나 바로 이 점이 LLM-DIF workflow의 방법론적 중요성을 드러낸다. LLM은 문항과 공변량 사이의 의미적 연결을 빠르게 생성하지만, 그 연결이 psychometric DIF인지, 잠재특성의 실제 차이인 impact인지, 혹은 일반적 사회 설명인지 스스로 안정적으로 구분하지 못한다. 따라서 LLM 산출물은 심리측정적 결론이 아니라 후속 검증을 위한 후보 가설로만 사용되어야 한다.

strict_dif prompt가 original prompt보다 전체 AP를 소폭 개선한 점은 LLM 출력이 심리측정적 제약에 반응할 수 있음을 시사한다. 그러나 strict prompt 역시 keyword baseline을 넘지는 못했다. 이는 프롬프트 개선만으로 LLM을 신뢰 가능한 DIF 판정 도구로 만들 수 없음을 보여준다. LLM의 역할은 판정이 아니라 triage이며, 그 triage 역시 keyword baseline, prompt sensitivity, rationale coding, empirical screening과 함께 평가될 때만 의미를 갖는다.

## 5. 한계 문장

본 연구의 한계는 분명하다. 첫째, empirical screening 결과는 최종 truth가 아니라 provisional criterion이다. 둘째, Gemini 2.5 Flash라는 폐쇄형 모델을 사용했기 때문에 모델 버전 변화와 재현성 문제가 남아 있다. 셋째, original과 strict_dif prompt의 비교는 prompt sensitivity를 보여주지만, 가능한 모든 프롬프트 공간을 대표하지는 않는다. 넷째, keyword baseline은 의도적으로 단순하게 설계되었으므로, 향후 연구에서는 embedding similarity, sentence-transformer baseline, human expert rating과의 비교가 필요하다. 다섯째, 본 연구의 LLM 산출물은 후속 MNLFA-style validation 또는 targeted ordinal DIF 분석을 통해 추가 검증되어야 한다.

## 6. 최종 방어 문장

본 연구의 결론은 LLM이 DIF를 더 잘 찾는다는 것이 아니다. 본 연구의 결론은 LLM을 DIF 연구에 사용할 때 무엇을 하면 안 되는지, 그리고 어떤 절차를 거쳐야 제한적으로 쓸 수 있는지를 보여준다는 데 있다. LLM은 문항-공변량 조합의 의미적 후보를 생성할 수 있지만, 그 후보는 keyword baseline보다 항상 우수하지도, prompt 변화에 안정적이지도 않았다. 따라서 LLM-DIF 연구의 핵심은 자동화된 판정이 아니라, 의미 기반 가설 생성과 심리측정 검증 사이의 간극을 드러내고 관리하는 workflow에 있다.
