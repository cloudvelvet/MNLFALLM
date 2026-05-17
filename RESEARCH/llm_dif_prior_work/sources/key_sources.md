# 주요 선행연구

## 가장 직접적인 자료

1. Li, H., Marchong, C., & Aldib, R. (2024). *The Use of ChatGPT to Facilitate Differential Item Functioning (DIF) Detection*. 25th Midwest Association of Language Testers (MwALT) Conference, work-in-progress poster.
   - URL: https://www.researchgate.net/publication/397039826_The_Use_of_ChatGPT_to_Facilitate_Differential_Item_Functioning_DIF_Detection
   - 관련성: ChatGPT와 인간 평정자가 reading-test item의 DIF 가능성을 사전에 판단하고, 이를 2,000명 이상 응답자료의 empirical `lordif` 결과와 비교했다.
   - 핵심 결과: 인간 평정자, ChatGPT, empirical DIF 분석 간 일치가 약했다. 인간 평정자가 ChatGPT보다 empirical result와 조금 더 잘 맞았다.

2. Maeda, H., & Lu, Y. (2025). *Finding Words Associated with DIF: Predicting Differential Item Functioning Using LLMs and Explainable AI*. Journal of Educational Measurement, 62(4), 883-906.
   - DOI: https://doi.org/10.1111/jedm.70017
   - arXiv: https://arxiv.org/abs/2502.07017
   - 관련성: peer-reviewed 직접 경쟁 연구다. encoder 기반 Transformer/LLM을 fine-tuning해 item text로 empirical DIF를 예측하고, XAI로 DIF 관련 단어를 찾았다.
   - 핵심 결과: focal/reference group pair에 따라 예측 R2가 약 .04-.32였다. 저자들은 DIF 관련 단어 중 상당수가 construct-irrelevant bias가 아니라 legitimate blueprint subdomain을 반영할 수 있다고 해석했다.

## AI/ML + DIF 인접 연구

3. Huang, S., & Ishii, H. (2025). *Enhancing Precision in Predicting Magnitude of Differential Item Functioning: An M-DIF Pretrained Model Approach*. Educational and Psychological Measurement, 85(2), 384-400.
   - DOI: https://doi.org/10.1177/00131644241279882
   - PubMed/PMC: https://pmc.ncbi.nlm.nih.gov/articles/PMC11562883/
   - 관련성: pretrained/XGBoost 접근으로 여러 DIF statistic과 testing-condition indicator를 이용해 DIF magnitude를 추정한다.
   - 차이점: response statistic 기반 DIF magnitude prediction이지, LLM semantic hypothesis generation은 아니다.

4. Belzak, W., Naismith, B., & Burstein, J. (2023/2024). *Ensuring Fairness of Human- and AI-Generated Test Items*.
   - URL: https://www.researchgate.net/publication/372024316_Ensuring_Fairness_of_Human-_and_AI-Generated_Test_Items
   - 관련성: 인간 생성 문항과 AI 생성 문항의 empirical DIF pattern을 비교했다.
   - 차이점: AI-generated item fairness evaluation이지, LLM-generated DIF hypothesis 연구는 아니다.

5. Zeinfeld, L., et al. (2026). *Assessment Design in the AI Era: A Method for Identifying Items Functioning Differentially for Humans and Chatbots*.
   - arXiv: https://arxiv.org/abs/2603.23682
   - DOI: https://doi.org/10.48550/arXiv.2603.23682
   - 관련성: human learner와 chatbot response를 비교하기 위해 DIF analysis를 적용했다.
   - 차이점: chatbot을 focal group처럼 다루는 연구이지, chatbot/LLM이 DIF hypothesis를 생성하는 연구는 아니다.

## LLM + psychometric item development 인접 연구

6. Hommel, B. E., Wollang, F.-J. M., Kotova, V., Zacher, H., & Schmukle, S. C. (2022). *Transformer-Based Deep Neural Language Modeling for Construct-Specific Automatic Item Generation*. Psychometrika.
   - DOI: https://doi.org/10.1007/s11336-021-09823-9
   - URL: https://www.cambridge.org/core/journals/psychometrika/article/transformerbased-deep-neural-language-modeling-for-constructspecific-automatic-item-generation/F65C49BDC77D628D38CB532EC61912CD
   - 관련성: Transformer 기반 automatic item generation을 psychometric validation과 연결했다.
   - 차이점: item generation 연구이지 DIF 연구는 아니다.

7. Franco-Martinez, A., Rey-Saez, R., & Castillejo, I. (2023). *The Seven Wonderings of Large Language Models as Psychometric Designers, Refiners, and Analysts*.
   - OSF: https://osf.io/7kce5/
   - DOI: https://doi.org/10.31234/osf.io/kmqy5
   - 관련성: LLM이 psychometric design, review, response simulation, analysis를 보조할 가능성을 넓게 논의한다.
   - 차이점: conceptual/prompt exploration에 가깝고, empirical DIF validation 연구는 아니다.

8. Feraco, T., & Toffalini, E. (2024/2025). *SEMbeddings: How to Evaluate Model Misfit Before Data Collection Using Large-Language Models*. Frontiers in Psychology.
   - DOI: https://doi.org/10.3389/fpsyg.2024.1433339
   - URL: https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2024.1433339/full
   - 관련성: LLM embedding을 사용해 data collection 전 SEM/CFA model misfit을 사전 점검한다.
   - 차이점: pre-data structural misfit screening이지 DIF 또는 MNLFA 연구는 아니다.

## 전통적/방법론적 DIF 맥락

9. Berger, M., & Tutz, G. (2016). *Detection of Uniform and Nonuniform Differential Item Functioning by Item Focused Trees*. Journal of Educational and Behavioral Statistics.
   - DOI: https://doi.org/10.3102/1076998616659371
   - 관련성: item-focused tree를 통해 covariate 기반 DIF를 설명 가능하게 탐색한다.
   - 차이점: response data 기반 statistical discovery이지 LLM semantic review는 아니다.

10. Hidalgo-Montesinos, M. D., et al. (2020). *Differential Item Functioning Analysis: A Systematic Review of Methods*. Educational Research Review.
    - DOI: https://doi.org/10.1016/j.edurev.2020.100340
    - 관련성: DIF detection 방법이 이미 매우 넓게 발전해 있음을 보여준다.
    - 함의: novelty를 “새로운 DIF detection method”로 잡으면 위험하다. 이 프로젝트는 detection method가 아니라 hypothesis-generation workflow로 포지셔닝해야 한다.

