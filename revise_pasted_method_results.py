from pathlib import Path


SRC = Path(r"C:\Users\ggoke\.codex\attachments\fa2ac00e-a528-4cea-a472-408f5dddf22c\pasted-text.txt")
DST = Path(r"C:\chen_bauer_2024\MNLFALLM\pasted-text_수정본.txt")


text = SRC.read_text(encoding="utf-8")

text = text.replace(
    "분석의 초점은 경험적 선별 이후 연구자가 검토할 문항-공변량 후보를 어떻게 우선순위화할 수 있는지에 있다.",
    "분석의 초점은 경험적 선별 결과를 LLM에 제공하지 않은 상태에서, 후속 검토의 우선순위가 될 문항-공변량 후보를 얼마나 잘 정렬할 수 있는지에 있다.",
)

lines = text.splitlines()
new_lines = []
for line in lines:
    if line.startswith("raw response 공개\t"):
        new_lines.append(
            "raw response 공개\t모든 raw response는 재현성 점검을 위해 보존하였다. 다만 MAPS 문항 원문 공개가 제한되는 경우에는 문항 ID, 예측값, 판단 근거, 파싱 결과를 분리하여 공개하고, 문항 원문 전체는 자료 이용 조건과 저작권 조건을 따른다."
        )
        continue
    new_lines.append(line)

text = "\n".join(new_lines) + "\n"

text = text.replace(
    "반복측정 자료의 응답자 내 의존성을 고려하기 위해 cluster-robust 표준오차를 사용한 선별 결과도 민감도 분석으로 검토하였다(표 11). 이 분석에서도 LLM과 이분형 키워드 기준의 차이는 크지 않았으며, 결과의 방향은 지시문 조건과 선별 기준에 따라 달라졌다. 따라서 cluster-robust 분석은 LLM의 일관된 우위를 뒷받침하기보다는, 경험적 label 자체가 모형 선택과 표준오차 처리 방식에 민감할 수 있음을 보여주는 보조 결과로 보는 것이 적절하다.",
    "반복측정 자료의 응답자 내 의존성을 고려하기 위해 cluster-robust 표준오차를 사용한 선별 결과도 민감도 분석으로 검토하였다(표 12). 이 분석에서도 LLM과 이분형 키워드 기준의 차이는 크지 않았다. 다만 이 분석은 반복측정 의존성을 완전히 모형화한 것이 아니라, 표준오차 처리 방식 변화에 따라 screening label이 얼마나 민감하게 달라지는지를 점검하기 위한 보조 분석으로 보아야 한다.",
)

text = text.replace(
    "6차년도 단일 wave만 사용한 민감도 분석에서는 주 분석과 다른 양상이 나타났다(표 12).",
    "6차년도 단일 wave만 사용한 민감도 분석에서는 주 분석과 다른 양상이 나타났다(표 13).",
)

threshold_last_row = "엄격\tFDR<.05 + |beta|>=.30\t85\t.176\t.308\t.307 [.268, .356]\t.000\t.398\t.669"
threshold_note = (
    threshold_last_row
    + "\n주. 이분형 키워드 AP의 대괄호 안 값은 표본추출 불확실성에 대한 신뢰구간이 아니라, 키워드 점수의 동점 처리를 무작위로 2,000회 반복했을 때의 2.5-97.5 백분위 범위이다."
)
if threshold_last_row in text and threshold_note not in text:
    text = text.replace(threshold_last_row, threshold_note)

DST.write_text(text, encoding="utf-8")
print(DST)
