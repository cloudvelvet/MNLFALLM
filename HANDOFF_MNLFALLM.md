# MNLFALLM 인수인계

목적: MAPS item-covariate pair에 대해 LLM 보조 DIF 후보 가설을 생성하고, 그 결과를 심리측정 검증과 연결한다.

이 저장소는 LLM-DIF 탐색 프로젝트 전용입니다. 핵심 아이디어는 간단합니다. LLM을 최종 DIF 판정기로 쓰지 않고, 문항 의미와 covariate 맥락을 바탕으로 검토할 만한 DIF 후보를 먼저 제안하게 합니다. 그다음 keyword baseline, ordinal DIF screening, MNLFA-style model로 검증합니다.

## 이 저장소에 들어가는 것

- MAPS item/covariate catalog 준비 스크립트
- prompt template과 prompt 생성 스크립트
- Gemini/OpenAI 실행 스크립트
- LLM 결과 parsing/evaluation 스크립트
- keyword baseline과 provisional DIF screening 스크립트
- LLM-DIF 아이디어 관련 선행연구, 교수님 설명문, 논문 파이프라인

## 이 저장소에 넣지 않는 것

- MAPS 원자료
- `llm_dif_output/` 결과 폴더
- API key 또는 `.Renviron`
- MNLFA 포스터/모델 output 폴더
- LLM-DIF와 무관한 포스터용 Stan/R 스크립트

## 로컬에만 두는 폴더

아래 폴더는 GitHub가 아니라 MYBOX나 개인 저장장치로 옮깁니다.

```text
C:\chen_bauer_2024\MAPS 2기 패널_Data_CSV (1)
C:\chen_bauer_2024\llm_dif_output
```

## 다른 컴퓨터에서 시작하기

저장소를 clone합니다.

```powershell
git clone -b llm-only-clean https://github.com/cloudvelvet/MNLFALLM.git C:\chen_bauer_2024\MNLFALLM
```

MYBOX에 데이터와 결과를 백업해두었다면 아래처럼 복사합니다.

```text
MYBOX\MNLFA_STRESS_shared\data\MAPS 2기 패널_Data_CSV (1)
-> C:\chen_bauer_2024\MAPS 2기 패널_Data_CSV (1)

MYBOX\MNLFA_STRESS_shared\outputs\llm_dif_output
-> C:\chen_bauer_2024\MNLFALLM\llm_dif_output
```

Gemini API key는 새 컴퓨터에서 다시 설정합니다. 키는 파일에 적어두지 않습니다.

```powershell
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "YOUR_KEY", "User")
```

PowerShell을 새로 열고 확인합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\check_gemini_api_key.ps1
```

## 기본 실행 순서

item/covariate 자료를 준비합니다.

```powershell
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_multiscale_llm_prep.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_llm_fill_item_text.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_llm_make_batches.R
```

provisional DIF screening을 실행합니다.

```powershell
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_llm_dif_gold_screen.R full
```

Gemini는 무료 API rate limit에 걸리기 쉬우므로 천천히 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\run_maps_llm_gemini_pilot.ps1 -Limit 10 -Resume -SleepSeconds 90 -RateLimitBaseSeconds 90 -RateLimitMaxSeconds 600
```

결과를 파싱하고 평가합니다.

```powershell
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_llm_parse_gemini_results.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_llm_eval_gemini_pilot.R
```

## 현재 해석

LLM이 DIF를 탐지한다고 쓰면 안 됩니다. 더 안전한 표현은 다음입니다.

> LLM은 의미적으로 그럴듯한 DIF 후보 가설을 생성하는 데 도움을 줄 수 있다. 그러나 그 후보가 실제 measurement-function difference인지 판단하려면 empirical psychometric validation이 필요하다. 특히 중요한 연구문제는 LLM이 latent trait difference와 measurement-function difference를 어디서 혼동하는지 확인하는 것이다.

