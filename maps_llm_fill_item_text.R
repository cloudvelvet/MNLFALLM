# Fill MAPS LLM-DIF item catalog with item wording from the user guide.
#
# Run after:
#   Rscript maps_multiscale_llm_prep.R
#
# Outputs:
#   llm_dif_output/maps_llm_item_catalog_filled.csv
#   llm_dif_output/maps_llm_prediction_template_filled.csv
#   llm_dif_output/maps_llm_item_text_coverage.csv

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}

library(dplyr)

out_dir <- "llm_dif_output"
catalog_csv <- file.path(out_dir, "maps_llm_item_catalog.csv")
template_csv <- file.path(out_dir, "maps_llm_prediction_template.csv")

if (!file.exists(catalog_csv) || !file.exists(template_csv)) {
  stop("Run maps_multiscale_llm_prep.R before this script.")
}

item_meta <- data.frame(
  item_stem = c(
    "p_accul_str_01", "p_accul_str_02", "p_accul_str_03", "p_accul_str_04",
    "p_accul_str_05", "p_accul_str_06", "p_accul_str_07", "p_accul_str_08",
    "p_esteem_01", "p_esteem_02", "p_esteem_03", "p_esteem_04",
    "p_esteem_05", "p_esteem_06", "p_esteem_07", "p_esteem_08",
    "p_esteem_09",
    "p_efficacy_01", "p_efficacy_02", "p_efficacy_03", "p_efficacy_04",
    "p_efficacy_05", "p_efficacy_06", "p_efficacy_07", "p_efficacy_08",
    "p_efficacy_09",
    "p_accul_01", "p_accul_02", "p_accul_03", "p_accul_04",
    "p_accul_05", "p_accul_06", "p_accul_07", "p_accul_08",
    "p_accul_09", "p_accul_10", "p_accul_11", "p_accul_12",
    "s_accul_str_01", "s_accul_str_02", "s_accul_str_03",
    "s_accul_str_04", "s_accul_str_05", "s_accul_str_06",
    "s_accul_str_07", "s_accul_str_08", "s_accul_str_09",
    "s_national_iden_01", "s_national_iden_02", "s_national_iden_03",
    "s_national_iden_04",
    "biticul_acc_01", "biticul_acc_02", "biticul_acc_03",
    "biticul_acc_04", "biticul_acc_05", "biticul_acc_06",
    "biticul_acc_07", "biticul_acc_08", "biticul_acc_09",
    "biticul_acc_10",
    "life_satis_01", "life_satis_02", "life_satis_03",
    "s_worry_01", "s_worry_02", "s_worry_03", "s_worry_04",
    "s_worry_05", "s_worry_06", "s_worry_07", "s_worry_08",
    "s_worry_09", "s_worry_10", "s_worry_11", "s_worry_12",
    "s_worry_13", "s_worry_14",
    "p_support_a01", "p_support_a02", "p_support_a03", "p_support_a04",
    "p_support_a05", "p_support_a06",
    "parenting_a01", "parenting_a02", "parenting_a03",
    "parenting_b01", "parenting_b02", "parenting_b03", "parenting_b04",
    "parenting_b05", "parenting_b06", "parenting_b07",
    "fr_sup_01", "fr_sup_02", "fr_sup_03",
    "te_sup_01", "te_sup_02", "te_sup_03",
    "bullying_01", "bullying_02", "bullying_03", "bullying_04",
    "bullying_05", "bullying_06"
  ),
  item_text = c(
    "나는 사회생활에서 한국 사람들과 다른 대우를 받는다",
    "한국 사람들은 내가 외국에서 왔다는 편견을 가지고 있다",
    "나는 고향에 대한 그리움 때문에 힘들다",
    "나는 고향을 떠나 낯선 환경에서 생활하는 게 슬프다",
    "나는 내가 태어난 곳과 사람들이 그립다",
    "나는 외국출신자들을 무시하는 것에 화가 난다",
    "나는 내가 외국에서 왔다는 이유 때문에 위축된다",
    "나는 내가 외국에서 왔기 때문에 사회적 지위가 낮다고 느낀다",
    "나는 다른 사람처럼 가치있는 사람이라고 생각한다",
    "나는 좋은 성품을 가졌다고 생각한다",
    "나는 대체적으로 실패한 사람이라고 생각한다",
    "나는 대부분의 다른 사람들만큼 일을 잘 할 수 있다",
    "나는 자랑할 것이 별로 없다",
    "나는 나 자신에 대해 긍정적인 태도를 가지고 있다",
    "나는 나 자신에 대해서 대체적으로 만족한다",
    "나는 가끔 나 자신이 쓸모없는 사람이라는 느낌이 든다",
    "나는 때때로 내가 좋은 사람이 아니라고 생각한다",
    "나는 내 행동이 내 아이에게 어떤 영향을 미치는지 잘 알고 있다",
    "나는 내가 유능한 부모라고 생각한다",
    "나는 내 아이가 무엇을 힘들어 하는지 잘 알고 있다",
    "나는 내가 다른 사람들에게 좋은 부모의 역할을 보여줄 수 있는 모델이라고 생각한다",
    "나는 내 아이와의 관계에서 생기는 문제를 잘 해결할 수 있다",
    "나는 내 아이가 잘못했을 때 스스로 잘못한 점을 깨달을 수 있도록 잘 설명한다",
    "나는 부모의 역할을 잘하고 있다",
    "나는 부모역할에 별로 흥미가 없다",
    "나는 좋은 부모가 되기 위해 필요한 지식과 방법을 잘 알고 있다",
    "나는 모국사람들보다 한국사람들과 더 잘 어울린다",
    "나는 모국사람들보다 한국사람들에게 나의 감정을 이야기하는 것이 더 쉽다",
    "나는 모국사람들보다 한국사람들과 사귀는 것이 더 편하다",
    "나는 한국인 친구와 모국인 친구가 모두 있다",
    "나는 한국사람들과 모국사람들 모두 나를 귀중히 여긴다고 느낀다",
    "나는 한국사람이든 모국사람이든 누구와 함께 있어도 매우 편안하다",
    "나는 모이는 대부분의 사람들이 모국사람인 모임에 가는 것을 더 좋아한다",
    "나는 한국사람들보다 모국사람들이 나를 더 동등하게 대해준다고 느낀다",
    "나는 한국사람들과 함께 있을 때보다 모국사람들과 함께 있을 때 더 편하다",
    "나는 한국인이나 모국인 누구도 나를 이해하지 못한다고 생각할 때가 있다",
    "나는 때때로 한국사람이나 모국사람이나 모두 나를 받아들이지 않는다고 느낀다",
    "나는 종종 한국사람들이나 모국사람들 모두 나를 이해하는데 어려움을 느낀다고 생각한다",
    "다른 사람이 외국인 부모님 나라의 문화를 갖고 농담할 때 스트레스를 받는다",
    "외국인 부모님이 다른 나라 사람이라서 학교에 가고 싶지 않다",
    "한국에 사는 것에 스트레스를 받는다",
    "한국어를 잘 못해서 스트레스를 받는다",
    "주변에서 한국 사람처럼 행동하라고 스트레스를 준다",
    "나의 부모님이 외국인이라서 무시를 당한다",
    "나의 부모님이 외국인이라고 친구들이 따돌린다",
    "우리 동네 사람들은 우리 식구를 못살게 군다",
    "한국 사람들은 우리 식구를 못살게 군다",
    "누군가 한국을 칭찬하면 내가 칭찬받는 것 같다",
    "나는 다른 나라 사람들이 한국에 관해서 어떤 생각을 갖는지에 관심이 많다",
    "한국의 성공이 곧 나의 성공이다",
    "누군가 한국에 대해 나쁘게 이야기하면 나에게 욕하는 것 같아서 기분이 상한다",
    "나는 한국문화(음악, 영화, 음식, 옷 등)를 즐기는 편이다",
    "나는 모국의 문화(음악, 영화, 음식, 옷 등)를 즐기는 편이다",
    "나는 부모님이 외국인이라는 것이 자랑스럽다",
    "나는 한국에 살고 있다는 것이 자랑스럽다",
    "나는 앞으로 계속 한국에 살고 싶다",
    "나는 앞으로 모국에 가서 살고 싶다",
    "나는 한국의 대학이나 회사에 다니고 싶다",
    "나는 모국에 가서 대학이나 회사에 다니고 싶다",
    "나는 모국 문화를 배우는 것이 중요하다",
    "한국문화를 배우는 것은 내게 중요하다",
    "나는 사는 게 즐겁다",
    "나는 걱정거리가 별로 없다",
    "나는 내 삶이 행복하다고 생각한다",
    "공부, 학교, 성적 문제",
    "진학, 진로 문제",
    "가정의 경제적 형편",
    "부모님 사이의 불화 또는 부모님/가족과의 갈등",
    "아버지와 나의 갈등",
    "어머니와 나의 갈등",
    "형제자매와 나와의 갈등",
    "이성친구와의 문제",
    "친구와의 문제",
    "나의 성격 문제",
    "나의 외모 문제",
    "나의 건강 문제(신체적, 정신적)",
    "미래에 대한 불안감",
    "비자/체류 문제",
    "부모님(보호자)은 열심히 공부하라고 격려해주신다",
    "부모님(보호자)은 학교에서 어려운 일이 생기면 도와주신다",
    "부모님(보호자)은 고등학교 혹은 대학에 진학하도록 격려해주신다",
    "부모님(보호자)은 나에게 많은 관심을 보여주신다",
    "부모님(보호자)은 수업이나 학교생활을 잘 할 수 있도록 도움말을 많이 해주신다",
    "부모님(보호자)은 내가 필요로 하는 것들(물건, 장소 등)을 잘 제공해주신다",
    "부모님(보호자)은 내가 방과 후에 어디에 가는지 알고 계신다",
    "부모님(보호자)은 내가 시간을 어떻게 보내는지 알고 계신다",
    "부모님(보호자)은 내가 외출할 경우 언제 들어올지 알고 계신다",
    "부모님(보호자)은 나보다 바깥일을 더 중요하게 생각하시는 것 같다",
    "부모님(보호자)은 나에 대해 관심이 없으셔서 칭찬을 하거나 혼내시는 일이 없다",
    "부모님(보호자)은 내가 어떤 생각을 갖고 있는지에 대해 관심이 없으시다",
    "부모님(보호자)은 내가 필요로 할 때 곁에 없으시다",
    "부모님(보호자)은 내가 아플 때에도 귀찮아서 병원에 데려가지 않으신다",
    "부모님(보호자)은 내가 학교에서 어떻게 생활하는지 관심을 갖고 물어보신다",
    "부모님(보호자)은 내 몸이나 옷, 이불 등이 깨끗하도록 항상 신경쓰신다",
    "내 친구들은 나에게 관심이 많은 것 같다",
    "내 친구들은 나와 함께 지내는 것을 좋아하는 것 같다",
    "내 친구들은 나를 잘 이해해주는 것 같다",
    "우리 담임선생님은 나에게 관심이 많으신 것 같다",
    "내가 아프거나 내게 무슨 일이 생기면 우리 담임선생님은 날 걱정해주시는 것 같다",
    "우리 담임선생님은 나를 중요한 사람으로 인정해주시는 것 같다",
    "다른 학생들로부터 따돌림을 당했다",
    "다른 학생들로부터 욕을 듣거나 심한 집적거림 또는 놀림을 당했다",
    "다른 학생들이 나를 고의로 어떤 일에 끼워주지 않거나 완전히 무시했다",
    "다른 학생들로부터 맞거나 발로 차이거나 위협을 당했다",
    "나에 대해 거짓소문을 퍼뜨려서 다른 친구들이 나를 싫어하게 되었다",
    "다른 학생들로부터 신체적 특징이나 외모에 대해 험한 욕설을 듣거나 놀림을 당했다"
  ),
  response_options = NA_character_,
  item_text_source = "MAPS 2기패널(1-5차) 데이터 유저가이드, 주요변수 안내",
  stringsAsFactors = FALSE
)

item_meta$wording_note <- "standard"
item_meta$response_options <- "observed ordinal categories 1-5 in the analytic file; verify exact verbal anchors in the MAPS codebook before final API runs"
item_meta$response_options[item_meta$item_stem %in% c(
  sprintf("s_accul_str_%02d", 1:9),
  sprintf("biticul_acc_%02d", 1:10),
  sprintf("s_worry_%02d", 1:14),
  sprintf("s_national_iden_%02d", 1:4),
  sprintf("life_satis_%02d", 1:3),
  sprintf("p_support_a%02d", 1:6),
  sprintf("parenting_a%02d", 1:3),
  sprintf("parenting_b%02d", 1:7),
  sprintf("bullying_%02d", 1:6)
)] <- "observed ordinal categories 1-4 in the analytic file; verify exact verbal anchors in the MAPS codebook before final API runs"
item_meta$response_options[item_meta$item_stem %in% c(
  sprintf("fr_sup_%02d", 1:3),
  sprintf("te_sup_%02d", 1:3)
)] <- "observed ordinal categories 1-5 in the analytic file; verify exact verbal anchors in the MAPS codebook before final API runs"
item_meta$wording_note[item_meta$item_stem %in% c(
  "p_esteem_03", "p_esteem_05", "p_esteem_08", "p_esteem_09",
  "p_efficacy_08", "parenting_b01", "parenting_b02", "parenting_b03",
  "parenting_b04", "parenting_b05"
)] <- "negative_wording_or_reverse_scored_candidate"
item_meta$wording_note[item_meta$item_stem == "s_worry_04"] <-
  "wording differs across waves in the guide; treat cautiously"

fill_text <- function(dat) {
  dat %>%
    select(-any_of(c("item_text", "item_text_status"))) %>%
    left_join(item_meta, by = "item_stem") %>%
    mutate(
      item_text_status = ifelse(is.na(item_text), "missing_text", "filled_from_user_guide")
    )
}

catalog <- read.csv(catalog_csv, stringsAsFactors = FALSE)
template <- read.csv(template_csv, stringsAsFactors = FALSE)

catalog_filled <- fill_text(catalog)
template_filled <- fill_text(template)

write.csv(catalog_filled,
          file.path(out_dir, "maps_llm_item_catalog_filled.csv"),
          row.names = FALSE)
write.csv(template_filled,
          file.path(out_dir, "maps_llm_prediction_template_filled.csv"),
          row.names = FALSE)

coverage <- catalog_filled %>%
  group_by(respondent_type, scale_id, scale_name, item_text_status) %>%
  summarise(items = n(), .groups = "drop") %>%
  arrange(respondent_type, scale_id, item_text_status)
write.csv(coverage,
          file.path(out_dir, "maps_llm_item_text_coverage.csv"),
          row.names = FALSE)

message("Saved filled item catalog and prediction template in: ", out_dir)
print(coverage)
