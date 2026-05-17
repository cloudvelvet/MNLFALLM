# MAPS LLM-DIF 파이프라인 상태

## 구현된 파일

- `maps_multiscale_llm_prep.R`
  - MAPS parent/youth 다중 척도 item pool을 만든다.
  - long item-response data, item catalog, LLM prediction template을 출력한다.

- `maps_llm_dif_gold_screen.R`
  - 빠른 ordinal-logit DIF screening을 실행한다.
  - item별 leave-one-item-out scale mean proxy, covariate effect, wave adjustment를 사용한다.
  - 이 모델은 provisional screening model이다. 최종 longitudinal MNLFA evidence가 아니다.

- `maps_llm_dif_prompt_template.md`
  - blind LLM DIF hypothesis generation을 위한 structured JSON prompt template이다.
  - 이 파일은 실제 실험 prompt이므로, 이전 결과와 비교하려면 함부로 바꾸지 않는다.

- `maps_llm_build_pilot_prompts.R`
  - API를 호출하지 않고 low-cost pilot용 JSONL prompt를 만든다.

- `maps_llm_keyword_baseline_eval.R`
  - LLM이 넘어야 할 무료 keyword baseline을 계산한다.

- `run_maps_llm_openai_pilot.ps1`
  - `OPENAI_API_KEY`가 있을 때 작은 유료 pilot을 실행할 수 있는 PowerShell runner다.

- `run_maps_llm_gemini_pilot.ps1`
  - Gemini API runner다.
  - `-Resume`, rate-limit backoff, 느린 실행 옵션을 포함한다.

## 로컬 생성 output

아래 파일들은 `llm_dif_output/` 아래에 생성되며 GitHub에는 올리지 않는다.

- `maps_multiscale_long.csv`
- `maps_multiscale_qc.csv`
- `maps_llm_item_catalog.csv`
- `maps_llm_prediction_template.csv`
- `maps_dif_screening_gold_quick.csv`
- `maps_dif_screening_gold_summary_quick.csv`
- `maps_dif_screening_gold_full.csv`
- `maps_dif_screening_gold_summary_full.csv`
- `maps_llm_pilot_items_30.csv`
- `maps_llm_pilot_prompts_30.jsonl`
- `maps_llm_pilot_prompt_preview.txt`
- `maps_keyword_baseline_predictions.csv`
- `maps_keyword_baseline_metrics.csv`
- `maps_llm_gemini_pilot_results_*.jsonl`
- `maps_llm_gemini_pilot_eval_metrics.csv`
- `maps_llm_gemini_pilot_eval_joined.csv`

## 현재 item pool

전처리 스크립트는 MAPS 반복 측정 척도 14개를 찾았다.

- Parent acculturation: 12 items
- Parent acculturative stress: 8 items
- Parent parenting efficacy: 9 items
- Parent self-esteem: 9 items
- Youth acculturative stress: 9 items
- Youth bicultural acceptance: 10 items
- Youth bullying: 6 items
- Youth friend support: 3 items
- Youth life satisfaction: 3 items
- Youth national identity: 4 items
- Youth parent support: 6 items
- Youth parenting / parent relationship: 10 items
- Youth teacher support: 3 items
- Youth worry: 14 items

screening unit:

- unstable youth worry split item을 제외한 105개 item.
- respondent-valid covariate만 사용.
- 총 487개 item-by-covariate test.

## 실행 확인

다음 명령은 성공적으로 실행되었다.

```powershell
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_multiscale_llm_prep.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_fill_item_text.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_make_batches.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_dif_gold_screen.R quick
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_dif_gold_screen.R full
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_build_pilot_prompts.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_keyword_baseline_eval.R
```

OpenAI runner는 key 없이 테스트했다.

```powershell
powershell -ExecutionPolicy Bypass -File .\run_maps_llm_openai_pilot.ps1 -Limit 1
```

`OPENAI_API_KEY`가 없으면 유료 호출 없이 멈추는 것을 확인했다.

## 주의점

- 현재 pilot item의 item text는 MAPS 유저가이드 기반으로 모두 채워졌다.
- screening model은 proxy latent score를 사용한 실용적 ordinal DIF screen이다. 최종 longitudinal MNLFA가 아니다.
- parent gender는 현재 parent file에서 사용할 수 없어 LLM prediction template과 screening test에서 제외했다.
- youth Korean-proficiency 값은 respondent/wave 전체에서 항상 안정적으로 있지 않아 일부 item row에서 결측이 많다.
- 현재 DIF label은 FDR-adjusted p-value와 practical coefficient threshold `|beta| >= 0.20`을 함께 사용한 provisional label이다.

## 다음 단계

이미 item text는 채웠고 Gemini pilot도 일부 실행했다. 다음 단계는 다음이다.

1. full 105 item prompt set을 천천히 실행한다.
2. `-Resume`으로 이미 성공한 API 결과는 재사용한다.
3. parse/eval을 다시 실행한다.
4. 487 item-covariate pair 기준으로 LLM vs keyword baseline 결과를 정리한다.
5. top-k candidate를 MNLFA/ordinal DIF validation 후보로 선정한다.

