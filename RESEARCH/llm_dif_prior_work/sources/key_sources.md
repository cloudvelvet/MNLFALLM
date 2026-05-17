# Key Sources

## Most Direct Sources

1. Li, H., Marchong, C., & Aldib, R. (2024). *The Use of ChatGPT to Facilitate Differential Item Functioning (DIF) Detection*. 25th Midwest Association of Language Testers (MwALT) Conference, work-in-progress poster.
   - URL: https://www.researchgate.net/publication/397039826_The_Use_of_ChatGPT_to_Facilitate_Differential_Item_Functioning_DIF_Detection
   - Relevance: Directly uses ChatGPT and human raters to hypothesize DIF in reading-test items, then compares with empirical DIF using `lordif` on 2,000+ examinees.
   - Key result: Weak agreement among human raters, ChatGPT, and empirical DIF analyses; human raters aligned slightly better with empirical results than ChatGPT.

2. Maeda, H., & Lu, Y. (2025). *Finding Words Associated with DIF: Predicting Differential Item Functioning Using LLMs and Explainable AI*. Journal of Educational Measurement, 62(4), 883-906.
   - DOI: https://doi.org/10.1111/jedm.70017
   - arXiv: https://arxiv.org/abs/2502.07017
   - Relevance: Peer-reviewed direct competitor. Fine-tunes encoder-based Transformer/LLM models to predict empirical DIF from item text and uses XAI to identify words associated with DIF.
   - Key result: Prediction R2 ranged from .04 to .32 across eight focal/reference group pairs; many DIF-associated words reflected legitimate blueprint subdomains rather than construct-irrelevant bias.

## Adjacent AI/ML + DIF Sources

3. Huang, S., & Ishii, H. (2025). *Enhancing Precision in Predicting Magnitude of Differential Item Functioning: An M-DIF Pretrained Model Approach*. Educational and Psychological Measurement, 85(2), 384-400.
   - DOI: https://doi.org/10.1177/00131644241279882
   - PubMed/PMC: https://pmc.ncbi.nlm.nih.gov/articles/PMC11562883/
   - Relevance: Uses pretrained/XGBoost approach to estimate DIF magnitude from multiple DIF statistics and testing-condition indicators.
   - Distinction: Response-statistic based DIF magnitude prediction, not LLM semantic hypothesis generation.

4. Belzak, W., Naismith, B., & Burstein, J. (2023/2024). *Ensuring Fairness of Human- and AI-Generated Test Items*.
   - URL: https://www.researchgate.net/publication/372024316_Ensuring_Fairness_of_Human-_and_AI-Generated_Test_Items
   - Relevance: Compares empirical DIF patterns for human- and AI-generated test items.
   - Distinction: AI-generated item fairness evaluation, not LLM-generated DIF hypotheses.

5. Zeinfeld, L., et al. (2026). *Assessment Design in the AI Era: A Method for Identifying Items Functioning Differentially for Humans and Chatbots*.
   - arXiv: https://arxiv.org/abs/2603.23682
   - DOI: https://doi.org/10.48550/arXiv.2603.23682
   - Relevance: Applies DIF analysis to compare human learners and chatbot responses.
   - Distinction: Treats chatbots as focal groups in DIF, not as DIF hypothesis generators.

## Adjacent LLM + Psychometric Item Development Sources

6. Hommel, B. E., Wollang, F.-J. M., Kotova, V., Zacher, H., & Schmukle, S. C. (2022). *Transformer-Based Deep Neural Language Modeling for Construct-Specific Automatic Item Generation*. Psychometrika.
   - DOI: https://doi.org/10.1007/s11336-021-09823-9
   - URL: https://www.cambridge.org/core/journals/psychometrika/article/transformerbased-deep-neural-language-modeling-for-constructspecific-automatic-item-generation/F65C49BDC77D628D38CB532EC61912CD
   - Relevance: Transformer-based automatic item generation with psychometric validation.
   - Distinction: Item generation, not DIF.

7. Franco-Martinez, A., Rey-Saez, R., & Castillejo, I. (2023). *The Seven Wonderings of Large Language Models as Psychometric Designers, Refiners, and Analysts*.
   - OSF: https://osf.io/7kce5/
   - DOI: https://doi.org/10.31234/osf.io/kmqy5
   - Relevance: Broad conceptual paper on LLMs assisting psychometric design, review, response simulation, and analysis.
   - Distinction: Conceptual/prompt exploration, not empirical DIF validation.

8. Feraco, T., & Toffalini, E. (2024/2025). *SEMbeddings: How to Evaluate Model Misfit Before Data Collection Using Large-Language Models*. Frontiers in Psychology.
   - DOI: https://doi.org/10.3389/fpsyg.2024.1433339
   - URL: https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2024.1433339/full
   - Relevance: Uses LLM embeddings to pre-screen SEM/CFA model misfit before data collection.
   - Distinction: Pre-data structural misfit screening, not DIF or MNLFA.

## Traditional/Methodological DIF Context

9. Berger, M., & Tutz, G. (2016). *Detection of Uniform and Nonuniform Differential Item Functioning by Item Focused Trees*. Journal of Educational and Behavioral Statistics.
   - DOI: https://doi.org/10.3102/1076998616659371
   - Relevance: Explainable covariate-based DIF discovery via item-focused trees.
   - Distinction: Response-data based statistical discovery, not LLM semantic review.

10. Hidalgo-Montesinos, M. D., et al. (2020). *Differential Item Functioning Analysis: A Systematic Review of Methods*. Educational Research Review.
    - DOI: https://doi.org/10.1016/j.edurev.2020.100340
    - Relevance: Shows DIF detection methods are already extensive; novelty should not be framed as "new DIF detection method" unless very carefully defined.
