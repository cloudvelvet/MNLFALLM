# 선행연구 스캔: LLM 보조 DIF 가설 생성

업데이트: 2026-05-17

## 결론부터

이 아이디어가 완전히 빈 땅은 아닙니다. 이미 꽤 가까운 연구가 두 개 있습니다.

1. ChatGPT로 DIF 후보를 판단하게 하고 empirical `lordif` 결과와 비교한 work-in-progress 포스터.
2. item text로 empirical DIF를 예측하고, XAI로 DIF 관련 단어를 찾은 Journal of Educational Measurement 논문.

그래도 우리가 잡은 기여는 아직 남아 있습니다. 핵심은 다음입니다.

> LLM을 DIF 판정기로 쓰는 것이 아니라, 다문화 longitudinal panel item에서 item-covariate DIF 후보 가설을 생성하게 하고, 그 후보를 ordinal DIF/MNLFA-style validation으로 검증하는 workflow를 평가한다.

따라서 안전한 주장은 “아무도 LLM을 DIF에 쓴 적이 없다”가 아닙니다. 그건 틀리거나 적어도 위험합니다. 더 정확한 주장은 이렇습니다.

> LLM/Transformer를 이용한 DIF 예측이나 ChatGPT 기반 item review 연구는 이미 나오기 시작했다. 다만 longitudinal, covariate-rich, ordinal MNLFA-style measurement model 안에서 LLM을 semantic hypothesis-generation layer로 평가한 연구는 아직 제한적이다.

## 직접 선행연구

### Li, Marchong, & Aldib (2024): ChatGPT 기반 DIF 후보 판단

가장 직접적인 선행연구입니다. 이 연구는 여러 ChatGPT 버전과 인간 평정자에게 reading-test item의 gender DIF 여부를 판단하게 하고, 그 판단을 2,000명 이상의 응답자료에 대한 empirical `lordif` 결과와 비교했습니다.

우리에게 중요한 점:

- “LLM as DIF hypothesis generator”와 직접 겹칩니다.
- 인간 평정자, ChatGPT, empirical DIF 결과 사이의 일치도가 약했습니다.
- 인간 평정자가 ChatGPT보다 empirical result와 조금 더 잘 맞았습니다.
- 현재 확인한 형태는 full peer-reviewed paper라기보다 work-in-progress conference poster에 가깝습니다.

함의:

> 우리는 “ChatGPT가 DIF 검토에 쓰일 수 있는지 처음 물었다”고 주장하면 안 됩니다. 대신 더 강한 설계를 가져가야 합니다. 더 많은 item-covariate pair, keyword baseline, psychometric guardrail prompt, covariate-specific error analysis, longitudinal/ordinal MNLFA validation이 차별점입니다.

### Maeda & Lu (2025): item text 기반 LLM/XAI DIF 예측

가장 강한 peer-reviewed 경쟁 논문입니다. Maeda와 Lu는 42,180개의 ELA/수학 문항 텍스트를 사용해 Transformer/LLM 계열 encoder model을 fine-tuning했고, empirical DIF를 예측했습니다. XAI를 이용해 DIF prediction과 관련된 단어도 찾았습니다. 보고된 예측력은 focal/reference group pair에 따라 R2 약 .04-.32였습니다.

우리에게 중요한 점:

- LLM과 DIF를 직접 연결합니다.
- 규모가 크고 peer-reviewed입니다.
- 다만 초점은 conversational LLM의 이론 기반 가설 생성이 아니라 item text 기반 prediction/screening입니다.
- 저자들도 DIF 관련 단어가 construct-irrelevant bias가 아니라 legitimate blueprint subdomain을 반영할 수 있다고 조심스럽게 해석합니다.

함의:

> Maeda & Lu는 반드시 중심 선행연구로 인용해야 합니다. 우리의 위치는 그 연구를 대체하는 것이 아니라 보완하는 것입니다. 우리는 대규모 text-to-DIF prediction이 아니라, substantive longitudinal migration context에서 theory-guided hypothesis generation과 validation을 다룹니다.

## 인접 연구

### ML/pretrained model 기반 DIF magnitude estimation

Huang과 Ishii의 M-DIF pretrained model은 여러 DIF statistic과 testing condition indicator를 사용해 DIF magnitude를 예측합니다. “AI for DIF”라는 점에서는 가깝지만, item text를 읽고 semantic hypothesis를 생성하는 연구는 아닙니다.

### AI-generated item fairness

AI가 만든 문항과 인간이 만든 문항의 DIF pattern을 비교하는 연구들이 있습니다. 이 흐름은 AI 기반 item workflow도 fairness validation이 필요하다는 점을 잘 보여줍니다. 하지만 LLM이 DIF hypothesis를 생성하는 연구는 아닙니다.

### LLM psychometric item generation/review

Transformer/LLM 기반 automatic item generation, item classification, survey drafting, scale development, pre-data model-misfit screening 연구가 빠르게 늘고 있습니다. 그래서 “psychometrics에서 LLM을 처음 쓴다”거나 “LLM item review를 처음 한다”는 식의 주장은 할 수 없습니다.

## novelty가 남는 지점

가장 방어 가능한 novelty는 다음 조합입니다.

1. **LLM as semantic DIF hypothesis generator**: 최종 판정기가 아니라 가설 생성기.
2. **Covariate-rich item-covariate screening**: discrimination, language proficiency, income, age처럼 time-varying 또는 substantive covariate를 다룸.
3. **Latent difference vs measurement DIF confusion**: LLM의 실패 양상을 주요 연구대상으로 삼음.
4. **Ordinal longitudinal/MNLFA-style validation**: 단순 cross-sectional binary DIF가 아니라 longitudinal panel 맥락으로 확장.
5. **Human-in-the-loop workflow**: LLM이 전문가 검토를 대체하는 것이 아니라 검토 우선순위를 정함.

## 위험한 주장

피해야 합니다.

- “LLM을 DIF에 처음 적용했다.”
- “AI 기반 DIF 방법을 처음 제안한다.”
- “LLM이 DIF를 탐지할 수 있다.”
- “LLM이 생성한 DIF 가설은 empirical testing 없이도 타당하다.”
- “LLM score가 높으면 그 문항은 biased item이다.”

## 안전한 주장

쓸 수 있는 표현입니다.

- “최근 연구들은 LLM/Transformer를 DIF prediction과 DIF item review에 사용하기 시작했다.”
- “아직 덜 개발된 부분은 formal DIF testing 전후에 놓일 수 있는 interpretable, theory-guided hypothesis-generation layer다.”
- “본 연구의 초점은 DIF 분석을 대체하는 것이 아니라, 어떤 item-covariate pair를 심리측정적으로 검토할지 우선순위를 정하는 것이다.”
- “중심 기여 중 하나는 LLM이 latent group difference와 measurement-function difference를 혼동하는 실패 양상을 문서화하는 것이다.”

## 논문에 바로 쓸 수 있는 포지셔닝 문단

선행연구는 AI가 문항을 생성하고, 문항 내용을 분류하고, psychometric screening을 보조할 수 있음을 보여주었다. 최근에는 LLM과 Transformer 기반 모형을 사용해 item text로 DIF를 예측하거나 expert DIF review를 보조하려는 연구도 등장했다. 그러나 이들 접근은 주로 LLM을 prediction 또는 review tool로 다룬다. substantive longitudinal panel research에서 LLM이 DIF에 대한 해석 가능하고 이론 기반적인 hypothesis-generation layer로 기능할 수 있는지는 아직 충분히 검토되지 않았다. 본 프로젝트는 MAPS 다문화 패널 자료에서 LLM이 생성한 item-covariate DIF hypothesis를 keyword baseline 및 empirical ordinal DIF/MNLFA-style screening과 비교하고, 특히 LLM이 latent trait difference와 measurement-function difference를 혼동하는 사례에 주목한다.

## 추천 프레이밍

이 아이디어는 여전히 가능성이 있습니다. 다만 “아무도 안 한 연구”가 아니라 **2세대 기여**로 잡아야 합니다.

> 기존 LLM-DIF 연구가 주로 text-to-DIF prediction 또는 소규모 ChatGPT item review에 가까웠다면, 이 연구는 longitudinal, covariate-rich, theory-guided psychometric validation workflow로 확장한다. 또한 LLM의 유용성뿐 아니라 실패 양상까지 분석한다.

