# 다음 작업

## 즉시 할 일

1. `MNLFALLM`과 `MNLFA_STRESS`를 계속 분리해서 관리한다.
2. `MNLFALLM/llm-only-clean`을 clean LLM branch로 유지한다. `main`을 덮어쓸지는 별도 결정한다.
3. 현재 prompt template을 고정하고 `prompt_manifest.json`을 작성한다.
4. Gemini `-Resume` 옵션을 사용해 전체 105 item prompt set을 천천히 실행한다.
5. batch가 성공할 때마다 parse/eval을 다시 실행한다.

## 분석 작업

1. 전체 487 item-covariate pair에 대한 final pair registry를 만든다.
2. gold-standard specification을 만든다. label은 다음처럼 분리한다.
   - provisional screen-positive.
   - formal validation-positive.
   - indeterminate.
3. pilot 지표를 full run으로 확장한다.
   - overall AUPRC.
   - by-covariate AUPRC.
   - Precision@5와 Precision@10.
   - top-k case list.
4. false-positive와 false-negative audit table을 만든다.
5. 논문에 넣을 case study 3-4개를 선정한다.

## 논문 작업

1. Maeda & Lu (2025), Li et al. (2024)를 직접 선행연구로 둔다.
2. novelty는 "first LLM-DIF work"가 아니라 "theory-guided hypothesis generation workflow"로 잡는다.
3. claim이 설계에서 벗어나지 않도록 Introduction보다 Methods를 먼저 작성한다.
4. validation gate를 통과하기 전까지 Discussion을 강하게 쓰지 않는다.

## 최소 논문화 기준

다음 중 하나 이상이 충족되면 manuscript draft로 진행한다.

- LLM이 이론적으로 의미 있는 covariate lane에서 keyword baseline보다 낫다.
- LLM top-k candidate 안에 validated DIF example이 포함된다.
- LLM failure mode가 체계적이고 cautionary methods paper로 의미 있다.

다음이면 중단하거나 논문 강도를 낮춘다.

- LLM이 전반적으로 baseline보다 나쁘다.
- false positive가 대부분 generic stereotype이다.
- psychometric validation을 완료할 수 없다.

