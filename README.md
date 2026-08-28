# London Food Hygiene Insights

A public data food hygiene compliance analysis for London business premises, built entirely on 'real-world' open UK government data.

## Overview

This project investigates food hygiene compliance across London's 33 boroughs, asking:

- How does food safety compliance vary across London?
- Does it correlate with local deprivation levels, business type, or borough?
- Can an establishment's likelihood of falling short of a top (**5**) FHRS rating be predicted?

This is a Tableau-led data analyst portfolio project, scoped to demonstrate range across Snowflake SQL, Jupyter, Python, and Tableau.  

## Background information
  
Food safety compliance can be measured using the Food Standards Agency's **FHRS** (_Food Hygiene Rating Scheme_) ratings, also known as the 'scores on the doors' for food business premises.

It is a government-backed, nationwide initiative, run by the FSA in partnership with Local Authorities. Its purpose is to give consumers clear information about the hygiene standards of food businesses, so that they can make informed choices.  

Establisments are inspected periodically by their Local Authority - in this case, the London borough in which the business is located - and a rating scored from **0 to 5** is given based on the food safety officer's findings.  

There is no official 'pass or fail' mark, however anything less than **5** indicates shortcomings in food hygiene management, and a **2** rating or below indicates the need for major improvements.  

**Poor ratings can be brand-damaging** - some businesses regard anything less than **5** to be a reputational risk - and can result in financial loss (loss of custom, removal from delivery platforms).**  

## Data sources

| Source | Description | Access |
|---|---|---|
| [FSA Food Hygiene Rating Scheme API](https://api.ratings.food.gov.uk/Help) | Establishment-level FHRS ratings, UK-wide | Free, keyless |
| [ONS Postcode to LSOA lookup](https://open-geography-portalx-ons.hub.arcgis.com/) | Maps postcode to 2021 LSOA geography, November 2025 | Free download |
| [English Indices of Deprivation 2025](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2025) | LSOA-level deprivation - overall index + 7 domains | Free download |

All data is scoped to London (33 boroughs, ~81,000 establishments as of the most recent pull).  

**LSOA** (Lower Layer Super Output Area) is a small geographic unit designed by the Office for National Statistics, for reporting local census and statistical data.  

## Pipeline

| Notebook | Purpose |
|---|---|
| `01_data_exploration.ipynb` | FSA API exploration, London authority filtering, full establishment pull with pagination handling |
| `02_data_cleaning.ipynb` | Null-value investigation (scores, geocode, postcode), postcode-quality tiering, DataFrame cleanup |
| `03_ons_join.ipynb` | Postcode to LSOA join (full + sector-level 'fallback'), IMD 2025 overall decile join, deprivation/rating significance testing |
| `04_imd_domain_join.ipynb` | IMD 2025 _domain-level_ data (Income, Employment, Education, Health, Crime, Barriers, Living Environment) join and testing |
| `05_modelling.ipynb` | Model build, comparison, and selection; final classifier and risk-scoring model |
| `06_scoring.ipynb` | Applies model outputs to full London dataset, outputs single scored table |

Each notebook loads its input from `data/processed/` (or `data/raw/` for the first notebook) rather than depending on in-memory state, and saves its own output. The pipeline can be re-run end-to-end from a clean environment.

## Key findings

- **Deprivation correlates with hygiene rating, but modestly.** _Kruskal-Wallis_ testing confirmed a statistically significant relationship between IMD decile and rating tier, but with a small effect size (ε² ≈ 0.02), inicating a useable signal, not a strong standalone predictor.
- **Income is the strongest individual deprivation domain**; **Living Environment** is essentially unrelated to rating outcome within London. This is likely a national-vs-urban comparison artefact (as London scores poorly on this domain regardless of local affluence, a pattern independently corroborated by other London-specific deprivation analysis).
- **Severely poor ("critical", ≤2) ratings are genuinely hard to separate** with the available features. This held true across every approach tested - three-tier and binary logistic regression, and both weighted and unweighted ordinal regression - pointing to an intrinsic feature/signal limitation rather than a fixable modelling choice.
- The strongest working model targets a different, better-supported question: **whether an establishment is likely to fall short of a 5 rating** (`lt5`, i.e. `<5`), using business type, borough, and income decile. Test set yielded **63%** accuracy, 'fail rating' F1 **0.55**, 'pass rating' F1 **0.69**.
- A separate, unweighted version of the same model produces a **calibrated risk score** (predicted probability of falling below 5) rather than a binary call - validated via a calibration curve, and arguably a more honest and practically useful output than a single yes/no classification.   

## Repository structure

```
fhrs-london-insights/
├── data/
│   ├── raw/                 # API pulls & downloaded source files (not tracked)
│   └── processed/           # Cleaned/joined tables (not tracked)
├── notebooks/               # 01-06, see 'Pipeline' above
├── models/                  # Saved classifier + risk-scorer (joblib), feature list, model card
├── sql/                     # Snowflake SQL (archived worksheets from Snowsight)
├── outputs/                 # Tableau-ready exports (scored data & lean fallback, aggregate views)
├── requirements.txt         # Minimal runtime dependencies
├── requirements-dev.txt     # Full dev environment (incl. Jupyter)
└── README.md
```

## Tech stack

Python (pandas, numpy, scikit-learn, statsmodels, scipy, matplotlib, seaborn) · Jupyter ·
Snowflake · Tableau Public

## Reproducibility

This project is structured as a sequence of self-contained Jupyter notebooks (`01`–`06`), each loading its inputs from disk rather than depending on another notebook's in-memory state. Reproducing the full pipeline means running them in numbered order.

Notebooks are intentionally the primary artifact here - they preserve the analytical reasoning and decisions behind the pipeline, not just its output, which is a more useful record for a portfolio project than a stripped-down production script would be.  

A potential future enhancement may involve a 'productionised' output-only pipeline, but due to time constraints (and the value of showing my working) I'll keep the _notebooks-as-pipeline_ approach for now.  

## Status

- [x] Data pipeline (extraction, cleaning, LSOA/deprivation joins)
- [x] Statistical analysis & modelling
- [x] Snowflake SQL transforms
- [ ] Tableau Public dashboard

## Known limitations

- ~13% of establishments couldn't be matched to an LSOA at usable precision (mostly mobile/non-fixed-premises businesses without a fixed geocodable address) and are excluded from deprivation-dependent analysis.
- The modelling population (establishments with a full deprivation match) is not perfectly representative of the full London dataset - see notebook 05 for details.
- See `models/model_card.json` for full model-level limitations and metrics.   