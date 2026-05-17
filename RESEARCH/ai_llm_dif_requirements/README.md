# AI 보조 DIF 가설 생성 연구 작업공간

## 작업 아이디어

LLM은 심리척도 문항의 텍스트를 보고, 어떤 item-covariate 조합에서 DIF가 나타날 수 있는지 사전 가설을 만들 수 있을까? 그리고 그 가설은 longitudinal ordinal MNLFA 같은 empirical psychometric model로 검증할 수 있을까?

## 현재 판단

약한 버전은 논문으로 밀기 어렵습니다.

> “LLM에게 MAPS DIF 결과를 설명하게 했다.”

이렇게 가면 너무 post-hoc이고, 표본/문항 수가 작고, 리뷰어가 “그럴듯한 이야기 만들기”라고 보기 쉽습니다.

논문화가 가능한 버전은 이쪽입니다.

> LLM이 문항 의미를 바탕으로 DIF 후보 가설을 사전에 생성하고, 그 후보가 keyword baseline과 empirical DIF/MNLFA 결과를 얼마나 잘 예측하거나 우선순위화하는지 검증한다.

현재 MAPS acculturative-stress 8문항만으로는 독립 논문으로 약합니다. standalone paper를 생각한다면 더 많은 문항, 두 번째 척도, 또는 외부 DIF benchmark가 필요합니다. 다행히 현재 pipeline은 MAPS 여러 척도로 확장되어 105개 item과 487개 item-covariate pair까지 갈 수 있습니다.

## 파일

- `outputs/requirements_report.md`: standalone AI + psychometrics DIF 논문에 필요한 조건.
- `outputs/pipeline_status.md`: 현재 구현된 스크립트와 실행 상태.
- `sources/key_sources.md`: 문헌 anchor와 source note.
- `professor_pitch_llm_dif.md`: 교수님께 설명할 때 사용할 문안.

