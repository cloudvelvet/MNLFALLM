# MNLFALLM

MAPS 다문화 패널 문항을 대상으로 한 **LLM 보조 DIF 가설 생성** 프로젝트입니다.

이 저장소는 MAPS MNLFA/포스터 저장소와 분리되어 있습니다. 여기에는 LLM-DIF 작업에 필요한 파일만 둡니다. 문항과 covariate catalog를 만들고, Gemini/OpenAI용 prompt를 생성하고, LLM 결과를 keyword baseline 및 provisional DIF screening과 비교하는 흐름입니다.

## 핵심 프레이밍

LLM은 **DIF 판정기**가 아닙니다. 이 프로젝트에서 LLM은 문항 텍스트와 covariate 맥락을 보고 “이 조합에서 DIF가 날 수 있다면 어떤 이유가 가능한가”를 제안하는 **가설 생성 도구**입니다.

최종 해석은 반드시 심리측정 검증을 거쳐야 합니다. 최소한 ordinal DIF screening이 필요하고, 주요 결과는 MNLFA 또는 그에 준하는 formal DIF model로 확인해야 합니다.

## 주요 파일

- `maps_multiscale_llm_prep.R`: MAPS 다중 척도 long data와 item/covariate catalog를 만듭니다.
- `maps_llm_fill_item_text.R`: MAPS 유저가이드에서 정리한 문항 텍스트를 item catalog에 채웁니다.
- `maps_llm_make_batches.R`: pilot/full item-covariate batch를 만듭니다.
- `maps_llm_dif_gold_screen.R`: provisional ordinal-logit DIF screening을 실행합니다.
- `maps_llm_build_pilot_prompts.R`: LLM prompt JSONL을 만듭니다.
- `run_maps_llm_gemini_pilot.ps1`: Gemini API 실행 스크립트입니다. `-Resume`과 rate-limit 대기 기능이 있습니다.
- `maps_llm_parse_gemini_results.R`: Gemini JSONL 결과를 분석 가능한 CSV로 풉니다.
- `maps_llm_eval_gemini_pilot.R`: LLM score, provisional DIF label, keyword baseline을 비교합니다.
- `RESEARCH/ai_llm_dif_requirements/`: AI-DIF 논문을 위해 필요한 조건, 교수님 설명문, 진행 상태.
- `RESEARCH/llm_dif_prior_work/`: 직접 선행연구와 인접 문헌 정리.
- `RESEARCH/llm_dif_paper_pipeline/`: 논문 파이프라인, 검증 게이트, 다음 작업.
- `HANDOFF_MNLFALLM.md`: 다른 컴퓨터에서 이어서 작업할 때 보는 문서.

## GitHub에 올리지 않는 것

아래 파일과 폴더는 GitHub에 올리지 않습니다.

- MAPS 원자료
- `llm_dif_output/`
- API key, `.Renviron`
- 큰 model output 또는 simulation output

설정과 파일 이동 방법은 `HANDOFF_MNLFALLM.md`를 보면 됩니다.

