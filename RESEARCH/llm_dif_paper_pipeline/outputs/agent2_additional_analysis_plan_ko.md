# Agent 2 방법론 및 추가 분석 제안

## 기본 판단

현재 연구는 LLM이 DIF를 판정한다는 논문으로 가면 방어가 어렵다. 그러나 "경험적 DIF 결과를 보지 않은 상태에서 LLM이 문항-공변량 단위의 DIF 후보 가설을 생성하고, 그 후보가 후속 심리측정 검증의 우선순위 설정에 도움을 주는가"라는 application 또는 방법론적 workflow 논문으로는 방어 가능성이 있다. 따라서 추가 분석의 목표는 LLM의 우월성을 과장하는 것이 아니라, 어느 조건에서 유용하고 어느 조건에서 위험한지를 재현 가능한 절차로 보여주는 데 두어야 한다.

현재 pilot 30 결과는 이 방향과 잘 맞는다. 전체 AP 차이는 LLM 쪽으로 약간 유리하지만 불확실하고, korean_c에서는 비교적 안정적인 LLM advantage가 나타난다. 반면 discrim_any에서는 keyword baseline이 강하고, age_c와 income_c에서는 LLM의 과잉 해석 가능성이 보인다. 이 패턴은 논문에서 단순 성능 경쟁보다 "공변량의 의미 구조에 따른 조건부 유용성"으로 해석하는 것이 가장 안전하다.

## 우선순위 1: 전체 105문항 prompt sensitivity

가장 먼저 끝내야 할 분석은 전체 105문항에 대한 prompt sensitivity다. 현재 연구의 가장 큰 약점은 폐쇄형 LLM의 출력이 prompt 문장에 따라 얼마나 흔들리는지 모른다는 점이다. 따라서 original, strict_dif, response_process 세 가지 prompt를 동일한 문항-공변량 조합에 적용하고, 결과의 안정성과 성능 차이를 비교해야 한다.

방법 섹션에는 다음과 같이 쓸 수 있다. 각 문항에 대해 세 가지 prompt 조건을 구성하였다. original 조건은 기본 DIF 가설 생성 지시문을 사용하였다. strict_dif 조건은 impact와 DIF의 구분을 강하게 강조하고, 공변량이 잠재특성의 실제 수준에 미치는 일반 효과만으로는 높은 DIF 가능성을 부여하지 않도록 지시하였다. response_process 조건은 문항 이해, 회상, 판단, 참조집단, 사회적 바람직성, 응답 범주 사용 등 응답 과정의 차이에 초점을 맞추도록 설계하였다. 세 조건 모두 경험적 DIF 결과, p값, 효과크기, keyword baseline 결과를 입력받지 않았다.

보고 지표는 세 층으로 나누는 것이 좋다. 첫째, 각 prompt 조건의 ranking utility를 AP, AUPRC, precision@5, precision@10, recall@10으로 보고한다. 둘째, prompt 간 안정성을 Spearman 순위상관, Kendall 순위상관, top-10 overlap, top-20 overlap으로 보고한다. 셋째, 공변량별로 성능을 나누어 korean_c, discrim_any, gender, age_c, income_c에서 prompt 효과가 달라지는지 확인한다. 특히 strict_dif prompt에서 age_c와 income_c의 과잉 점수가 줄어드는지 확인하면, LLM에 대한 guardrail의 효과를 보여줄 수 있다.

논문에서 중요한 비교는 "어떤 prompt가 가장 높았는가"가 아니라 "strict_dif 조건이 impact를 DIF로 오인하는 경향을 줄였는가"이다. 만약 strict_dif에서 전체 AP가 조금 낮아지더라도 age_c/income_c의 false positive가 줄고 rationale의 질이 좋아진다면, 이는 방법론적으로 의미 있는 결과다.

## 우선순위 2: bootstrap CI와 permutation test

두 번째로 중요한 분석은 불확실성 추정이다. pilot 30에서 이미 cluster bootstrap과 paired permutation을 수행한 것은 매우 좋다. 전체 105문항에서도 같은 절차를 유지해야 한다. 단일 AP 값만 보고하면 "LLM이 keyword보다 좋다"는 식의 과장으로 읽히기 쉽다. 반대로 신뢰구간과 permutation p값을 함께 제시하면, 논문이 훨씬 조심스럽고 방어 가능해진다.

절차는 다음과 같이 제안한다. 분석 단위는 문항-공변량 조합이지만, bootstrap resampling은 문항 단위로 수행한다. 같은 문항에서 여러 공변량 점수가 생성되므로, item-level clustering을 보존하기 위해 item_id 또는 custom_id를 cluster로 두고 2,000회 이상 재표집한다. 각 bootstrap 표본에서 LLM과 baseline의 AP, AUPRC, precision@k 차이를 계산하고, percentile confidence interval을 산출한다. paired permutation test는 같은 문항-공변량 조합에서 LLM 점수와 baseline 점수를 교환하는 방식으로 수행하며, 5,000회 이상 반복한다.

보고 지표는 전체 및 공변량별로 AP difference, AUPRC difference, precision@10 difference, 95% bootstrap CI, permutation p값을 제시한다. 다만 income_c처럼 empirical positive가 극히 적은 공변량은 별도 해석 제한을 명시해야 한다. 이 분석은 KCI 논문에서 "작은 pilot 결과를 과잉 해석하지 않았다"는 방어 장치가 된다.

## 우선순위 3: rationale coding 실제 적용

세 번째 우선순위는 rationale coding이다. 이 연구의 차별점은 단순 점수 예측이 아니라 rationale-bearing output이다. 따라서 rationale을 분석하지 않으면 LLM을 쓴 이유가 약해진다. 반대로 rationale coding을 실제로 적용하면, LLM이 무엇을 근거로 DIF 가설을 만드는지, 그리고 어디서 실패하는지를 보여줄 수 있다.

코딩 단위는 문항-공변량 조합별 LLM rationale이다. 각 rationale은 복수 코딩이 가능하도록 한다. 권장 코드는 다음과 같다. 첫째, wording 기반 근거는 문항의 특정 단어, 표현, 어휘 난도, 문화적으로 표시된 표현을 근거로 삼는 경우다. 둘째, response process 기반 근거는 이해, 회상, 판단, 비교 기준, 사회적 바람직성, 응답 범주 사용 차이를 언급하는 경우다. 셋째, 문화·언어 맥락 기반 근거는 한국어 능력, 한국문화, 모국 문화, 이중문화 경험이 문항 해석에 미치는 영향을 구체적으로 설명하는 경우다. 넷째, impact-DIF 혼동은 공변량이 잠재특성 수준에 미치는 실제 차이를 문항 threshold 차이처럼 서술하는 경우다. 다섯째, 고정관념적 근거는 문항 단서 없이 성별, 연령, 소득에 대한 일반론을 사용하는 경우다. 여섯째, 문항 무관 추측은 문항 내용과 직접 연결되지 않는 설명을 제시하는 경우다.

방법 섹션에서는 전체 rationale 중 최소 20-30%를 두 명의 코더가 독립 코딩하고, Cohen's kappa 또는 Krippendorff's alpha를 보고하는 방식을 제안한다. 자원이 부족하면 전체를 한 명이 코딩하되, 무작위 30개 또는 top-20 후보에 대해 두 번째 검토자가 확인하는 간소화 절차를 쓸 수 있다. 결과 섹션에는 prompt 조건별, 공변량별 코드 비율을 보고한다. 특히 korean_c에서 response_process/문화·언어 맥락 코드가 높은지, age_c/income_c에서 impact-DIF 혼동이나 고정관념 코드가 높은지 확인하는 것이 핵심이다.

## 우선순위 4: 추가 baseline

keyword baseline 하나만으로는 비교 기준이 너무 약하다는 비판이 나올 수 있다. 따라서 추가 baseline을 넣는 것이 좋다. 다만 복잡한 모델을 너무 많이 넣으면 논문 초점이 흐려질 수 있으므로, 최소 2개 정도가 적절하다.

첫 번째 추가 baseline은 TF-IDF 또는 lexical similarity baseline이다. 이미 API-free 분석에서 TF-IDF baseline을 계산했으므로 유지하면 된다. 문항 텍스트와 공변량 설명문을 TF-IDF 벡터로 변환하고 cosine similarity를 산출한다. 이 baseline은 "표면 단어 일치보다 조금 더 넓은 어휘 유사성"을 대표한다. 보고 지표는 LLM 및 keyword baseline과 동일하게 AP, AUPRC, precision@k를 사용한다.

두 번째 baseline은 sentence-transformer embedding similarity가 적절하다. 한국어 문항을 다루므로 multilingual sentence-transformer 또는 한국어 SBERT 계열 모델을 사용할 수 있다. 문항 문장과 공변량 설명문을 embedding으로 변환하고 cosine similarity를 산출한다. 이 baseline은 생성형 LLM 없이도 의미 유사도만으로 가능한 성능을 보여준다. 만약 embedding baseline이 korean_c에서 LLM보다 낮다면, LLM의 장점이 단순 semantic similarity가 아니라 응답 과정에 대한 추론에 있음을 주장할 수 있다. 반대로 embedding baseline이 비슷하게 나오면, 논문은 "비싼 생성형 LLM이 꼭 필요한가"라는 질문에 정직하게 답할 수 있다.

세 번째 baseline은 선택 사항이다. pilot 또는 전체 105문항에서 empirical label을 사용해 logistic/meta-model을 훈련하는 것은 표본 수가 작으면 과적합 위험이 크다. 따라서 본 논문에서는 주 분석 baseline으로 쓰기보다 탐색적 보조분석으로 제한하는 것이 좋다. 사용한다면 leave-one-scale-out 또는 leave-one-item-out cross-validation을 적용하고, feature는 keyword score, TF-IDF similarity, embedding similarity, 문항 길이, 공변량 유형 정도로 제한한다. 이 모델은 LLM과 직접 경쟁시키기보다 "단순한 텍스트 특징의 조합으로 설명되는 부분이 어느 정도인가"를 확인하는 용도로 두는 것이 안전하다.

## 우선순위 5: human expert plausibility rating

인간 전문가 평정은 논문의 설득력을 크게 높일 수 있지만, 실행 비용이 있다. 가능하다면 상위 후보와 오류 후보를 표집하여 psychometrician 또는 다문화 청소년 연구자에게 plausibility를 평정하게 하는 것이 좋다.

절차는 다음과 같다. LLM 점수가 높은 top-20, keyword만 높은 top-20, LLM false positive 후보 10개, LLM false negative 후보 10개를 포함해 약 40-60개의 문항-공변량 조합을 표집한다. 평가자에게는 empirical DIF 결과와 LLM 점수를 숨기고, 문항, 구인 설명, 공변량 정의, LLM rationale만 제시한다. 평가자는 각 rationale에 대해 1점에서 5점까지 plausibility를 부여하고, "DIF 가설로 후속 검증할 가치가 있는가"를 yes/no 또는 3점 척도로 평가한다.

보고 지표는 평균 plausibility, 평가자 간 일치도, LLM score와 human plausibility의 Spearman 상관, empirical provisional DIF와 human plausibility의 관계다. 이 분석의 목적은 LLM이 정답을 맞혔는지를 입증하는 것이 아니라, LLM rationale이 전문가가 보기에 검토 가능한 가설인지 확인하는 것이다. KCI 논문에서는 이 절차가 있으면 "LLM이 만든 그럴듯한 말"이라는 비판을 상당히 줄일 수 있다.

## 우선순위 6: targeted MNLFA validation

MNLFA validation은 가장 강력하지만 가장 무겁다. 전체 문항-공변량 조합에 대해 MNLFA를 전부 돌리려 하면 논문이 커지고 수렴 문제도 생길 수 있다. 따라서 targeted validation으로 제한하는 것이 좋다.

추천 절차는 다음과 같다. LLM top 후보 중 korean_c 관련 상위 5-10개, keyword가 강한 discrim_any 상위 5개, LLM이 높게 줬지만 empirical screening은 낮은 age_c/income_c 후보 5개를 선정한다. 각 구인별로 기본 ordinal factor model을 설정하고, 잠재요인의 평균과 분산에 대한 공변량 효과를 먼저 허용한다. 이후 후보 문항의 threshold에 해당 공변량 효과를 추가한 모형과 추가하지 않은 모형을 비교한다. 가능하면 loading DIF까지 확장하지 말고 threshold DIF에 초점을 맞추는 것이 현재 연구 질문과 더 잘 맞다.

보고 지표는 후보별 threshold covariate effect estimate, standard error, p값 또는 credible interval, 모형 적합도 변화, AIC/BIC 변화, 그리고 효과 방향이 LLM의 expected_direction과 일치하는지 여부다. 이때 MNLFA 결과도 최종 진실로 쓰기보다 targeted validation evidence로 표현해야 한다. 핵심은 LLM top 후보 일부가 후속 심리측정 모형에서 실제로 검토할 가치가 있는지를 보여주는 것이다.

## 권장 실행 순서

가장 먼저 전체 105문항 prompt sensitivity를 완료한다. 이것이 논문의 가장 직접적인 보강이다. 그 다음 전체 결과에 대해 bootstrap CI와 permutation test를 다시 계산한다. 동시에 rationale coding을 최소 표본부터 시작한다. 세 번째로 TF-IDF와 embedding similarity baseline을 추가한다. 네 번째로 human plausibility rating을 소규모라도 수행한다. 마지막으로 논문 분량과 시간 여유가 있으면 targeted MNLFA validation을 넣는다.

실행 우선순위를 한 줄로 정리하면 다음과 같다.

1. 전체 105문항 prompt sensitivity
2. bootstrap CI 및 paired permutation test
3. rationale coding 실제 적용
4. TF-IDF 및 embedding similarity baseline
5. human plausibility rating
6. targeted MNLFA validation

KCI 또는 짧은 application 논문이라면 1-4번만 충실히 해도 방어 가능하다. 5번이 들어가면 설득력이 크게 올라간다. 6번은 가장 강하지만, 시간이 부족하면 "후속 validation 설계"로 남겨도 된다. 다만 SSCI를 노린다면 5번 또는 6번 중 하나는 실제 분석으로 포함하는 편이 좋다.

## 방법 섹션에 들어갈 수 있는 요약 문장

본 연구는 LLM 산출물의 안정성과 비교 가능성을 평가하기 위해 여섯 가지 보조 분석을 수행하였다. 첫째, 세 가지 prompt 조건을 동일한 문항-공변량 조합에 적용하여 prompt sensitivity를 평가하였다. 둘째, 문항 단위 cluster bootstrap과 paired permutation test를 사용해 LLM과 baseline 간 ranking utility 차이의 불확실성을 추정하였다. 셋째, LLM rationale을 wording 기반, response process 기반, 문화·언어 맥락 기반, impact-DIF 혼동, 고정관념적 근거, 문항 무관 추측으로 코딩하여 LLM 추론의 성공 및 실패 양상을 분석하였다. 넷째, keyword baseline 외에 TF-IDF 및 embedding similarity baseline을 구성하여 LLM의 추가 가치가 단순 어휘 또는 의미 유사도만으로 설명되는지 검토하였다. 다섯째, 일부 후보에 대해 전문가 plausibility rating을 실시하여 LLM rationale이 후속 검증 가능한 가설로 받아들여질 수 있는지 확인하였다. 여섯째, 상위 후보에 대해서는 targeted MNLFA-style validation을 수행하여 LLM이 제안한 threshold DIF 방향과 후속 심리측정 모형의 결과가 일치하는지 탐색적으로 평가하였다.

