# 주요 문헌 메모

## 직접 DIF + AI anchor

Maeda와 Lu(2025)는 현재 가장 가까운 직접 선행연구다. 이들은 42,180개 평가 문항의 item text를 사용해 Transformer 기반 LLM을 fine-tuning하고, empirical DIF를 예측했다. 또한 explainable AI로 DIF와 관련된 단어를 식별했다.

따라서 novelty를 단순히 “LLM이 item text로 DIF를 예측한다”로 잡으면 안 된다. MAPS 논문은 더 구체적인 기여가 필요하다. 예를 들어 longitudinal psychometric validation, prompt robustness, bilingual item wording, mechanism-constrained hypothesis generation 같은 방향이 더 방어 가능하다.

- Maeda, H., & Lu, Y. (2025). Finding Words Associated with DIF: Predicting Differential Item Functioning Using LLMs and Explainable AI. Journal of Educational Measurement, 62(4), 883-906.  
  https://doi.org/10.1111/jedm.70017
- Source page: https://experts.umn.edu/en/publications/finding-words-associated-with-dif-predicting-differential-item-fu/

## LLMs in psychometrics and assessment

Brickman, Gupta, and Oltmanns(2025)는 psychological assessment에서 LLM을 사용할 때 validation, bias, privacy, generalizability가 핵심 제약이라고 정리한다.

- https://doi.org/10.1177/25152459251343582

Hommel et al.(2022)은 transformer 기반 language model이 construct-specific automatic item generation을 도울 수 있음을 보였다. 다만 이런 모델의 역할은 item author를 보조하는 것이지 psychometric validation을 대체하는 것이 아니다.

- https://doi.org/10.1007/s11336-021-09823-9

Rios(2026)는 LLM이 item-writing efficiency를 높일 수 있지만, SME review, revision, psychometric evaluation을 대체하지는 못한다고 본다.

- https://doi.org/10.1080/08957347.2026.2655640

## DIF, content review, fairness framing

Suk and Han(2024)은 DIF 논리를 algorithmic fairness로 확장해 “differential algorithmic functioning”을 제안한다. psychometric measurement bias와 AI fairness를 연결할 때 참고할 수 있다.

- https://doi.org/10.3102/10769986231171711

Kraus, Wild, and Hilbert(2024)는 interpretable machine learning과 psychometric modeling을 결합해 test unfairness를 탐색했다. ML 보조 psychometric bias interpretation의 가까운 선행연구다.

- https://doi.org/10.1177/01466216241238744

Pohl, Schulze, and Stets(2021)는 partial invariance와 anchor selection에서 통계만으로는 부족하고 substantive item-content judgment가 필요하다고 강조한다.

- https://doi.org/10.1177/01466216211042809

## LLM 사용 시 주의할 문헌

Palmer, Smith, and Spirling(2024)은 학술연구에서 proprietary language model을 사용할 경우 closed model이 reproducibility와 auditability 문제를 만든다고 지적한다. 따라서 왜 이런 모델을 써야 하는지 명시해야 한다.

- https://www.nature.com/articles/s43588-023-00585-1

Grundy et al.(2024)은 과학 연구에서 LLM을 사용할 때 transparency, journal-policy compliance, privacy protection, overreliance 방지가 필요하다고 정리한다.

- https://doi.org/10.1371/journal.pcbi.1011767

Farquhar et al.(2024)은 hallucination/confabulation이 여전히 중요한 문제라고 보고, semantic entropy를 탐지 접근 중 하나로 제안한다.

- https://doi.org/10.1038/s41586-024-07421-0

Bender et al.(2021)은 fluent LLM output을 grounded understanding으로 착각하면 안 된다는 고전적 경고로 남아 있다.

- https://doi.org/10.1145/3442188.3445922

