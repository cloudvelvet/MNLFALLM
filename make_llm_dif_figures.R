out_dir <- file.path("RESEARCH", "llm_dif_paper_pipeline", "outputs", "figures")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
data_dir <- "llm_dif_output"

labels <- c(
  overall = "전체",
  `covariate:discrim_any` = "차별 경험",
  `covariate:korean_c` = "한국어 능력",
  `covariate:gender` = "성별",
  `covariate:age_c` = "연령",
  `covariate:income_c` = "가구소득"
)
order_groups <- names(labels)

metric_wide <- function(path) {
  d <- read.csv(path, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  d <- d[d$group %in% order_groups, ]
  rows <- lapply(order_groups, function(g) {
    sub <- d[d$group == g, ]
    original <- sub[sub$prompt_version == "original", ]
    strict <- sub[sub$prompt_version == "strict_dif", ]
    if (nrow(original) == 0 || nrow(strict) == 0) return(NULL)
    data.frame(
      group = g,
      label = unname(labels[g]),
      original_llm = original$llm_average_precision[1],
      strict_llm = strict$llm_average_precision[1],
      keyword = strict$keyword_average_precision[1],
      positives_original = original$positives[1],
      positives_strict = strict$positives[1],
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

save_ap_plot <- function(wide, path, title, subtitle) {
  png(path, width = 3000, height = 1600, res = 300, type = "cairo")
  oldpar <- par(no.readonly = TRUE)
  on.exit({ par(oldpar); dev.off() }, add = TRUE)
  par(family = "Malgun Gothic", mar = c(5, 5, 4.5, 1.5))
  mat <- rbind(
    `기본 지시문 LLM` = wide$original_llm,
    `엄격한 DIF 구분 지시문 LLM` = wide$strict_llm,
    `키워드 비교 기준` = wide$keyword
  )
  cols <- c("#4C78A8", "#F58518", "#54A24B")
  ylim <- c(0, max(0.75, max(mat, na.rm = TRUE) + 0.08))
  bp <- barplot(
    mat,
    beside = TRUE,
    col = cols,
    border = NA,
    names.arg = wide$label,
    ylim = ylim,
    ylab = "Average precision (AP)",
    cex.names = 0.92,
    las = 1
  )
  grid(nx = NA, ny = NULL, col = "#DDDDDD", lty = 1)
  box(bty = "l")
  title(main = title, line = 2.4, cex.main = 1.25, font.main = 2)
  mtext(subtitle, side = 3, line = 0.6, adj = 0, cex = 0.82, col = "#444444")
  legend(
    "topright",
    fill = cols,
    legend = rownames(mat),
    bty = "n",
    horiz = TRUE,
    inset = c(0, -0.02),
    cex = 0.8
  )
  for (i in seq_along(mat)) {
    text(
      bp[i],
      mat[i] + 0.015,
      sub("^0", "", sprintf("%.3f", mat[i])),
      cex = 0.62,
      xpd = TRUE
    )
  }
}

save_workflow <- function(path) {
  png(path, width = 3300, height = 1250, res = 300, type = "cairo")
  oldpar <- par(no.readonly = TRUE)
  on.exit({ par(oldpar); dev.off() }, add = TRUE)
  par(family = "Malgun Gothic", mar = c(1, 1, 3, 1))
  plot.new()
  plot.window(xlim = c(0, 1), ylim = c(0, 1))
  title("LLM 기반 DIF 후보 가설 생성 및 평가 절차", cex.main = 1.35, font.main = 2)

  heads <- c("MAPS 문항·공변량", "LLM 후보 생성", "구조화된 출력",
             "비교 기준", "평가", "해석")
  bodies <- c(
    "105개 문항\n문항-공변량 조합",
    "기본 지시문\n엄격한 DIF 구분 지시문",
    "문턱 DIF 가능성\n방향·확신도·판단 근거",
    "키워드 비교 기준\n잠정적 경험 DIF 선별",
    "AP, P@5, P@10\n지시문 민감도",
    "판정이 아니라\n검증할 후보 가설"
  )
  x <- seq(0.08, 0.92, length.out = length(heads))
  y <- 0.58
  w <- 0.135
  h <- 0.40
  fills <- c("#E8F1FA", "#FFF0DC", "#EAF7EA", "#F4ECF7", "#FCEAEA", "#EEF0F2")
  for (i in seq_along(heads)) {
    rect(x[i] - w / 2, y - h / 2, x[i] + w / 2, y + h / 2,
         col = fills[i], border = "#333333", lwd = 1.3)
    text(x[i], y + 0.09, heads[i], font = 2, cex = 0.85)
    text(x[i], y - 0.055, bodies[i], cex = 0.72)
    if (i < length(heads)) {
      arrows(x[i] + w / 2 + 0.012, y, x[i + 1] - w / 2 - 0.012, y,
             length = 0.08, lwd = 1.2, col = "#333333")
    }
  }
  text(
    0.5, 0.15,
    "LLM 산출물은 DIF 판정 근거가 아니라, 키워드 기준과 경험적 선별 결과에 비추어 검토할 후보 가설로 해석한다.",
    cex = 0.85,
    col = "#333333"
  )
}

save_scatter <- function(path) {
  d <- read.csv(file.path(data_dir, "maps_llm_gemini_sensitivity_eval_joined.csv"),
                stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  key <- c("scale_id", "item_id", "covariate")
  orig <- d[d$prompt_version == "original",
            c(key, "threshold_dif_probability_0_100", "dif_label")]
  strict <- d[d$prompt_version == "strict_dif",
              c(key, "threshold_dif_probability_0_100")]
  names(orig)[4] <- "score_original"
  names(strict)[4] <- "score_strict"
  m <- merge(orig, strict, by = key)
  rho <- suppressWarnings(cor(m$score_original, m$score_strict,
                              method = "spearman", use = "complete.obs"))

  png(path, width = 1800, height = 1700, res = 300, type = "cairo")
  oldpar <- par(no.readonly = TRUE)
  on.exit({ par(oldpar); dev.off() }, add = TRUE)
  par(family = "Malgun Gothic", mar = c(5, 5, 4, 1.5))
  col <- ifelse(m$dif_label == "TRUE" | m$dif_label == TRUE, "#D95F02AA", "#4C78A8AA")
  plot(
    m$score_original, m$score_strict,
    pch = 16,
    col = col,
    xlim = c(0, 100),
    ylim = c(0, 100),
    xlab = "기본 지시문 LLM 점수",
    ylab = "엄격한 DIF 구분 지시문 LLM 점수",
    main = "지시문 조건에 따른 LLM 점수 변화"
  )
  abline(0, 1, lty = 2, col = "#555555")
  grid(col = "#DDDDDD")
  legend("topleft", legend = c("경험 DIF 후보", "비후보"),
         col = c("#D95F02", "#4C78A8"), pch = 16, bty = "n", cex = 0.85)
  text(72, 12, sprintf("Spearman rho = %.3f\n공통 조합 = %d", rho, nrow(m)), cex = 0.85)
}

main_wide <- metric_wide(file.path(data_dir, "maps_llm_gemini_sensitivity_eval_metrics.csv"))
w6_wide <- metric_wide(file.path(data_dir, "maps_llm_gemini_sensitivity_eval_metrics_w6.csv"))

save_ap_plot(
  main_wide,
  file.path(out_dir, "figure1_main_ap_by_covariate.png"),
  "주 분석: 공변량별 우선순위화 성능",
  "MAPS 2기 1-5차년도 pooled long 자료 기준"
)
save_ap_plot(
  w6_wide,
  file.path(out_dir, "figure1b_w6_ap_by_covariate.png"),
  "민감도 분석: 6차년도 단일 wave 우선순위화 성능",
  "MAPS 2기 6차년도 단일 wave 자료 기준"
)
save_workflow(file.path(out_dir, "figure2_workflow.png"))
save_scatter(file.path(out_dir, "figure3_prompt_sensitivity_scatter.png"))

write.csv(main_wide, file.path(out_dir, "figure1_main_ap_values.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(w6_wide, file.path(out_dir, "figure1b_w6_ap_values.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

print(normalizePath(list.files(out_dir, pattern = "^figure.*[.]png$", full.names = TRUE)))
