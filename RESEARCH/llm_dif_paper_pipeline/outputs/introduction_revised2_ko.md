# 1. 서론

집단과 시점을 비교하는 연구는 측정도구가 같은 의미로 작동한다는 전제 위에 선다. 이 전제가 약하면 평균 차이도, 성장 차이도, 예측 경로의 차이도 흔들린다. 다문화 청소년과 부모를 장기간 추적하는 패널 자료에서는 이 문제가 더 날카롭다. 한국어 능력, 차별 경험, 가구소득, 성별, 연령은 응답자의 삶을 구성하는 조건인 동시에 문항을 읽고 해석하고 응답하는 조건이다. 따라서 관찰된 점수 차이가 잠재특성의 차이인지, 문항이 특정 응답자에게 다르게 작동한 결과인지 분리해야 한다. 이것이 측정동일성과 차별기능문항(differential item functioning, DIF)의 문제다(Meredith, 1993; Vandenberg & Lance, 2000).

DIF는 동일한 잠재특성 수준에 있는 응답자가 집단이나 공변량에 따라 특정 문항에 다르게 반응하는 현상을 가리킨다. 이때 중요한 구분은 impact와 DIF의 구분이다. Impact는 공변량에 따른 잠재특성 분포의 실제 차이다. DIF는 같은 잠재특성 수준에서도 문항 기능이 달라지는 현상이다. 이 구분을 놓치면 연구자는 실제 차이를 측정 오류로 읽거나, 측정 기능의 차이를 실질적 차이로 해석할 수 있다. 특히 문화적응 스트레스, 이중문화수용, 자아존중감처럼 사회적 경험과 자기해석이 문항 의미에 깊게 관여하는 구인에서는 이 위험이 작지 않다.

심리측정 연구는 DIF를 탐지하기 위한 풍부한 방법을 발전시켜 왔다. Mantel-Haenszel 절차, 로지스틱 회귀, 문항반응이론 기반 방법, 요인분석 기반 방법은 모두 조건부 문항 반응 차이를 포착하기 위한 도구다(Millsap & Everson, 1993; Hidalgo-Montesinos et al., 2020). 여러 배경변수가 동시에 작동하는 자료에서는 조절 비선형 요인분석(moderated nonlinear factor analysis, MNLFA)이 특히 유용한 틀을 제공한다. MNLFA는 잠재요인의 평균과 분산에 대한 공변량 효과와 문항 절편, threshold, 부하량에 대한 공변량 효과를 같은 모형 안에서 다룰 수 있다(Curran et al., 2014; Bauer, 2017; Bauer et al., 2020). 즉 공변량이 잠재특성에 미치는 영향과 문항 기능에 미치는 영향을 한 framework 안에서 구분할 수 있다.

그러나 통계적 탐지는 해석을 끝내지 않는다. DIF flag는 어떤 문항을 검토해야 하는지 알려주지만, 왜 그런 차이가 나타났는지는 따로 물어야 한다. 그 차이가 문항 wording의 문제인지, 응답 과정의 차이인지, 구인과 관련된 정당한 내용 차이인지, 또는 실제 비교 결론을 왜곡할 만큼 큰지는 별도의 판단이 필요하다. DIF는 문항 편향이나 불공정성의 자동 판정이 아니다(Ackerman, 1992; Clauser & Mazor, 1998). Cheng, Chen, Shih(2020)가 보인 것처럼 DIF 원천 탐색은 통계적 detection 이후의 부수 작업이 아니라, 문항 내용과 가능한 원인을 함께 검토하는 독립된 연구 과제다.

여기서 병목이 생긴다. 문항 수가 늘고 공변량이 늘면 검토해야 할 문항-공변량 조합은 빠르게 불어난다. 모든 조합을 전문가가 같은 깊이로 읽고 가능한 DIF 메커니즘을 정리하기는 어렵다. 단순 keyword 접근은 직접적인 표면 단서에는 강하다. 차별, 무시, 외국인, 언어 같은 단어가 문항에 드러나면 관련 공변량과의 연결을 빨리 찾을 수 있다. 그러나 모든 DIF 후보가 그런 식으로 드러나지는 않는다. 한국어 능력처럼 문항 이해, 사회적 상호작용, 문화적 맥락을 통해 간접적으로 작동할 수 있는 공변량은 표면 단어만으로 포착하기 어렵다. 따라서 대량의 문항-공변량 조합에서 해석 가능한 후보 가설을 재현 가능하게 생성하는 절차가 필요하다.

대규모 언어모형(large language model, LLM)은 이 절차의 후보가 될 수 있다. LLM은 문항 문장, 구인 설명, 응답 범주, 공변량 정의를 함께 읽고 그 사이의 의미적 연결을 생성하도록 요청될 수 있다. 이 능력은 DIF 판정이 아니라 사전 triage에 적합하다. LLM이 empirical DIF 결과를 보지 않은 상태에서 각 문항-공변량 조합의 threshold DIF 가능성, 예상 방향, 판단 근거를 제시한다면, 연구자는 후속 ordinal DIF 또는 MNLFA-style validation의 우선순위를 정할 수 있다. 이때 LLM의 출력은 증거가 아니라 검증할 가설이다.

관련 선행연구는 이미 이 방향의 일부를 열었다. Transformer 기반 언어모형은 심리측정 문항 생성과 검토에 사용되기 시작했다(Hommel et al., 2022; Attali et al., 2022). AI가 생성한 문항도 인간이 만든 문항과 마찬가지로 fairness와 DIF 검토를 필요로 한다는 연구도 등장했다(Belzak et al., 2023). DIF와 더 직접적으로 연결된 연구로 Maeda와 Lu(2025)는 encoder 기반 transformer 모형으로 문항 텍스트에서 empirical DIF를 예측하고, explainable AI로 DIF 관련 단어를 탐색했다. Li, Marchong, Aldib(2024)는 ChatGPT 판단을 empirical `lordif` 결과와 비교한 work-in-progress 연구를 제시했다. 따라서 본 연구는 LLM을 DIF에 처음 적용하는 연구가 아니다. 본 연구의 초점은 더 좁다. 생성형 LLM의 rationale-bearing output을 다문화 패널 자료의 문항-공변량 단위에서 blind hypothesis로 만들고, keyword baseline 및 empirical screening과 나란히 비교하는 것이다.

이 접근에는 강한 guardrail이 필요하다. LLM은 자연스러운 설명을 빠르게 만든다. 그 설명은 유용한 단서일 수 있지만 심리측정 근거는 아니다. 모형은 잠재특성 차이를 문항 기능 차이처럼 말할 수 있고, 문항에 직접 단서가 없어도 연령이나 성별에 대해 그럴듯한 서사를 만들 수 있다. 반대로 empirical DIF가 있어도 표면 의미가 약하면 낮은 점수를 줄 수 있다. LLM 연구 일반에서도 hallucination, 폐쇄형 모델의 재현성, 감사 가능성 문제가 꾸준히 제기되어 왔다(Farquhar et al., 2024; Palmer et al., 2024). 따라서 LLM-DIF workflow는 empirical label을 숨긴 상태의 생성, prompt와 raw response 보존, baseline 비교, 후속 심리측정 검증을 기본 조건으로 삼아야 한다.

본 연구는 다문화청소년패널(Multicultural Adolescents Panel Study, MAPS)의 문항을 사용해 이러한 workflow를 시험한다. 분석 단위는 문항-공변량 조합이다. Gemini 모형은 각 조합에 대해 문항 문장, 구인 맥락, 응답 범주, 공변량 정의를 입력받고 threshold DIF 가능성, 예상 방향, 확신도, rationale을 산출한다. 이 산출물은 keyword baseline 및 provisional ordinal DIF screening 결과와 비교된다. 평가는 최종 분류 정확도가 아니라 ranking utility에 초점을 둔다. 핵심 질문은 LLM이 모든 DIF를 맞히는가가 아니다. 연구자와 psychometrician이 먼저 검토해야 할 후보를 더 앞쪽에 놓는가이다.

본 연구는 네 가지 질문을 다룬다. 첫째, LLM은 empirical DIF 결과를 보지 않은 상태에서 문항-공변량 조합별 DIF 후보 가설을 구조화된 형태로 생성할 수 있는가. 둘째, LLM의 가능성 점수는 keyword baseline보다 provisional empirical DIF 후보를 더 잘 우선순위화하는가. 셋째, 이 유용성은 공변량의 성격에 따라 달라지는가. 특히 차별 경험, 한국어 능력, 가구소득, 연령, 성별은 서로 다른 의미 연결과 오류 가능성을 가진다. 넷째, LLM은 어디서 실패하는가. 특히 잠재특성 차이와 문항 기능 차이의 경계에서 어떤 혼동을 보이는가.

이 논문의 기여는 새로운 DIF 검정법이 아니라 검증 앞단의 가설 생성 workflow다. LLM은 문항과 공변량 사이의 의미적 연결을 읽도록 설계되고, keyword baseline은 그 연결이 단순 표면 단어로 설명되는지 점검하는 비교 기준이 된다. Ordinal DIF screening과 후속 MNLFA-style validation은 그 가설이 실제 측정 기능 차이와 연결되는지 평가한다. 이 분업 안에서 LLM의 가치는 답을 내리는 데 있지 않다. 검토 순서를 좁히고, 성공과 실패의 조건을 통해 의미 기반 추론이 심리측정 검증과 어디서 만나고 어디서 어긋나는지 보여주는 데 있다.

## 참고문헌 후보

Ackerman, T. A. (1992). A didactic explanation of item bias, item impact, and item validity from a multidimensional perspective. *Journal of Educational Measurement*, 29, 67-91. https://doi.org/10.1111/j.1745-3984.1992.tb00368.x

Attali, Y., Runge, A., LaFlair, G. T., Yancey, K., Goodwin, S., Park, Y., & von Davier, A. A. (2022). The interactive reading task: Transformer-based automatic item generation. *Frontiers in Artificial Intelligence*, 5, 903077. https://doi.org/10.3389/frai.2022.903077

Bauer, D. J. (2017). A more general model for testing measurement invariance and differential item functioning. *Psychological Methods*, 22(3), 507-526. https://doi.org/10.1037/met0000077

Bauer, D. J., Belzak, W. C. M., & Cole, V. T. (2020). Simplifying the assessment of measurement invariance over multiple background variables: Using regularized moderated nonlinear factor analysis to detect differential item functioning. *Structural Equation Modeling: A Multidisciplinary Journal*, 27(1), 43-55. https://doi.org/10.1080/10705511.2019.1642754

Belzak, W. C. M., Naismith, B., & Burstein, J. (2023). Ensuring fairness of human- and AI-generated test items. In *Artificial Intelligence in Education* (CCIS 1831, pp. 701-707). https://doi.org/10.1007/978-3-031-36336-8_108

Cheng, C.-P., Chen, C.-C., & Shih, C.-L. (2020). An exploratory strategy to identify and define sources of differential item functioning. *Applied Psychological Measurement*, 44(7-8), 548-560. https://doi.org/10.1177/0146621620931190

Clauser, B. E., & Mazor, K. M. (1998). Using statistical procedures to identify differentially functioning test items. *Educational Measurement: Issues and Practice*, 17(1), 31-44. https://doi.org/10.1111/j.1745-3992.1998.tb00619.x

Curran, P. J., McGinley, J. S., Bauer, D. J., Hussong, A. M., Burns, A., Chassin, L., Sher, K., & Zucker, R. (2014). A moderated nonlinear factor model for the development of commensurate measures in integrative data analysis. *Multivariate Behavioral Research*, 49(3), 214-231. https://doi.org/10.1080/00273171.2014.889594

Farquhar, S., Kossen, J., Kuhn, L., & Gal, Y. (2024). Detecting hallucinations in large language models using semantic entropy. *Nature*, 630, 625-630. https://doi.org/10.1038/s41586-024-07421-0

Hidalgo-Montesinos, M. D., et al. (2020). Developments and trends in research on methods of detecting differential item functioning. *Educational Research Review*. https://doi.org/10.1016/j.edurev.2020.100340

Hommel, B. E., Wollang, F.-J. M., Kotova, V., Zacher, H., & Schmukle, S. C. (2022). Transformer-based deep neural language modeling for construct-specific automatic item generation. *Psychometrika*, 87, 749-772. https://doi.org/10.1007/s11336-021-09823-9

Li, H., Marchong, C., & Aldib, R. (2024). *The use of ChatGPT to facilitate differential item functioning (DIF) detection*. 25th Midwest Association of Language Testers Conference, work-in-progress poster. https://www.researchgate.net/publication/397039826_The_Use_of_ChatGPT_to_Facilitate_Differential_Item_Functioning_DIF_Detection

Maeda, H., & Lu, Y. (2025). Finding words associated with DIF: Predicting differential item functioning using LLMs and explainable AI. *Journal of Educational Measurement*, 62(4), 883-906. https://doi.org/10.1111/jedm.70017

Meredith, W. (1993). Measurement invariance, factor analysis and factorial invariance. *Psychometrika*, 58, 525-543. https://doi.org/10.1007/BF02294825

Millsap, R. E., & Everson, H. T. (1993). Methodology review: Statistical approaches for assessing measurement bias. *Applied Psychological Measurement*, 17(4), 297-334. https://doi.org/10.1177/014662169301700401

Palmer, A., Smith, N. A., & Spirling, A. (2024). Using proprietary language models in academic research requires explicit justification. *Nature Computational Science*, 4, 2-3. https://doi.org/10.1038/s43588-023-00585-1

Vandenberg, R. J., & Lance, C. E. (2000). A review and synthesis of the measurement invariance literature: Suggestions, practices, and recommendations for organizational research. *Organizational Research Methods*, 3(1), 4-70. https://doi.org/10.1177/109442810031002
