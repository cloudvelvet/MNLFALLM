out_dir <- file.path("RESEARCH", "llm_dif_paper_pipeline", "outputs", "figures")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
data_dir <- "llm_dif_output"

labels <- c(
  overall = "\uc804\uccb4",
  `covariate:discrim_any` = "\ucc28\ubcc4 \uacbd\ud5d8",
  `covariate:korean_c` = "\ud55c\uad6d\uc5b4 \ub2a5\ub825",
  `covariate:gender` = "\uc131\ubcc4",
  `covariate:age_c` = "\uc5f0\ub839",
  `covariate:income_c` = "\uac00\uad6c\uc18c\ub4dd"
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

save_ap_plot_pub <- function(wide, path) {
  png(path, width = 3000, height = 1700, res = 300, type = "cairo")
  oldpar <- par(no.readonly = TRUE)
  on.exit({ par(oldpar); dev.off() }, add = TRUE)

  par(family = "Malgun Gothic", mar = c(5.2, 5.2, 1.1, 0.8), mgp = c(3.2, 0.9, 0))
  mat <- rbind(
    "\uae30\ubcf8 \uc9c0\uc2dc\ubb38" = wide$original_llm,
    "\uc5c4\uaca9\ud55c DIF \uad6c\ubd84 \uc9c0\uc2dc\ubb38" = wide$strict_llm,
    "\ud0a4\uc6cc\ub4dc \ube44\uad50 \uae30\uc900" = wide$keyword
  )
  cols <- c("#FFFFFF", "#BDBDBD", "#404040")
  ylim <- c(0, max(0.75, max(mat, na.rm = TRUE) + 0.08))
  bp <- barplot(
    mat,
    beside = TRUE,
    col = cols,
    border = "#222222",
    lwd = 0.8,
    names.arg = wide$label,
    ylim = ylim,
    ylab = "Average precision (AP)",
    cex.names = 0.95,
    cex.axis = 0.9,
    las = 1
  )
  abline(h = pretty(ylim), col = "#E5E5E5", lwd = 0.8)
  box(bty = "l", lwd = 0.9)
  legend(
    "topright",
    fill = cols,
    border = "#222222",
    legend = rownames(mat),
    bty = "n",
    horiz = TRUE,
    inset = c(0.0, 0.0),
    cex = 0.78
  )
  for (i in seq_along(mat)) {
    text(
      bp[i],
      mat[i] + 0.014,
      sub("^0", "", sprintf("%.3f", mat[i])),
      cex = 0.56,
      xpd = TRUE
    )
  }
}

save_workflow_pub <- function(path) {
  png(path, width = 3300, height = 950, res = 300, type = "cairo")
  oldpar <- par(no.readonly = TRUE)
  on.exit({ par(oldpar); dev.off() }, add = TRUE)

  par(family = "Malgun Gothic", mar = c(0.6, 0.8, 0.6, 0.8))
  plot.new()
  plot.window(xlim = c(0, 1), ylim = c(0, 1))

  heads <- c(
    "MAPS \ubb38\ud56d-\uacf5\ubcc0\ub7c9",
    "LLM \uac00\uc124 \uc0dd\uc131",
    "\uad6c\uc870\ud654\ub41c \ucd9c\ub825",
    "\ube44\uad50 \uae30\uc900",
    "\uc6b0\uc120\uc21c\uc704\ud654 \ud3c9\uac00",
    "\ud574\uc11d"
  )
  bodies <- c(
    "105\uac1c \ubb38\ud56d\n\ubb38\ud56d-\uacf5\ubcc0\ub7c9 \uc870\ud569",
    "\uae30\ubcf8 \uc9c0\uc2dc\ubb38\n\uc5c4\uaca9\ud55c DIF \uad6c\ubd84 \uc9c0\uc2dc\ubb38",
    "\ubb38\ud131 DIF \uac00\ub2a5\uc131\n\ubc29\ud5a5\u00b7\ud655\uc2e0\ub3c4\u00b7\ud310\ub2e8 \uadfc\uac70",
    "\ud0a4\uc6cc\ub4dc \ube44\uad50 \uae30\uc900\n\uc7a0\uc815\uc801 \uacbd\ud5d8 DIF \uc120\ubcc4",
    "AP, P@5, P@10\n\uc9c0\uc2dc\ubb38 \ubbfc\uac10\ub3c4",
    "\ud310\uc815\uc774 \uc544\ub2cc\n\uac80\uc99d\ud560 \ud6c4\ubcf4 \uac00\uc124"
  )

  x <- seq(0.085, 0.915, length.out = length(heads))
  y <- 0.54
  w <- 0.13
  h <- 0.47
  for (i in seq_along(heads)) {
    rect(x[i] - w / 2, y - h / 2, x[i] + w / 2, y + h / 2,
         col = "#FFFFFF", border = "#222222", lwd = 0.9)
    text(x[i], y + 0.11, heads[i], font = 2, cex = 0.78)
    text(x[i], y - 0.06, bodies[i], cex = 0.67)
    if (i < length(heads)) {
      arrows(
        x[i] + w / 2 + 0.014, y,
        x[i + 1] - w / 2 - 0.014, y,
        length = 0.06,
        lwd = 0.8,
        col = "#222222"
      )
    }
  }
}

save_scatter_pub <- function(path) {
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

  par(family = "Malgun Gothic", mar = c(5, 5, 1.2, 1))
  is_pos <- m$dif_label == "TRUE" | m$dif_label == TRUE
  col <- ifelse(is_pos, "#111111AA", "#B0B0B0AA")
  pch <- ifelse(is_pos, 16, 1)
  plot(
    m$score_original, m$score_strict,
    pch = pch,
    col = col,
    xlim = c(0, 100),
    ylim = c(0, 100),
    xlab = "\uae30\ubcf8 \uc9c0\uc2dc\ubb38 LLM \uc810\uc218",
    ylab = "\uc5c4\uaca9\ud55c DIF \uad6c\ubd84 \uc9c0\uc2dc\ubb38 LLM \uc810\uc218",
    cex = 0.68,
    las = 1
  )
  abline(0, 1, lty = 2, col = "#555555", lwd = 0.9)
  grid(col = "#E5E5E5", lwd = 0.8)
  box(bty = "l", lwd = 0.9)
  legend(
    "topleft",
    legend = c("\uacbd\ud5d8 DIF \ud6c4\ubcf4", "\ube44\ud6c4\ubcf4"),
    col = c("#111111", "#777777"),
    pch = c(16, 1),
    bty = "n",
    cex = 0.83
  )
  text(72, 11, sprintf("Spearman rho = %.3f\nn = %d", rho, nrow(m)), cex = 0.82)
}

main_wide <- metric_wide(file.path(data_dir, "maps_llm_gemini_sensitivity_eval_metrics.csv"))
w6_wide <- metric_wide(file.path(data_dir, "maps_llm_gemini_sensitivity_eval_metrics_w6.csv"))

save_ap_plot_pub(main_wide, file.path(out_dir, "figure1_main_ap_publication.png"))
save_ap_plot_pub(w6_wide, file.path(out_dir, "figure1b_w6_ap_publication.png"))
save_workflow_pub(file.path(out_dir, "figure2_workflow_publication.png"))
save_scatter_pub(file.path(out_dir, "figure3_prompt_sensitivity_publication.png"))

print(normalizePath(list.files(out_dir, pattern = "publication[.]png$", full.names = TRUE)))
