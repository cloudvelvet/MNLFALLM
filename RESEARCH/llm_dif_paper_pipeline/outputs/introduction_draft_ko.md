# 서론 초안

차별기능문항(differential item functioning, DIF)은 집단 비교의 타당성을 흔든다. 한 척도가 여러 집단, 여러 시점, 여러 사회적 위치에서 같은 잠재특성을 재고 있는 것처럼 보일 수 있다. 그러나 특정 문항이 어떤 응답자에게는 다른 방식으로 작동한다면, 관찰된 집단 차이는 두 층위의 차이를 함께 품게 된다. 하나는 잠재특성의 실제 차이다. 다른 하나는 문항의 측정 기능 차이다. 측정동일성은 바로 이 경계를 지키는 문제다. 다문화 패널 자료에서는 경계가 더 쉽게 흐려진다. 한국어 능력, 차별 경험, 가구소득, 성별, 연령은 응답자가 문항 문장을 읽고 해석하고 선택지에 닿는 방식을 바꿀 수 있다.

심리측정 연구는 DIF를 탐지하기 위한 많은 도구를 갖고 있다. 로지스틱 회귀, 문항반응이론, 요인분석 기반 접근, tree 기반 탐색, 여러 공변량을 함께 다루는 확장 모형은 모두 잠재특성을 조건화한 뒤에도 문항 반응이 달라지는지를 묻는다. 특히 조절 비선형 요인분석(moderated nonlinear factor analysis, MNLFA)은 여러 배경변수가 동시에 작동하는 자료에서 유용하다. 이 모형은 잠재요인의 평균과 분산에 대한 영향, 문항 절편과 부하량의 DIF를 하나의 측정 틀 안에서 함께 다룰 수 있다. 이런 모형은 필요하다. 그러나 충분하지는 않다. 어떤 문항이 후보로 걸러진 뒤에도 연구자는 다시 물어야 한다. 이 신호는 어떤 실질적 메커니즘에서 나왔는가. 그 메커니즘은 문항 내용과 맞는가. 통계적 신호는 측정 비동일성인가, 아니면 잠재특성의 실제 차이인가.

이 두 번째 작업은 대개 더 느리다. 통계적 선별은 문항-공변량 조합(item-covariate pair)의 계수 표를 내놓을 수 있다. 그러나 그 표만으로는 한국어 관련 문항이 언어적으로 더 무거운지, 차별 경험 문항이 차별 경험 공변량과 지나치게 겹치는지, 연령 효과가 반응양식인지 발달 맥락인지 구인 관련 차이인지 말해주지 않는다. DIF의 원천을 찾는 선행연구는 이 설명 단계를 문항 내용, 응답 과정, 전문가 판단의 문제로 다루어 왔다. 이 판단은 심리측정 타당화의 핵심이다. DIF는 곧바로 불공정성을 뜻하지 않는다. 같은 이유로, 이 판단은 병목이 된다. 문항 수와 공변량 수가 늘어나면 연구자가 손으로 읽어야 할 문항-공변량 조합은 빠르게 불어난다.

대규모 언어모형(large language model, LLM)은 이 병목에서 제한된 가능성을 만든다. LLM은 문항 문장, 구인 정의, 공변량 설명을 읽고, 결과 label을 보지 않은 상태에서 어떤 문항-공변량 조합을 먼저 심리측정적으로 검토할지 제안할 수 있다. 이 위치에서 LLM은 의미 기반 triage 도구가 된다. 핵심 질문은 단순하다. 같은 잠재특성 수준에 있는 응답자라도, 특정 배경 특성을 가진 응답자가 그 문항을 다른 경로로 승인하게 되는가. LLM의 출력은 방향, 확신도, 근거를 갖춘 후보 가설이어야 한다. 그 가설은 응답자료 앞에서 다시 검증되어야 한다.

최근 연구는 이 질문을 피할 수 없게 만들었고, 동시에 이 연구가 주장할 수 있는 범위를 좁혔다. LLM과 transformer 계열 모형은 이미 심리측정 문항 생성, 문항 검토, 자료 수집 전 모형 부적합 탐색에 들어와 있다. DIF 연구에서도 직접적인 선행 사례가 있다. Maeda와 Lu(2025)는 encoder 기반 transformer 모형으로 문항 텍스트에서 empirical DIF를 예측하고, explainable AI 방법으로 DIF 예측과 관련된 단어를 찾았다. Li, Marchong, Aldib(2024)의 work-in-progress poster는 ChatGPT의 DIF 판단을 reading-test 문항의 empirical `lordif` 결과와 비교했다. 따라서 이 연구는 LLM을 DIF에 처음 적용한다고 주장할 수 없다. 남는 질문은 더 좁고 더 까다롭다. 생성형 LLM이 종단적이고, 다문화적이며, 여러 공변량이 얽힌 측정 장면에서 해석 가능한 DIF 가설 생성층으로 작동할 수 있는가. 그리고 그 의미 판단은 단순한 keyword cue를 넘어서는 정보를 주는가.

여기서 핵심은 의미적 그럴듯함과 심리측정 근거 사이의 거리다. LLM은 이유를 잘 만든다. 문항에 실제 언어적 단서나 문화적 단서가 있을 때, 그 능력은 도움이 된다. 동시에 위험하다. 모형은 잠재특성의 차이를 문항 threshold DIF처럼 말할 수 있다. 문항 wording에 threshold 수준의 메커니즘이 없는데도 연령, 성별, 소득에 대해 사회적으로 그럴듯한 이야기를 붙일 수 있다. 구인과 관련된 내용을 편향처럼 다룰 수 있다. 설명이라는 형식 아래 고정관념을 키울 수도 있다. 이런 위험은 부록으로 밀어둘 수 없다. 이 위험이 연구문제의 일부다. 따라서 방어 가능한 workflow는 LLM에게 empirical DIF label을 숨기고, 단순 baseline과 비교하고, prompt와 raw response를 보존하고, 모든 LLM rationale을 DIF 증거로 쓰지 않고 검증 대기 중인 후보로 취급해야 한다.

본 연구는 다문화청소년패널(Multicultural Adolescents Panel Study, MAPS)의 문항을 사용해 그런 workflow를 구성하고 시험한다. 분석 단위는 문항-공변량 조합이다. 각 조합에 대해 Gemini 모형은 문항 문장, 구인 맥락, 응답 범주, 공변량 정의를 입력받는다. 모형은 threshold DIF 가능성, 예상 방향, 확신도, 짧은 rationale을 산출한다. 이 예측은 keyword baseline 및 provisional ordinal DIF screening 결과와 비교된다. 평가는 단순 정확도보다 ranking utility에 초점을 둔다. average precision, 상위 후보의 precision, 공변량별 성능이 핵심 지표다. 이 설정은 연구의 실제 용도와 맞다. 연구자와 psychometrician이 먼저 읽어야 할 후보 목록을 줄이는 것이다.

연구질문은 네 가지다. 첫째, LLM은 empirical DIF 결과를 보지 않은 상태에서 MAPS 문항의 문항-공변량 조합에 대해 구조화되고 parse 가능한 DIF 가설을 생성할 수 있는가. 둘째, LLM의 가능성 점수는 keyword baseline보다 provisional empirical DIF 조합을 더 잘 우선순위화하는가. 셋째, 그 유용성은 공변량에 따라 달라지는가. 특히 차별 경험, 한국어 능력, 가구소득, 연령, 성별에서 어떤 차이가 나타나는가. 넷째, LLM은 어디서 실패하는가. 특히 잠재특성 차이와 문항 threshold DIF의 경계에서 어떤 혼동을 보이는가.

현재 pilot 결과는 조심스럽지만 연구를 계속할 이유를 준다. 완료된 24개 pilot item에서 Gemini workflow는 109개의 parse 가능한 문항-공변량 예측을 만들었다. 이 중 32개 조합이 provisional ordinal DIF screening에서 positive였다. LLM의 전체 average precision은 0.505였고, keyword baseline은 0.453이었다. 상위 10개 LLM 후보 중 7개가 provisional positive였다. 이 차이는 압도적이지 않다. 그러나 triage 도구로서는 의미가 있다.

패턴은 고르지 않았다. 한국어 능력(`korean_c`)에서는 LLM이 keyword baseline보다 뚜렷하게 나았다. 이는 단순 표면 단어보다 넓은 수준에서 언어 능력과 문항 해석의 연결을 포착했을 가능성을 보여준다. 차별 경험(`discrim_any`)에서는 LLM과 keyword baseline이 모두 비교적 강했다. 차별, 편견, 무시와 같은 단어가 문항에 직접 드러나는 경우 단순 lexical cue도 강력한 경쟁 기준이 된다. 연령(`age_c`)에서는 LLM ranking이 약했다. 모형은 발달적 설명을 잘 만들었지만, 그 설명은 empirical DIF와 잘 맞지 않았다. scale 수준에서는 청소년 문화적응 스트레스와 이중문화수용 문항에서 신호가 강했고, 부모 자아존중감과 부모 문화적응 스트레스에서는 약했다. 방향 예측도 아직 안정적이지 않았다. 모형은 후보를 위로 올리는 일에는 어느 정도 쓸모가 있었지만, DIF 계수의 empirical sign까지 안정적으로 맞혔다고 보기는 어렵다.

따라서 이 논문의 기여는 방법론적이며 진단적이다. 생성형 LLM을 formal DIF analysis의 앞단에 배치해 blind hypothesis를 만들고, 그 출력을 keyword baseline 및 empirical screening과 나란히 비교하는 workflow를 제안한다. 어떤 측정 주장도 empirical validation 없이는 올려보내지 않는다. 이 workflow에서 LLM의 가치는 연구자가 다음에 무엇을 검토해야 하는지 좁혀주는 데 있다. 그 오류 역시 자료가 된다. 오류는 의미 추론이 심리측정 근거 없이 어디까지 미끄러질 수 있는지 보여준다.

## 참고문헌 검증 메모

- Cheng, C.-P., Chen, C.-C., & Shih, C.-L. (2020). An exploratory strategy to identify and define sources of differential item functioning. *Applied Psychological Measurement*, 44(7-8), 548-560. https://doi.org/10.1177/0146621620931190
- Curran, P. J., McGinley, J. S., Bauer, D. J., Hussong, A. M., Burns, A., Chassin, L., Sher, K., & Zucker, R. (2014). A moderated nonlinear factor model for the development of commensurate measures in integrative data analysis. *Multivariate Behavioral Research*, 49(3), 214-231. https://doi.org/10.1080/00273171.2014.889594
- Hidalgo-Montesinos, M. D., et al. (2020). Developments and trends in research on methods of detecting differential item functioning. *Educational Research Review*. https://doi.org/10.1016/j.edurev.2020.100340
- Hommel, B. E., Wollang, F.-J. M., Kotova, V., Zacher, H., & Schmukle, S. C. (2022). Transformer-based deep neural language modeling for construct-specific automatic item generation. *Psychometrika*, 87, 749-772. https://doi.org/10.1007/s11336-021-09823-9
- Maeda, H., & Lu, Y. (2025). Finding words associated with DIF: Predicting differential item functioning using LLMs and explainable AI. *Journal of Educational Measurement*, 62(4), 883-906. https://doi.org/10.1111/jedm.70017
- Palmer, A., Smith, N. A., & Spirling, A. (2024). Using proprietary language models in academic research requires explicit justification. *Nature Computational Science*, 4, 2-3. https://www.nature.com/articles/s43588-023-00585-1
