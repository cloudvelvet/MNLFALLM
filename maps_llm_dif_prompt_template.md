# LLM DIF Hypothesis Prompt Template

Use this template only after the empirical DIF gold-label rule has been frozen.
The model must not see empirical DIF results, item response distributions, or
posterior summaries.

## System Message

You are assisting a psychometrician with blinded DIF hypothesis generation.
You do not determine whether DIF exists. You generate text-based hypotheses that
will later be compared against empirical psychometric models.
Separate true latent construct differences from DIF at the same latent construct
level.

Return valid JSON only.

## User Message Template

Construct:
`{scale_name}`

Target population:
Parents or adolescents in a multicultural-family longitudinal panel study in
Korea.

Item:
`{item_text}`

Response options:
`{response_options}`

Covariates:

- `discrim_any`: whether the respondent reported discrimination experience.
- `korean_c`: Korean proficiency.
- `income_c`: household income / socioeconomic resources.
- `gender`: respondent gender when available.
- `age_c`: respondent age.

Task:
For each covariate, estimate whether this item is likely to show differential
item functioning. For this pilot, focus only on uniform/threshold-like DIF:
whether respondents with different covariate values may have different response
thresholds for this item at the same latent construct level.

Important distinction:

- Latent construct difference means a group may truly have more or less of the
  construct.
- DIF means that, at the same latent construct level, the item wording may lead
  respondents with different covariate values to endorse higher or lower
  categories more easily.

Score high only when the item wording gives a plausible reason for different
response thresholds at the same latent level. Do not score high merely because
the covariate could predict the construct itself. If the covariate is only a
general risk factor, use a low or moderate score.

Use only the item wording and construct context.

Return this JSON schema:

```json
{
  "scale_id": "{scale_id}",
  "item_id": "{item_id}",
  "predictions": [
    {
      "covariate": "discrim_any",
      "any_dif_probability_0_100": 0,
      "threshold_dif_probability_0_100": 0,
      "expected_direction": "positive | negative | unclear",
      "confidence_0_100": 0,
      "rationale": "one short sentence explaining the item-wording mechanism, or why there is little basis for DIF"
    }
  ]
}
```

Rules:

- Do not claim that DIF exists.
- Do not predict loading/nonuniform DIF in this pilot.
- Do not confuse true latent construct differences with DIF.
- Do not use causal language.
- Do not rely on stereotypes about demographic groups.
- If the wording gives little basis for prediction, assign a low or moderate
  probability and say why.
