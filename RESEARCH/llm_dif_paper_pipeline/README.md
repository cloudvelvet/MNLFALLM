# LLM-DIF 논문 파이프라인

프로젝트: MAPS 다문화 패널 자료를 활용한 LLM 보조 DIF 가설 생성 연구.

이 폴더는 현재 LLM-DIF 파일럿을 실제 논문 작업으로 이어가기 위한 파이프라인 문서입니다. 핵심 원칙은 다음입니다.

> LLM은 DIF 판정기가 아니라 가설 생성기다. 실질적인 DIF 주장은 반드시 심리측정 모형으로 검증되어야 한다.

## 주요 문서

- `outputs/llm_dif_paper_pipeline.md`: 연구 설계부터 논문화까지 이어지는 전체 파이프라인.
- `outputs/paper_outline.md`: 논문 구조와 섹션별 작성 계획.
- `outputs/validation_gates.md`: 리뷰어 대응용 검증 게이트와 금지 주장.
- `outputs/next_actions.md`: 당장 실행할 작업 체크리스트.

## 고정 프레이밍

이렇게 주장하지 않는다.

- "LLM이 DIF를 탐지한다."
- "LLM이 편향 문항을 식별한다."
- "LLM이 DIF의 실제 원인을 설명한다."

대신 이렇게 말한다.

- "LLM은 DIF 후보 가설을 생성한다."
- "LLM 출력은 후속 심리측정 검증이 필요한 item-covariate 조합의 우선순위를 정하는 데 사용된다."
- "본 연구는 LLM rationale이 empirical DIF evidence와 언제 일치하고 언제 어긋나는지 평가한다."

