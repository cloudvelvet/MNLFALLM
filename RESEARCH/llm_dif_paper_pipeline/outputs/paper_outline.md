# 논문 개요: LLM 보조 DIF 가설 생성

## 초록 뼈대

배경: DIF 검증은 공정하고 타당한 집단 비교의 핵심 절차이지만, 왜 특정 문항에서 DIF가 발생할 수 있는지에 대한 해석 가능한 item-level hypothesis를 생성하는 일은 여전히 연구자 노동에 크게 의존한다.

목적: 본 연구는 LLM이 다문화 패널 문항에서 의미적으로 그럴듯한 DIF 후보 가설을 생성할 수 있는지, 그리고 그 후보들이 후속 심리측정 검증의 우선순위를 정하는 데 도움이 되는지를 평가한다.

방법: MAPS 다문화 패널 문항을 사용하여 Gemini가 item-covariate DIF hypothesis를 생성한다. LLM score는 keyword baseline 및 provisional ordinal DIF screening과 비교하고, 주요 scale에 대해서는 후속 MNLFA/ordinal DIF validation을 계획한다.

결과: ranking utility, covariate-specific pattern, case study를 보고한다. 일치 사례뿐 아니라 failure mode도 함께 강조한다.

결론: LLM은 standalone DIF detector가 아니라 hypothesis generation 및 triage tool로 다루어야 한다.

## Introduction

1. DIF와 measurement invariance는 longitudinal multicultural research에서 중요하다.
2. 통계적 DIF 방법은 detection에는 강하지만, item-level explanatory hypothesis generation은 여전히 expert-intensive하다.
3. LLM은 item text와 covariate context를 바탕으로 candidate mechanism을 생성하는 데 도움이 될 수 있다.
4. 그러나 LLM은 latent trait difference, cultural stereotype, true measurement-function change를 혼동할 수 있다.
5. 본 논문은 LLM-assisted DIF hypothesis generation의 유용성과 위험을 함께 평가한다.

## Related Work

1. DIF, item bias, impact, measurement invariance.
2. MIMIC/MNLFA와 covariate-rich DIF modeling.
3. 전문가 문항 검토와 qualitative DIF explanation.
4. AI/LLM 기반 psychometric item generation과 item review.
5. 직접적인 LLM-DIF 선행연구:
   - Li et al. (2024) ChatGPT DIF poster.
   - Maeda & Lu (2025) LLM/XAI text-to-DIF prediction.
6. Gap: longitudinal multicultural data에서 ordinal/MNLFA validation과 연결되는 theory-guided, interpretable hypothesis generation 연구가 부족하다.

## Method

### Data

- MAPS 다문화 패널.
- parent/youth item pools.
- covariates: discrimination experience, Korean proficiency, income, age, gender where applicable.
- 분석 단위: item-covariate pair.

### LLM Prompting

- Prompt는 threshold DIF probability, direction, confidence, rationale을 요구한다.
- Prompt는 latent trait difference와 threshold DIF를 명시적으로 구분하게 한다.
- generation prompt에는 empirical DIF label을 넣지 않는다.

### Baselines

- keyword baseline.
- optional lexical baseline.
- optional naive prompt baseline.

### Empirical DIF Screening

- keyed theta proxy를 사용한 provisional ordinal-logit DIF screen.
- 선택 scale에 대한 formal MNLFA/ordinal DIF validation.

### Evaluation

- AUPRC / Average Precision.
- Precision@k.
- covariate-stratified performance.
- qualitative failure-mode coding.

## Results

1. item-covariate pair의 descriptive map.
2. LLM vs keyword ranking performance 전체 결과.
3. covariate-specific results.
4. top-k hypotheses.
5. case studies:
   - validated discrimination-linked DIF candidate.
   - Korean proficiency semantic candidate.
   - age false positive / latent-difference confusion.
   - LLM이 놓친 empirical DIF.

## Discussion

1. LLM은 final detection보다 hypothesis prioritization에서 더 유용할 가능성이 있다.
2. 문항 wording이 covariate-relevant construct를 직접 지칭하면 keyword baseline도 강할 수 있다.
3. Korean proficiency처럼 직접 단어 매칭이 어려운 semantic link에서는 LLM이 추가 가치를 보일 수 있다.
4. LLM은 심리측정적으로 지지되지 않는 그럴듯한 이야기를 과생성할 수 있다.
5. Formal DIF/MNLFA validation은 선택사항이 아니라 필수 gate다.

## Limitations

- 단일 dataset.
- full 487 pair run 전까지는 pilot scale.
- Gemini model/version dependence.
- provisional label은 gold standard가 아님.
- prompt sensitivity.
- causal mechanism proof 불가.

## Conclusion

LLM은 semantic plausibility와 measurement evidence를 엄격히 분리하는 guarded psychometric workflow 안에서 interpretable DIF hypothesis generator로 평가될 수 있다.

