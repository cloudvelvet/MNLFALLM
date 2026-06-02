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

# 이론적 배경

## 1. DIF와 측정동일성

차별기능문항(differential item functioning, DIF)은 문항 반응의 집단 차이를 다루는 개념이 아니다. 핵심은 같은 잠재특성 수준에 있는 응답자들이 특정 집단, 시점, 배경 특성에 따라 같은 문항에 다르게 반응하는가이다. 이 점에서 DIF는 측정동일성의 문항 수준 문제다. 집단 간 평균 차이가 커도 문항이 같은 방식으로 작동할 수 있다. 반대로 평균 차이가 작아도 특정 문항은 집단에 따라 다른 측정 기능을 가질 수 있다. DIF 분석은 이 둘을 분리하려는 절차다 (Hidalgo-Montesinos et al., 2020; Columbia University Mailman School of Public Health, n.d.).

이 구분은 다문화 패널 자료에서 더 중요하다. 다문화 청소년과 부모의 응답에는 언어 능력, 차별 경험, 사회경제적 자원, 연령, 성별이 함께 들어온다. 이 변수들은 잠재특성 자체와 관련될 수 있다. 동시에 문항 문장을 이해하고, 사회적 경험을 떠올리고, 응답 범주를 선택하는 과정에도 영향을 줄 수 있다. 측정동일성의 문제는 이 경계에서 생긴다. 어떤 공변량이 실제 구인 수준을 바꾸는가. 어떤 공변량이 같은 구인 수준에서도 문항의 threshold나 부하량을 바꾸는가. 이 질문을 분리하지 않으면 집단 비교의 해석은 쉽게 흔들린다.

DIF는 곧바로 문항 편향이나 불공정성을 뜻하지 않는다. 통계적 DIF는 후속 판단의 출발점이다. 문항 내용, 응답 과정, 구인 정의, 연구 맥락을 함께 검토해야 그 DIF가 construct-irrelevant한 문제인지, 구인과 관련된 정당한 차이인지 판단할 수 있다. Cheng, Chen, Shih(2020)는 DIF 원천을 찾는 작업이 단순한 flag 확인을 넘어 문항 내용과 잠재 원천을 탐색하는 절차가 되어야 함을 보였다. Columbia University의 방법론 안내도 adverse DIF와 benign DIF의 구분에는 통계량만으로 충분하지 않고, 문항 검토와 응답자 이해에 대한 후속 절차가 필요하다고 설명한다 (Cheng et al., 2020; Columbia University Mailman School of Public Health, n.d.).

## 2. 공변량 기반 DIF 모형과 MNLFA

전통적 측정동일성 검정은 흔히 몇 개의 범주형 집단을 비교한다. 그러나 실제 패널 자료의 배경변수는 더 복잡하다. 공변량은 연속형일 수 있고, 시간에 따라 변할 수 있으며, 서로 겹쳐 작동할 수 있다. 다문화청소년패널처럼 연령, 성별, 가구소득, 한국어 능력, 차별 경험을 함께 고려해야 하는 자료에서는 단일 집단 비교만으로 충분하지 않다.

조절 비선형 요인분석(moderated nonlinear factor analysis, MNLFA)은 이 상황에 맞는 측정모형 틀을 제공한다. Curran 등(2014)은 MNLFA가 관측 공변량의 함수로 잠재요인의 평균과 분산뿐 아니라 문항 절편과 부하량의 차이를 모델링할 수 있음을 보였다. 이 구조는 impact와 DIF를 함께 다루게 한다. impact는 공변량에 따른 잠재특성 분포의 차이다. DIF는 같은 잠재특성 수준에서도 문항 함수가 달라지는 현상이다. 두 차이를 한 틀에서 다룰 수 있다는 점이 MNLFA의 장점이다 (Curran et al., 2014).

본 연구가 MNLFA-style validation을 후속 목표로 두는 이유도 여기에 있다. LLM이 제안하는 것은 통계적 결론이 아니다. 문항-공변량 조합에 대한 사전 가설이다. 이 가설은 공변량이 잠재특성에 미치는 영향과 문항 기능에 미치는 영향을 구분할 수 있는 모형 안에서 다시 검토되어야 한다. 특히 한국어 능력이나 차별 경험처럼 구인 수준과 문항 해석 과정을 동시에 흔들 수 있는 변수에서는 이 구분이 분석의 중심이 된다.

## 3. DIF 탐지와 DIF 설명 사이의 간극

DIF 방법론은 탐지 절차를 정교하게 발전시켜 왔다. Hidalgo-Montesinos 등(2020)은 DIF 탐지 방법 연구가 Mantel-Haenszel, logistic regression, SIBTEST, IRT 기반 방법, Rasch 기반 방법 등 여러 흐름으로 확장되어 왔다고 정리했다. 이 문헌은 통계적 탐지가 이미 풍부한 도구 상자를 갖고 있음을 보여준다. 그러나 탐지의 풍부함이 설명의 자동화를 뜻하지는 않는다.

문항이 flag되면 연구자는 다른 질문으로 이동한다. 왜 이 문항인가. 왜 이 공변량인가. 문항 wording에 단서가 있는가. 응답자가 같은 잠재특성을 가지고 있어도 다른 기준으로 응답 범주를 사용할 이유가 있는가. Cheng 등(2020)의 연구는 DIF 원천 확인이 별도의 탐색 문제임을 보여준다. 통계량은 후보를 좁힌다. 원천 해석은 문항 의미와 응답 맥락을 다시 읽는 작업이다 (Cheng et al., 2020).

이 간극이 본 연구의 출발점이다. 대규모 item pool에서는 모든 문항-공변량 조합을 같은 깊이로 검토하기 어렵다. 연구자는 먼저 볼 후보를 골라야 한다. 기존 keyword baseline은 단순하고 재현 가능하지만, 표면 어휘에 묶인다. 예를 들어 차별, 무시, 외국인 같은 단어가 직접 드러나는 문항에서는 강할 수 있다. 그러나 한국어 능력처럼 문항 이해, 사회적 상호작용, 문화적 맥락이 간접적으로 얽힌 경우에는 더 넓은 의미 판단이 필요할 수 있다.

## 4. LLM과 심리측정 문항 연구

LLM과 transformer 계열 모형은 이미 심리측정 연구에 들어와 있다. Hommel 등(2022)은 transformer 기반 언어모형을 construct-specific automatic item generation에 적용했다. 이 연구는 언어모형이 문항 생성과 문항 개발 과정에서 활용될 수 있음을 보였지만, 동시에 psychometric validation과의 연결이 필요함을 전제한다. 문항을 만들 수 있다는 사실은 문항이 좋은 측정도구라는 결론으로 이어지지 않는다 (Hommel et al., 2022).

DIF와 더 가까운 선행연구도 있다. Maeda와 Lu(2025)는 42,180개의 교육평가 문항 텍스트를 사용해 encoder 기반 transformer 모형으로 empirical DIF를 예측하고, explainable AI를 통해 DIF 예측에 관련된 단어를 찾았다. 이 연구는 item text와 DIF 사이의 연결을 직접 다루었다. 다만 초점은 생성형 LLM이 설명 가능한 가설을 만드는 과정이 아니라, item text에서 empirical DIF를 예측하는 supervised modeling에 가깝다. Li, Marchong, Aldib(2024)의 work-in-progress poster는 ChatGPT의 DIF 판단을 empirical `lordif` 결과와 비교했다. 이 사례는 생성형 LLM을 DIF 검토에 사용할 수 있다는 직접 선례지만, 본 연구가 요구하는 종단적이고 공변량이 풍부한 MAPS workflow와는 범위가 다르다 (Maeda & Lu, 2025; Li et al., 2024).

따라서 본 연구의 이론적 위치는 좁다. LLM을 새로운 DIF 검정법으로 세우지 않는다. LLM을 문항 의미와 공변량 의미를 결합하는 hypothesis-generation layer로 둔다. 이 layer의 산출물은 probability, direction, confidence, rationale을 가진 후보 가설이다. 그 가설은 keyword baseline 및 empirical DIF screening과 비교된다. 이 비교를 통해 LLM이 어떤 의미 영역에서 도움이 되는지, 어떤 영역에서 그럴듯한 설명만 만들어내는지 평가한다.

## 5. LLM 사용의 위험과 심리측정 guardrail

LLM의 장점은 곧 위험이다. LLM은 자연스러운 설명을 빠르게 만든다. 그러나 자연스러운 설명은 근거가 아니다. Farquhar 등(2024)은 LLM이 그럴듯하지만 잘못된 답변을 산출할 수 있음을 hallucination 문제로 다루었다. Palmer, Smith, Spirling(2024)은 proprietary language model을 학술연구에 사용할 때 재현성과 감사 가능성 문제가 생기므로 명시적 정당화와 투명성이 필요하다고 주장했다. 이 논의는 본 연구의 설계에도 직접 적용된다. 모형 이름, prompt, parameter, raw response, parsing rule을 남기지 않으면 LLM 결과는 검증 가능한 연구 산출물이 되기 어렵다 (Farquhar et al., 2024; Palmer et al., 2024).

DIF 맥락에서 위험은 더 구체적이다. LLM은 잠재특성 차이를 threshold DIF로 오해할 수 있다. 연령이나 성별처럼 넓은 사회적 설명이 가능한 공변량에서는 문항 wording에 직접 단서가 없어도 plausible rationale을 만들 수 있다. 반대로 empirical DIF가 있지만 표면 의미가 약한 경우에는 낮은 점수를 줄 수 있다. 이 실패 양상은 단순 오류가 아니다. LLM이 의미 기반 추론을 어디서 과도하게 확장하는지 보여주는 자료다.

따라서 본 연구의 guardrail은 세 가지다. 첫째, LLM은 empirical DIF label을 보지 않는다. 둘째, LLM score는 keyword baseline과 비교된다. 셋째, LLM rationale은 DIF 증거가 아니라 후속 검증을 위한 후보로만 해석된다. 이 세 조건이 있어야 LLM은 심리측정 판단을 흐리는 장식이 아니라, 검토 대상을 좁히는 도구가 된다.

## 6. 본 연구의 이론적 모형

본 연구의 기본 모형은 세 층으로 구성된다. 첫째 층은 문항 의미다. 문항 wording, 응답 범주, 구인 정의가 여기에 속한다. 둘째 층은 공변량 의미다. 차별 경험, 한국어 능력, 소득, 연령, 성별이 문항 해석과 어떤 관계를 가질 수 있는지 묻는다. 셋째 층은 심리측정 검증이다. 같은 잠재특성 수준에서 문항 threshold나 loading이 공변량에 따라 달라지는지를 응답자료로 검토한다.

LLM은 첫째 층과 둘째 층 사이에서 작동한다. 문항 의미와 공변량 의미를 결합해 후보 메커니즘을 만든다. 그러나 셋째 층으로 넘어갈 권한은 없다. empirical screening과 MNLFA-style validation이 그 권한을 가진다. 이 분업이 본 연구의 이론적 핵심이다. LLM은 의미를 읽는다. 심리측정 모형은 측정 기능을 검증한다. 연구자는 둘 사이의 일치와 불일치를 해석한다.

이 틀에서 예상되는 결과도 분명하다. 차별 경험처럼 문항에 직접 어휘 단서가 있는 공변량에서는 keyword baseline도 강할 수 있다. 한국어 능력처럼 의미 연결이 더 간접적인 공변량에서는 LLM이 추가 가치를 보일 수 있다. 연령처럼 넓은 서사를 만들기 쉬운 공변량에서는 false positive가 늘 수 있다. 이 대비는 LLM의 성공과 실패를 동시에 평가하게 한다. 좋은 결과는 LLM이 모든 DIF를 잘 맞히는 것이 아니다. 좋은 결과는 LLM이 어느 조건에서 유용하고, 어느 조건에서 위험한지 분명히 드러내는 것이다.

## 참고문헌

Cheng, C.-P., Chen, C.-C., & Shih, C.-L. (2020). An exploratory strategy to identify and define sources of differential item functioning. *Applied Psychological Measurement*, 44(7-8), 548-560. https://doi.org/10.1177/0146621620931190

Columbia University Mailman School of Public Health. (n.d.). Differential item functioning. https://www.publichealth.columbia.edu/research/population-health-methods/differential-item-functioning

Curran, P. J., McGinley, J. S., Bauer, D. J., Hussong, A. M., Burns, A., Chassin, L., Sher, K., & Zucker, R. (2014). A moderated nonlinear factor model for the development of commensurate measures in integrative data analysis. *Multivariate Behavioral Research*, 49(3), 214-231. https://doi.org/10.1080/00273171.2014.889594

Farquhar, S., Kossen, J., Kuhn, L., & Gal, Y. (2024). Detecting hallucinations in large language models using semantic entropy. *Nature*, 630, 625-630. https://doi.org/10.1038/s41586-024-07421-0

Hidalgo-Montesinos, M. D., et al. (2020). Developments and trends in research on methods of detecting differential item functioning. *Educational Research Review*. https://doi.org/10.1016/j.edurev.2020.100340

Hommel, B. E., Wollang, F.-J. M., Kotova, V., Zacher, H., & Schmukle, S. C. (2022). Transformer-based deep neural language modeling for construct-specific automatic item generation. *Psychometrika*, 87, 749-772. https://doi.org/10.1007/s11336-021-09823-9

Li, H., Marchong, C., & Aldib, R. (2024). *The use of ChatGPT to facilitate differential item functioning (DIF) detection*. 25th Midwest Association of Language Testers Conference, work-in-progress poster. https://www.researchgate.net/publication/397039826_The_Use_of_ChatGPT_to_Facilitate_Differential_Item_Functioning_DIF_Detection

Maeda, H., & Lu, Y. (2025). Finding words associated with DIF: Predicting differential item functioning using LLMs and explainable AI. *Journal of Educational Measurement*, 62(4), 883-906. https://doi.org/10.1111/jedm.70017

Palmer, A., Smith, N. A., & Spirling, A. (2024). Using proprietary language models in academic research requires explicit justification. *Nature Computational Science*, 4, 2-3. https://www.nature.com/articles/s43588-023-00585-1

