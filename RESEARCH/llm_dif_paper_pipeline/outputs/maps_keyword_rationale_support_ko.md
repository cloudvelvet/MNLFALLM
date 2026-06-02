# MAPS 공변량 근거, keyword baseline 정의, LLM rationale 코딩표

작성 목적: 서론과 방법 섹션에서 부족한 세 부분을 보강한다. 첫째, 왜 MAPS의 한국어 능력, 차별 경험, 가구소득, 성별, 연령이 문항-공변량 DIF 가설 생성에 적합한지 정리한다. 둘째, 현재 repo에 구현된 keyword baseline을 재현 가능한 방법 문장으로 정의한다. 셋째, LLM rationale의 실패 유형을 코딩할 수 있는 표를 제안한다.

## 1. MAPS와 공변량 선택의 근거

MAPS는 다문화 청소년과 보호자를 반복 관찰하는 패널 자료이며, 청소년의 발달, 가족 및 학교 맥락, 문화적응, 언어, 차별 경험, 심리사회적 적응을 함께 다룬다. 따라서 본 연구의 공변량은 단순한 배경 통제변수가 아니다. 이들은 잠재특성의 실제 차이와 관련될 수 있으면서, 동시에 문항을 이해하고 해석하고 응답 범주를 사용하는 조건이 될 수 있다. 이 이중적 지위 때문에 impact와 DIF의 구분이 필요하다.

### 한국어 능력

한국어 능력은 MAPS 문항 응답 과정과 직접 연결될 수 있는 공변량이다. 청소년 조사는 한국어로 수행되며, 한국어 능력은 다문화 청소년의 학교생활, 또래 관계, 자아존중감, 문화적응과 반복적으로 연결되어 왔다. 특히 한국어 능력이 낮은 응답자는 같은 잠재특성 수준에서도 문항 wording, 사회적 상황을 묘사하는 표현, 응답 범주의 미묘한 차이를 다르게 처리할 가능성이 있다. 이 때문에 한국어 능력은 단순한 outcome predictor가 아니라 response process와 연결되는 DIF 후보 공변량으로 볼 수 있다.

서론 삽입 문장 후보:

> 한국어 능력은 다문화 청소년의 적응과 관련된 실질적 조건이면서, 동시에 한국어 문항을 읽고 응답 범주를 해석하는 과정에 직접 관여할 수 있다. 따라서 한국어 능력에 따른 차이는 잠재특성의 실제 차이일 수도 있고, 같은 잠재특성 수준에서 문항 이해와 응답 기준이 달라진 결과일 수도 있다.

### 차별 경험

차별 경험은 문화적응 스트레스, 자아존중감, 우울, 또래 관계와 강하게 연결되는 핵심 경험이다. 동시에 차별, 무시, 따돌림, 외국인 취급 같은 표현이 문항에 직접 포함된 경우에는 공변량과 문항 내용이 과도하게 겹칠 수 있다. 이 경우 차별 경험은 keyword baseline이 잘 잡는 표면 단서의 대표 사례가 된다. 반대로 차별 경험이 문항에 명시되지 않아도 응답 과정에서 사회적 위협, 소속감, 인정 경험을 다르게 읽게 만들 수 있다.

서론 삽입 문장 후보:

> 차별 경험은 다문화 청소년의 심리사회적 적응과 밀접하게 관련되지만, 일부 문항에서는 문항 내용 자체와 직접 겹친다. 이 경우 통계적 차이는 실제 경험의 차이인지, 같은 잠재특성 수준에서도 특정 wording이 다른 응답 기준을 유발한 결과인지 따로 검토해야 한다.

### 가구소득

가구소득은 다문화 청소년과 가족의 교육 자원, 거주 환경, 건강 접근성, 부모 지원, 진로 기대와 관련될 수 있다. 다만 소득은 문항 wording에 직접 드러나는 경우가 상대적으로 적다. 따라서 가구소득은 두 가지 역할을 한다. 하나는 실제 잠재특성 차이와 관련될 수 있는 사회경제적 조건이다. 다른 하나는 LLM이 직접 문항 단서 없이 넓은 사회경제적 설명을 만들어내는지 확인하는 실패 위험 공변량이다.

서론 삽입 문장 후보:

> 가구소득은 가족 자원과 생활 조건을 반영하므로 여러 구인의 실제 수준과 관련될 수 있다. 그러나 문항 기능 차이를 주장하려면 소득이 문항 이해, 응답 기준, 선택지 사용에 영향을 줄 수 있는 구체적 wording 또는 응답 과정상의 이유가 필요하다.

### 성별

성별은 청소년 발달, 또래 관계, 외모, 사회적 기대, 차별 경험의 양상과 연결될 수 있다. 그러나 성별은 LLM이 고정관념적 설명을 만들기 쉬운 공변량이기도 하다. 따라서 성별은 DIF 후보 탐색에서 조심스럽게 다뤄야 한다. 문항에 성별화된 역할, 외모, 또래 관계, 폭력, 관계적 공격성 같은 단서가 있을 때만 높은 후보 점수를 주는 원칙이 필요하다.

서론 삽입 문장 후보:

> 성별은 또래 관계와 자기평가의 사회적 맥락을 바꿀 수 있지만, 문항 단서 없이 일반적 성별 차이를 DIF로 해석하면 고정관념적 설명이 된다. 이 점에서 성별은 LLM rationale의 과잉 일반화 여부를 점검하는 중요한 공변량이다.

### 연령

연령은 발달 단계, 학년 전환, 진로 기대, 부모-자녀 관계의 변화와 연결된다. MAPS처럼 반복 관찰되는 자료에서는 연령이 강한 맥락 변수다. 다만 본 연구가 longitudinal DIF를 직접 검정하지 않는다면, 연령은 time-invariance 검정의 대체물이 아니다. 본 연구에서는 연령을 문항-공변량 DIF 후보 가설 생성의 공변량으로 두고, 발달적 설명이 실제 문항 기능 차이와 얼마나 구분되는지 확인하는 용도로 제한한다.

서론 삽입 문장 후보:

> 연령은 발달 단계와 연결되지만, 발달에 따른 잠재특성의 변화가 곧 문항 기능의 변화를 뜻하지는 않는다. 따라서 연령 관련 LLM rationale은 특히 impact와 threshold DIF의 경계를 검토하는 사례로 다뤄야 한다.

## 2. Keyword Baseline의 조작적 정의

현재 baseline은 `maps_llm_keyword_baseline_eval.R`에 구현된 deterministic lexical rule이다. 이 baseline은 LLM이 아니다. 문항 텍스트와 공변량 이름만 사용하며, 경험적 DIF label, 응답 분포, 문항 통계량, LLM 출력은 사용하지 않는다.

### 입력

- 분석 단위: 문항-공변량 조합
- 텍스트 입력: `item_text`
- 공변량 입력: `covariate`
- 사용하지 않는 정보: empirical DIF label, p-value, beta, response distribution, LLM rationale

### 점수 규칙

모든 문항-공변량 조합은 기본 점수 15점에서 시작한다. 해당 공변량의 키워드 사전에 포함된 문자열이 문항 텍스트에 하나라도 있으면 가중치를 더한다. 문자열 탐색은 `grepl(..., fixed = TRUE)`로 수행한다. 형태소 분석, 어간 추출, 동의어 확장, 빈도 가중, TF-IDF는 사용하지 않는다. 최종 점수는 5점 이상 95점 이하로 제한한다.

| 공변량 | 현재 키워드 | 가중치 | 점수 범위 |
|---|---|---:|---:|
| `discrim_any` | 다른 대우, 편견, 무시, 위축, 사회적 지위, 따돌, 못살게, 외국, 욕, 놀림, 소문 | +55 | 15 또는 70 |
| `korean_c` | 한국어, 한국문화, 한국 사람, 한국사람, 한국에, 한국의, 모국, 외국, 문화, 언어 | +50 | 15 또는 65 |
| `income_c` | 경제, 형편, 물건, 장소, 제공, 대학, 회사, 지위, 건강, 병원 | +45 | 15 또는 60 |
| `gender` | 외모, 이성친구, 신체적 특징, 친구, 따돌림, 소문, 욕설, 놀림 | +35 | 15 또는 50 |
| `age_c` | 진학, 진로, 미래, 부모역할, 자녀, 아이, 대학, 회사, 체류, 비자 | +35 | 15 또는 50 |

방법 섹션 문장 후보:

> Keyword baseline은 LLM과 비교하기 위한 규칙 기반 lexical baseline으로 정의하였다. 각 문항-공변량 조합은 기본 점수 15점을 부여받았고, 문항 텍스트에 해당 공변량의 사전 정의 키워드가 하나 이상 포함될 경우 공변량별 고정 가중치를 더하였다. 문자열 탐색은 고정 문자열 일치 방식으로 수행했으며, 형태소 분석, 동의어 확장, 빈도 가중, 경험적 DIF 결과, LLM 출력은 사용하지 않았다. 따라서 이 baseline은 표면 어휘 단서만으로 얻을 수 있는 최소 성능 기준으로 해석된다.

논의 섹션 문장 후보:

> Keyword baseline은 단순하기 때문에 약한 비교 기준처럼 보일 수 있지만, 본 연구에서는 오히려 엄격한 해석 장치로 기능한다. 차별 경험처럼 문항 표면에 직접 단서가 드러나는 공변량에서는 단순 lexical cue만으로도 높은 우선순위화 성능이 가능하다. 따라서 LLM의 추가 가치는 keyword baseline이 설명하지 못하는 간접적 의미 연결에서 확인되어야 한다.

## 3. LLM Rationale 코딩표 초안

단위는 LLM이 생성한 문항-공변량 조합별 rationale 하나다. 각 rationale에는 1차 코드 하나를 부여하고, 필요한 경우 보조 코드를 하나까지 부여한다. 핵심은 LLM 설명을 DIF 증거로 쓰지 않고, 설명의 유형과 실패 양상을 분석하는 것이다.

| 코드 | 이름 | 정의 | 판정 방향 | 예시 판단 기준 |
|---|---|---|---|---|
| `WOR` | Wording 기반 메커니즘 | 문항의 특정 단어, 표현, 어휘 난도, 번역 가능성, 문화적으로 표시된 표현을 근거로 threshold 차이를 설명한다. | 타당 후보 | 문항 안의 실제 표현을 지칭하고, 같은 잠재특성 수준에서 응답 기준 차이를 설명함. |
| `RSP` | 응답 과정 기반 메커니즘 | 이해, 회상, 비교 기준, 사회적 바람직성, 응답 범주 사용 방식의 차이를 설명한다. | 타당 후보 | 문항 표면 단어만이 아니라 응답자가 답을 고르는 과정을 설명함. |
| `CUL` | 문화·언어 맥락 기반 메커니즘 | 한국어 능력, 모국 문화, 한국 문화, 이중문화 맥락이 문항 해석에 미칠 수 있는 영향을 설명한다. | 타당 후보 | 공변량과 문항 내용 사이의 문화적 또는 언어적 연결이 구체적임. |
| `CON` | 구인 관련 내용 차이 | 공변량이 실제 잠재특성 수준과 관련될 수 있음을 설명하되, 이것을 DIF로 단정하지 않는다. | 적절한 보류 | “이 공변량은 construct level과 관련될 수 있으나 wording 기반 DIF 근거는 약하다”처럼 구분함. |
| `IMP` | Impact를 DIF로 오인 | 공변량에 따른 실제 잠재특성 차이를 같은 잠재특성 수준의 문항 기능 차이처럼 서술한다. | 실패 유형 | “소득이 낮으면 스트레스가 높으므로 이 문항은 DIF 가능성이 높다”처럼 item-function 근거 없이 일반 위험요인만 제시함. |
| `STY` | 성별·연령 등 고정관념적 서사 | 문항 단서 없이 성별, 연령, 소득에 대한 일반적 사회 통념으로 rationale을 만든다. | 실패 유형 | “여학생은 관계에 민감하다”, “나이가 많으면 미래 고민이 많다”처럼 문항 특수성이 약함. |
| `GEN` | 문항 무관 일반론 | 문항 내용과 직접 연결되지 않는 넓은 설명을 제시한다. | 실패 유형 | 어떤 문항에도 붙일 수 있는 일반 문장으로 구성됨. |
| `MIS` | 방향성 근거 불일치 | 높은 가능성 점수나 예상 방향을 제시하지만 rationale이 그 방향을 뒷받침하지 않는다. | 실패 유형 | positive/negative 방향과 설명 내용이 맞지 않거나, 방향을 판단할 근거가 없음. |
| `RES` | 적절한 낮은 근거 판단 | 문항에 공변량 관련 단서가 약하다고 보고 낮은 점수 또는 불명확한 방향을 제시한다. | 좋은 restraint | LLM이 무리한 설명을 만들지 않고 낮은 근거를 명시함. |

### 이진 보조 변수

| 변수 | 1로 코딩하는 경우 |
|---|---|
| `mentions_same_latent_level` | 같은 잠재특성 수준에서의 차이라는 DIF 조건을 명시하거나 그 논리를 반영함. |
| `uses_item_specific_evidence` | 문항의 실제 단어, 응답 범주, 구인 맥락 중 하나 이상을 근거로 듦. |
| `generic_covariate_story` | 문항 특수성 없이 공변량 일반 효과만 말함. |
| `stereotype_risk` | 성별, 연령, 소득, 출신 배경에 대한 고정관념적 추론이 포함됨. |
| `direction_supported` | 예상 방향이 rationale과 논리적으로 맞음. |

방법 섹션 문장 후보:

> LLM rationale은 후속 질적 코딩의 대상이 되며, DIF 원인에 대한 증거로 직접 해석하지 않는다. 각 rationale은 문항 wording 기반, 응답 과정 기반, 문화·언어 맥락 기반, 구인 관련 impact를 DIF로 오인한 경우, 고정관념적 공변량 서사, 문항 무관 일반론, 방향성 근거 불일치, 적절한 낮은 근거 판단으로 분류한다. 이 코딩은 LLM이 어떤 조건에서 유용한 후보 설명을 생성하고, 어떤 조건에서 심리측정적으로 부적절한 설명을 생성하는지 평가하기 위한 것이다.

## 4. 서론에 추가할 압축 문단

> MAPS의 공변량은 단순한 배경 변수가 아니다. 한국어 능력과 차별 경험은 다문화 청소년의 적응을 설명하는 실질적 조건인 동시에, 한국어 문항을 이해하고 사회적 경험을 해석하는 응답 과정과 연결된다. 가구소득, 성별, 연령 역시 가족 자원, 또래 관계, 발달 단계와 관련되지만, 이 관련성이 곧 문항 기능 차이를 뜻하지는 않는다. 따라서 이들 공변량은 LLM-DIF workflow에 적합한 시험대가 된다. 어떤 경우에는 문항 wording과 공변량 의미가 직접 맞물리고, 어떤 경우에는 LLM이 실제 잠재특성 차이나 사회적 고정관념을 threshold DIF처럼 설명할 위험이 있기 때문이다.

## 5. 확인한 주요 근거 문헌 후보

- National Youth Policy Institute. MAPS 2기 패널 안내 및 유저가이드. 2기 패널은 2019년 초등학교 4학년 다문화 청소년과 보호자를 대상으로 시작되었고, 자료에는 발달, 가족, 학교, 문화적응, 언어, 차별 경험 관련 변수가 포함된다. https://www.nypi.re.kr/archive/board?menuId=MENU00495
- National Youth Policy Institute. 다문화청소년패널조사 2기 청소년 조사내용(2019~). 청소년 조사에는 언어 능력, 문화적응 및 이중문화, 심리·사회적응, 학교생활 관련 문항이 포함된다. https://www.nypi.re.kr/archive/board?menuId=MENU00499
- Kim, H., Han, K., & Won, S. (2023). Perceived discrimination as a critical factor affecting self-esteem, satisfaction with physical appearance and depression of racial/ethnic minority adolescents in Korea. *Behavioral Sciences*, 13(4), 343. https://doi.org/10.3390/bs13040343
- Han, S. (2023). Factors affecting cultural adaptation stress by gender among multicultural adolescents in Korea. *Research in Community and Public Health Nursing*, 34(4), 320-331. https://doi.org/10.12799/rcphn.2023.00276
- Ahn, H. S., Lee, J., & Jin, Y. (2024). The effects of multicultural family support services on the longitudinal changes of acculturative stress, peer relations, and school adjustment. *Frontiers in Psychology*, 14, 1301294. https://doi.org/10.3389/fpsyg.2023.1301294
- Lee, J., & Lee, K. (2019). Reciprocal effects between Korean language ability and self-esteem in multicultural adolescents: The mediating effect of peer relationships. *Studies on Korean Youth*, 30(4), 7-32. RISS record: https://m.riss.kr/search/detail/DetailView.do?control_no=319e3698a9ac7abac85d2949c297615a&p_mat_type=1a0202e37d52c72d
- Choe, C., & Yu, S. (2025). Longitudinal cross-lagged analysis between depressive symptoms, social withdrawal, self-esteem, and school adaptation in multicultural adolescents. *Psychologica Belgica*, 65(1), 38-53. https://doi.org/10.5334/pb.1310
- Jin, Y., & Ahn, H. S. (2025). Acculturative stress and achievement motivation: The moderating role of immigrant mothers' Korean proficiency in South Korean multicultural adolescents. *Frontiers in Psychology*, 16, 1652737. https://doi.org/10.3389/fpsyg.2025.1652737
- Cheng, C.-P., Chen, C.-C., & Shih, C.-L. (2020). An exploratory strategy to identify and define sources of differential item functioning. *Applied Psychological Measurement*, 44(7-8), 548-560. https://doi.org/10.1177/0146621620931190
- Farquhar, S., Kossen, J., Kuhn, L., & Gal, Y. (2024). Detecting hallucinations in large language models using semantic entropy. *Nature*, 630, 625-630. https://doi.org/10.1038/s41586-024-07421-0
- Palmer, A., Smith, N. A., & Spirling, A. (2024). Using proprietary language models in academic research requires explicit justification. *Nature Computational Science*, 4, 2-3. https://doi.org/10.1038/s43588-023-00585-1
