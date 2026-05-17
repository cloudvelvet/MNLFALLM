# AI + 심리측정 DIF 논문에 필요한 조건

## 판단

약한 버전은 하지 않는 편이 낫습니다.

> “LLM에게 MAPS DIF 결과를 설명하게 했다.”

이 방식은 너무 사후적입니다. 문항 수도 작고, 리뷰어가 “LLM이 그럴듯한 이야기를 붙인 것”이라고 보기 쉽습니다.

논문화가 가능한 버전은 다음입니다.

> 사전에 고정한 LLM 기반 의미/메커니즘 가설이 empirical DIF pattern을 얼마나 예측하거나 우선순위화하는지 검증한다. 이때 단순 text feature, keyword baseline, 가능하면 human expert baseline과 비교한다.

현재 단계에서는 conditional go입니다. 다만 MAPS 8문항 사례만으로는 약하고, 지금처럼 105개 item과 487개 item-covariate pair로 확장해야 합니다.

## MAPS 단일 8문항 사례가 약한 이유

초기 MAPS acculturative-stress 적용은 다음 규모였습니다.

- 8개 문항.
- 4개 DIF covariate: parent age, Korean proficiency, income, discrimination.
- 32개 item-by-covariate prediction unit.

이 정도는 standalone LLM prediction paper로는 너무 작습니다. 한두 문항이 metric 전체를 좌우할 수 있습니다. wave를 독립 prediction unit처럼 세는 것도 부적절합니다. 문항 텍스트가 같기 때문입니다.

최소 목표:

- 적어도 100-150개 item-by-covariate unit.
- 가능하면 positive DIF case 20-30개 이상.
- 더 좋게는 두 번째 척도, 두 번째 데이터셋, 또는 외부 DIF benchmark.

현재 확장안:

- MAPS 다중 척도 item pool.
- 105개 item.
- 487개 item-covariate pair.

이 정도면 파일럿 논문 또는 방법론적 feasibility paper로는 훨씬 방어 가능합니다.

## 필요한 연구 설계

### 1. gold standard를 먼저 고정한다

LLM prompting 전에 empirical DIF target을 정해야 합니다.

- 최종 psychometric model.
- DIF decision rule.
- practical effect-size threshold.
- threshold DIF와 loading DIF 처리.
- direction 처리.
- sensitivity analysis.

MAPS에서는 wave-specific noise보다 안정적인 item-level DIF가 더 중요합니다. 가능하면 longitudinal ordinal MNLFA 또는 그에 준하는 formal DIF model을 목표로 둡니다.

### 2. LLM은 blind 상태로 예측하게 한다

LLM에게 줄 수 있는 정보:

- item wording.
- response options.
- construct definition.
- covariate definition.
- respondent group context.

LLM에게 주면 안 되는 정보:

- empirical DIF coefficient.
- p-value.
- flagged item ID.
- 기존 분석 결과.
- 연구자가 이미 알고 있는 DIF rationale.

이 구분이 깨지면 hypothesis generation이 아니라 post-hoc explanation이 됩니다.

### 3. 비교 기준을 반드시 둔다

LLM만 돌리면 설득력이 약합니다. 최소한 다음 baseline이 필요합니다.

- keyword baseline.
- simple lexical/text feature baseline.
- 가능하면 human expert baseline.
- 가능하면 naive prompt vs psychometric guardrail prompt 비교.

현재 결과에서 discrimination은 keyword baseline도 강했습니다. 이 점은 오히려 중요합니다. “LLM이 좋아 보인다”가 아니라 “단순 단어 매칭과 구분되는가”를 보여줘야 합니다.

### 4. 평가 지표는 classification accuracy보다 ranking utility 중심으로 둔다

이 작업의 실무적 목적은 모든 DIF를 자동 판정하는 것이 아닙니다. 전문가와 psychometrician이 먼저 볼 item-covariate pair를 줄이는 것입니다.

주요 지표:

- Average Precision / AUPRC.
- Precision@5.
- Precision@10.
- top-k validated yield.
- covariate-specific performance.

accuracy 하나로 평가하면 class imbalance와 threshold choice에 지나치게 흔들립니다.

### 5. failure mode를 결과로 삼는다

LLM이 틀린 경우도 논문 재료입니다. 특히 다음 유형은 꼭 분리해야 합니다.

- latent difference를 threshold DIF로 착각.
- construct-relevant content를 bias로 과해석.
- 사회적 고정관념에 기대어 rationale을 생성.
- 문항 wording에는 단서가 없지만 empirical DIF가 있는 경우.
- keyword baseline이 충분히 설명하는 경우.

이 논문은 “LLM이 잘 맞췄다”보다 “LLM을 어디까지 믿을 수 있고 어디서 조심해야 하는가”가 더 강한 메시지입니다.

## 논문화 기준

Go:

- LLM이 적어도 하나의 의미 있는 covariate lane에서 keyword baseline보다 낫다.
- top-k candidate 안에 empirical validation을 통과한 사례가 있다.
- failure mode가 체계적이고 이론적으로 해석 가능하다.

Conditional go:

- 전체 성능은 약하지만 discrimination/language proficiency처럼 특정 lane에서 패턴이 보인다.
- false positive 분석이 cautionary methods paper로 의미 있다.

Stop 또는 downgrade:

- LLM이 모든 baseline보다 일관되게 낮다.
- false positive가 대부분 generic stereotype이다.
- formal DIF/MNLFA validation을 수행할 수 없다.

## 안전한 논문 주장

쓸 수 있는 주장:

- LLM은 candidate DIF hypotheses를 생성할 수 있다.
- LLM은 일부 item-covariate pair의 검토 우선순위를 정하는 데 도움을 줄 수 있다.
- LLM output은 empirical validation 없이 DIF evidence로 해석할 수 없다.
- LLM은 latent trait difference와 measurement-function difference를 혼동할 수 있다.

피해야 할 주장:

- LLM이 DIF를 탐지한다.
- LLM이 편향 문항을 식별한다.
- LLM이 DIF의 원인을 밝혔다.
- LLM이 전문가를 대체할 수 있다.
- LLM score가 높은 문항은 불공정하다.

