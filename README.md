# Brexfish: Fishing Vessel Landing Decisions Before and After Brexit

**Master's Thesis in Economics | Barcelona School of Economics | June 2024**

[Read the full thesis](Master%20Thesis%20BSE.pdf)

## Overview

How did the non-tariff trade barriers introduced after Brexit affect where European and British fishing vessels land their catch?

This thesis studies the effects of the **EU–UK Trade and Cooperation Agreement (TCA)**, which took effect in January 2021, on fishing vessels' landing decisions. New customs procedures, certification requirements, and associated delays raised the cost of landing across the UK–EU border.

We construct a vessel-level longitudinal dataset using georeferenced fishing and port-visit records, estimate a **mixed logit discrete-choice model**, and simulate a counterfactual scenario without the new trade barriers. The analysis focuses on *where* vessels choose to land, rather than the quantity of fish landed.

## Data

The final sample follows **2,979 vessels from 10 nationalities over 2018–2022**, combining several data sources:

| Source | Data used |
| --- | --- |
| [Global Fishing Watch (GFW)](https://globalfishingwatch.org/) | Vessel characteristics, fishing events, port visits, locations, and fishing-effort measures, retrieved through its APIs |
| [UK Marine Management Organisation (MMO)](https://www.gov.uk/government/organisations/marine-management-organisation) | Landings information and fish prices in UK ports |
| [EUMOFA](https://www.eumofa.eu/) | Fish and seafood price information for EU countries |
| [Eurostat](https://ec.europa.eu/eurostat) | Monthly foreign-tourism overnight stays used as a demand shifter in the price endogeneity analysis |

The data workflow includes API extraction using **R** (`gfwr`), cleaning and linking vessel histories, and geographic processing using **Python** (`GeoPandas`). Fishing events and port visits are matched chronologically to identify relevant landing decisions. The sample is deliberately restricted to vessels with a demonstrated connection to UK–EU landing markets; it is not a representative sample of all European fishing vessels.

## Empirical strategy

We model each landing as a choice among destination countries under a random-utility framework. The **mixed logit model** accommodates repeated choices by the same vessel and heterogeneous responses to trade barriers and fish prices, relaxing the independence-of-irrelevant-alternatives assumption of a standard multinomial logit.

Explanatory variables include:

- Post-Brexit barriers for EU vessels landing in the UK and UK vessels landing in the EU;
- Distance between fishing locations and potential landing destinations;
- Destination-level fish prices and fishing-effort proxies;
- Vessel characteristics, including nationality and fishing gear.

To address potential **price endogeneity**, the empirical strategy applies a **control-function approach** using tourism-related demand variation as an instrumental variable. Estimation and counterfactual predictions are performed in **Stata**.

The estimated model is then used to compare predicted landing choices under the observed post-Brexit trade regime with a **counterfactual scenario in which the new non-tariff barriers are removed**.

## Main findings

- The observed share of EU vessels' landings going to the UK fell from approximately **10% to 5%** around the introduction of the new trade barriers.
- For EU vessels in the model, the predicted post-Brexit probability of landing in the UK is approximately **10% with the barriers**, compared with **17% in the no-barriers counterfactual**.
- The model suggests that EU vessels redirected part of their landings toward nearby destinations, particularly France and Norway.
- The thesis reports a **13.84% decline in its model-based utility/surplus measure for the EU-vessel sample**, compared with **2.49% for UK vessels**.

These are **model-based counterfactual estimates**, conditional on the choice-model specification and sample selection. They should not be interpreted as estimates from a randomized experiment or a quasi-experimental difference-in-differences design. The utility-based surplus measure is not a direct monetary measure of profits.

## Repository contents

```text
Master_Thesis_BSE/
├── Master Thesis BSE.pdf   # Full thesis
├── Results_full_model.do   # Stata model estimation commands and output
├── scripts/                # Supporting scripts
├── figures/                # Figures and graphical outputs
└── README.md
```

The [original thesis PDF](Master%20Thesis%20BSE.pdf) contains the full institutional background, data definitions, model specification, estimation results, and discussion of limitations. The [`Results_full_model.do`](Results_full_model.do) file provides additional details on the Stata model and predicted probabilities.

**Reproducibility note:** This repository contains research code and outputs but is **not a fully automated replication package**. Reproducing the complete workflow requires access to the underlying source datasets, appropriate GFW API credentials, and compatible R, Python, and Stata environments. API interfaces and software versions may have changed since the 2024 project.

Please refer to the [full thesis](Master%20Thesis%20BSE.pdf) for the detailed methodology, references, and interpretation of results.
