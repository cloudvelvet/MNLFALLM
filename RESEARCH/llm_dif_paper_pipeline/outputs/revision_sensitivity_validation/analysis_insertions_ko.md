# Revision Sensitivity and Validation Insertions

생성일: 2026-05-28

## 1. Screening 기준 민감도 분석

아래 표는 동일한 LLM 점수와 keyword 점수를 사용하되, provisional screening-positive 기준만 바꾸어 AP와 P@10을 다시 계산한 결과다. 주 분석 기준은 `FDR < .05 and |beta| >= .20`이다.

| criterion | prompt_version | n_pairs | positives | positive_prevalence | llm_ap | keyword_ap | llm_p_at_10 | keyword_p_at_10 | positive_jaccard_with_main | main_positive_retained |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FDR<.05 only | original | 486 | 238 | 0.49 | 0.553 | 0.657 | 0.8 | 0.7 | 0.538 | 1.0 |
| FDR<.05 and \|beta\|>=.10 | original | 486 | 194 | 0.399 | 0.474 | 0.552 | 0.7 | 0.7 | 0.66 | 1.0 |
| FDR<.05 and \|beta\|>=.20 (main) | original | 486 | 128 | 0.263 | 0.382 | 0.441 | 0.6 | 0.7 | 1.0 | 1.0 |
| FDR<.05 and \|beta\|>=.30 | original | 486 | 86 | 0.177 | 0.326 | 0.389 | 0.6 | 0.7 | 0.672 | 0.672 |
| FDR<.05 only | strict_dif | 482 | 237 | 0.492 | 0.557 | 0.664 | 0.5 | 0.7 | 0.536 | 1.0 |
| FDR<.05 and \|beta\|>=.10 | strict_dif | 482 | 193 | 0.4 | 0.496 | 0.558 | 0.4 | 0.7 | 0.658 | 1.0 |
| FDR<.05 and \|beta\|>=.20 (main) | strict_dif | 482 | 127 | 0.263 | 0.405 | 0.445 | 0.3 | 0.7 | 1.0 | 1.0 |
| FDR<.05 and \|beta\|>=.30 | strict_dif | 482 | 85 | 0.176 | 0.308 | 0.392 | 0.0 | 0.7 | 0.669 | 0.669 |

해석: 기준을 완화하면 positive prevalence가 커지고 AP 기준선도 함께 올라간다. 기준을 강화하면 positive 수가 줄어들어 AP가 불안정해진다. 두 prompt 모두에서 LLM AP는 대체로 keyword AP를 일관되게 넘지 못한다. 따라서 주 결론은 practical nonzero 기준 변화에 크게 의존하지 않는 편이다.

## 2. 6차년도 single-wave 민감도 분석

반복측정 pooled long 결과에 대한 대조로 6차년도 단일 wave screening label을 사용했다. 이는 cluster-robust 또는 mixed model과 동일한 분석은 아니지만, 동일 응답자의 반복 관측 의존성 문제를 피한 보조 기준이다.

| criterion | prompt_version | n_pairs | positives | positive_prevalence | llm_ap | keyword_ap | llm_p_at_10 | keyword_p_at_10 | positive_jaccard_with_main | main_positive_retained |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Wave 6 single-wave screening | original | 486 | 70 | 0.144 | 0.208 | 0.299 | 0.4 | 0.3 | 0.329 | 0.383 |
| Wave 6 single-wave screening | strict_dif | 482 | 69 | 0.143 | 0.201 | 0.302 | 0.2 | 0.3 | 0.324 | 0.378 |

해석: 6차년도 단일 wave 기준에서도 LLM AP는 keyword AP를 넘지 못했다. original 조건은 LLM AP .208, keyword AP .299였고, strict_dif 조건은 LLM AP .201, keyword AP .302였다. 따라서 1-5차 pooled long 기준에서의 결론은 단일 wave 보조 기준에서도 유지된다.

## 3. Rationale coding 핵심 요약

| code | original | strict_dif |
| --- | --- | --- |
| CULTURE_LANGUAGE_CONTEXT | 0.43 | 0.44 |
| IMPACT_DIF_CONFUSION | 0.006 | 0.019 |
| ITEM_IRRELEVANT_SPECULATION | 0.019 | 0.015 |
| NO_WITHIN_TRAIT_CONDITIONING | 0.399 | 0.305 |
| RESPONSE_PROCESS | 0.895 | 0.948 |
| STEREOTYPE_GENDER_AGE | 0.169 | 0.197 |
| TESTABLE_HYPOTHESIS | 0.689 | 0.718 |
| VAGUE_GENERALITY | 0.282 | 0.241 |
| WORDING | 0.364 | 0.309 |

해석: strict_dif prompt는 RESPONSE_PROCESS와 TESTABLE_HYPOTHESIS 비율을 높이고, NO_WITHIN_TRAIT_CONDITIONING과 VAGUE_GENERALITY를 낮췄다. 그러나 STEREOTYPE_GENDER_AGE와 IMPACT_DIF_CONFUSION은 줄지 않았다. 따라서 엄격한 지시문은 일부 설명 품질을 개선했지만, 성별·연령 일반론과 실제 차이-DIF 혼동을 제거하지는 못했다.

## 4. Human validation 상태

현재 폴더에서 독립적인 사람 코더가 작성한 완료 파일은 발견되지 않았다. 그래서 이 단계에서 Cohen's kappa나 Krippendorff's alpha를 보고하면 안 된다. 대신 다음 두 파일을 생성했다.

- `human_validation_blind_coding_sheet.csv`: 두 명의 코더가 blind 상태로 판단근거를 수동 코딩할 수 있는 시트
- `human_validation_sample_key.csv`: 코딩 완료 후 label, LLM score, keyword score, rule-based flags와 대조하기 위한 key 파일

권장 보고 방식은 다음과 같다.

> LLM 판단근거의 규칙 기반 코딩 결과를 검토하기 위해 prompt 조건, outcome 유형(TP/FP/FN/TN), 공변량, 고위험 코드가 층화되도록 표본을 추출하였다. 두 명의 코더는 empirical screening label과 LLM 점수를 보지 않은 상태에서 문항 내용 연결성, 같은 잠재특성 조건 명시, 응답 과정 근거, 검증 가능성, impact-DIF 혼동, 고정관념 또는 모호한 일반론 여부를 독립적으로 코딩한다. 코딩 완료 후 범주별 일치도와 rule-based coding의 precision/recall을 보고한다.

## 5. 문항 원문 예시

전체 예시는 `item_examples_top_candidates.csv`와 `item_examples_top_candidates.md`에 저장했다. 아래 표는 논문용으로 축약한 예시다.

| prompt_version | covariate | respondent_type | scale_name | item_id | item_text | llm_score | keyword_score | label | beta | p_fdr | outcome_70 | rationale | expert_audit_comment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| original | age_c | youth | Parenting / parent relationship | youth_parenting__parenting_a02 | 부모님(보호자)은 내가 시간을 어떻게 보내는지 알고 계신다 | 90 | 15 | False | 0.007 | 0.969 | FP70 | The interpretation of 'parents knowing how I spend my time' is likely to change developmentally with increasing ad… | LLM 고점이지만 주 screening에서는 positive가 아니다. 성별/연령 일반론 또는 고정관념 위험을 별도 점검해야 한다. |
| original | age_c | youth | Parenting / parent relationship | youth_parenting__parenting_b06 | 부모님(보호자)은 내가 학교에서 어떻게 생활하는지 관심을 갖고 물어보신다 | 85 | 15 | False | 0.003 | 0.984 | FP70 | As adolescents age, their developmental stage may alter how they perceive or interpret parental inquiries about sc… | LLM 고점이지만 주 screening에서는 positive가 아니다. 성별/연령 일반론 또는 고정관념 위험을 별도 점검해야 한다. |
| original | age_c | youth | Teacher support | youth_teacher_support__te_sup_03 | 우리 담임선생님은 나를 중요한 사람으로 인정해주시는 것 같다 | 65 | 15 | True | 0.313 | 0.0113 | FN70 | The interpretation of what constitutes 'recognition as an important person' by a teacher may plausibly evolve as a… | screening-positive이나 LLM이 낮게 본 조합이다. 성별/연령 일반론 또는 고정관념 위험을 별도 점검해야 한다. |
| original | discrim_any | parent | Parent acculturation | parent_acculturation__p_accul_08 | 나는 한국사람들보다 모국사람들이 나를 더 동등하게 대해준다고 느낀다 | 90 | 15 | False | 0.066 | 0.355 | FP70 | Discrimination experience directly impacts perceptions of how 'Korean people' treat the respondent, potentially sh… | LLM 고점이지만 주 screening에서는 positive가 아니다. 잠재특성 실제 차이를 DIF 근거로 오인할 위험이 있다. 응답 과정과 검증 가능한 가설 형식은 비… |
| original | discrim_any | parent | Parent acculturative stress | parent_acculturative_stress__p_accul_str_01 | 나는 사회생활에서 한국 사람들과 다른 대우를 받는다 | 90 | 70 | True | 0.552 | 8.39e-19 | TP70 | Reporting prior discrimination experience may lower the threshold for endorsing 'different treatment' in social li… | 고점 LLM 후보이며 screening-positive 조합이다. 응답 과정과 검증 가능한 가설 형식은 비교적 분명하다. |
| original | discrim_any | youth | Youth acculturative stress | youth_acculturative_stress__s_accul_str_07 | 나의 부모님이 외국인이라고 친구들이 따돌린다 | 60 | 70 | True | 1.028 | 2.11e-06 | FN70 | Prior experience with discrimination might heighten sensitivity to social exclusion, potentially lowering the thre… | screening-positive이나 LLM이 낮게 본 조합이다. 응답 과정과 검증 가능한 가설 형식은 비교적 분명하다. |
| original | gender | youth | Bullying victimization | youth_bullying__bullying_05 | 나에 대해 거짓소문을 퍼뜨려서 다른 친구들이 나를 싫어하게 되었다 | 90 | 50 | False | -0.076 | 0.648 | FP70 | Relational aggression, such as spreading rumors leading to social dislike, is often a more salient and impactful f… | LLM 고점이지만 주 screening에서는 positive가 아니다. 성별/연령 일반론 또는 고정관념 위험을 별도 점검해야 한다. |
| original | gender | youth | Youth worry | youth_worry__s_worry_11 | 나의 외모 문제 | 85 | 50 | True | 0.491 | 1.56e-30 | TP70 | Societal and cultural expectations regarding appearance differ significantly by gender, potentially influencing th… | 고점 LLM 후보이며 screening-positive 조합이다. 응답 과정과 검증 가능한 가설 형식은 비교적 분명하다. |
| original | gender | youth | Teacher support | youth_teacher_support__te_sup_03 | 우리 담임선생님은 나를 중요한 사람으로 인정해주시는 것 같다 | 60 | 15 | True | 0.211 | 8.45e-06 | FN70 | Cultural gender roles in Korea might influence how 'being recognized as an important person' by a teacher is perce… | screening-positive이나 LLM이 낮게 본 조합이다. |
| original | income_c | youth | Youth worry | youth_worry__s_worry_02 | 진학, 진로 문제 | 90 | 15 | False | 0.039 | 0.0831 | FP70 | Lower socioeconomic resources directly exacerbate 'school advancement' and 'career path problems,' lowering the en… | LLM 고점이지만 주 screening에서는 positive가 아니다. 응답 과정과 검증 가능한 가설 형식은 비교적 분명하다. |
| original | income_c | youth | Parent support | youth_parent_support__p_support_a02 | 부모님(보호자)은 학교에서 어려운 일이 생기면 도와주신다 | 90 | 15 | False | 0.076 | 0.00448 | FP70 | Household income can influence the types of 'help' parents can provide for school difficulties, particularly for r… | LLM 고점이지만 주 screening에서는 positive가 아니다. 응답 과정과 검증 가능한 가설 형식은 비교적 분명하다. |
| original | income_c | parent | Parent acculturation | parent_acculturation__p_accul_10 | 나는 한국인이나 모국인 누구도 나를 이해하지 못한다고 생각할 때가 있다 | 10 | 15 | True | -0.203 | 4.82e-25 | FN70 | Socioeconomic status is a general risk factor for acculturation stress but does not directly alter the interpretat… | screening-positive이나 LLM이 낮게 본 조합이다. 응답 과정과 검증 가능한 가설 형식은 비교적 분명하다. |
| original | korean_c | youth | Youth worry | youth_worry__s_worry_02 | 진학, 진로 문제 | 90 | 15 | False | -0.118 | 0.0207 | FP70 | Lower Korean proficiency directly creates more tangible 'school advancement' and 'career path problems,' making hi… | LLM 고점이지만 주 screening에서는 positive가 아니다. 응답 과정과 검증 가능한 가설 형식은 비교적 분명하다. |
| original | korean_c | parent | Parent acculturation | parent_acculturation__p_accul_12 | 나는 종종 한국사람들이나 모국사람들 모두 나를 이해하는데 어려움을 느낀다고 생각한다 | 90 | 65 | True | -0.428 | 1.29e-102 | TP70 | Lower Korean proficiency may directly contribute to actual communication difficulties with Koreans, leading to a s… | 고점 LLM 후보이며 screening-positive 조합이다. 잠재특성 실제 차이를 DIF 근거로 오인할 위험이 있다. |
| original | korean_c | parent | Parenting efficacy | parent_parenting_efficacy__p_efficacy_02 | 나는 내가 유능한 부모라고 생각한다 | 90 | 15 | False | -0.122 | 2.63e-08 | FP70 | Lower Korean proficiency might lead to misinterpretation of '유능한' (competent) or the overall item nuance, altering… | LLM 고점이지만 주 screening에서는 positive가 아니다. 응답 과정과 검증 가능한 가설 형식은 비교적 분명하다. |
| original | korean_c | parent | Parent acculturation | parent_acculturation__p_accul_10 | 나는 한국인이나 모국인 누구도 나를 이해하지 못한다고 생각할 때가 있다 | 60 | 65 | True | -0.393 | 3.21e-87 | FN70 | Lower Korean proficiency could heighten sensitivity to communication barriers, making respondents more likely to e… | screening-positive이나 LLM이 낮게 본 조합이다. |
| strict_dif | age_c | youth | Parenting / parent relationship | youth_parenting__parenting_a03 | 부모님(보호자)은 내가 외출할 경우 언제 들어올지 알고 계신다 | 95 | 15 | False | 0.117 | 0.32 | FP70 | Parental oversight and adolescents' autonomy typically change with age, meaning older adolescents might report les… | LLM 고점이지만 주 screening에서는 positive가 아니다. 성별/연령 일반론 또는 고정관념 위험을 별도 점검해야 한다. |
| strict_dif | age_c | youth | Youth worry | youth_worry__s_worry_08 | 이성친구와의 문제 | 90 | 15 | False | 0.189 | 0.226 | FP70 | The developmental stage associated with age profoundly influences the nature and salience of 'problems with opposi… | LLM 고점이지만 주 screening에서는 positive가 아니다. 성별/연령 일반론 또는 고정관념 위험을 별도 점검해야 한다. |
