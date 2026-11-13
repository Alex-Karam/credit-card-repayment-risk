# Credit Card Repayment Risk

A guided portfolio study of next-month credit card default in a historical Taiwanese cohort. I used MySQL to audit and reshape repayment history, Python to evaluate a logistic regression model, Power BI to report the training and test results, and Excel to reconcile the overall training default rate.

[Portfolio case study](https://alex-karam.github.io/projects/credit-card-repayment-risk/index.html) · [Two-page Power BI report (PDF)](Credit%20Card%20Repayment%20Risk.pdf)

## Findings

- In the training set, the observed default rate rose from **11.44%** for clients with zero documented delay months (1,361 of 11,902) to **69.86%** for clients with six (568 of 813). The training rate was **22.12%** overall (3,982 of 18,000), which the Excel PivotTable reproduced from the SQL counts.
- The training default rate was **36.90%** below an NT$50,000 credit limit and **15.11%** at NT$200,000 and above. These rates describe the groups in this cohort.
- Logistic regression improved on the constant-probability baseline on all four held-out metrics. In the largest calibration band, the mean predicted rate was **13.80%** and the observed rate was **13.83%** across 3,405 clients. The 90–100% band contained two clients.
- A hypothetical queue for the highest-scored **10%** of test clients captured **415 of 1,327 defaults** (31.27% capture, 3.13× lift). At **20%** capacity it captured **673** (50.72%, 2.54× lift). The larger queue reviewed 600 additional clients and captured 258 additional defaults.

| Held-out metric | Constant baseline | Logistic regression |
|---|---:|---:|
| ROC AUC | 0.5000 | 0.7719 |
| Average precision | 0.2212 | 0.5527 |
| Brier score | 0.1723 | 0.1354 |
| Log loss | 0.5284 | 0.4350 |

## Data and evaluation

The dataset has 30,000 client records, repayment history for April–September 2005, and a next-month default-payment flag. Amounts are in New Taiwan dollars. The [source manifest](data/source_manifest.json) identifies the exact Kaggle CSV and ZIP by SHA-256. I-Cheng Yeh is credited in the original dataset record. [UCI dataset and attribution](https://doi.org/10.24432/C55S3H) · [Kaggle source used](https://www.kaggle.com/datasets/uciml/default-of-credit-card-clients-dataset)

The model used 19 financial predictors and a fixed stratified client split of 18,000 training, 6,000 validation and 6,000 test records. Preprocessing and fitting used the training set. The baseline assigned every client the training default rate. Validation set the review cutoff at approximately **27.01%** using a 20% capacity. Applying that same cutoff to test flagged **1,267 clients** (21.12%), catching **695 defaults**. The fixed-capacity queues in the report rank each test client by score, with client ID breaking ties.

All three samples come from the same 2005 cohort. Performance on later periods and other populations remains unverified. The review exercise counts observed defaults in a hypothetical queue. It does not estimate defaults prevented or financial savings.

## Reproduce locally

1. Use Python 3.14.6 on Windows and install the [pinned dependencies](requirements.txt) with `python -m pip install -r requirements.txt`. Place the extracted `UCI_Credit_Card.csv` in `data/raw` and check its hash against the manifest.
2. From the project folder, open [01_data_understanding.ipynb](01_data_understanding.ipynb). Run through the cell that writes `data/client_split.csv`. The following cells use the MySQL feature export.
3. In MySQL Workbench, run [01_schema.sql](sql/01_schema.sql) on a fresh project schema. Use the import folder returned by the first query in [02_import.sql](sql/02_import.sql), copy the raw and split CSVs there, and adjust the two file paths as needed. The verified raw CSV uses LF and the Windows-generated split uses CRLF. Match `LINES TERMINATED BY` to the actual files. Check 30,000 clients and 6,636 defaults after import.
4. Run [03_monthly_history.sql](sql/03_monthly_history.sql), then [04_client_features.sql](sql/04_client_features.sql). Export the final result grid from `04_client_features.sql` to `data/client_features.csv` and the seven-group training delay summary from `03_monthly_history.sql` to `data/training_delay_summary.csv`. Include column headers in both exports.
5. Restart and run the two notebooks in order. [02_model_development.ipynb](02_model_development.ipynb) writes four CSVs under `data/model_evaluation`. On the verified local rerun, the split and all four evaluation CSVs matched the earlier outputs byte for byte.
6. **Optional reporting checks with your own Power BI and Excel files.** Refresh the local Power BI report against the MySQL training query and the four test CSVs. Refresh the Excel audit from `data/training_delay_summary.csv` and refresh its PivotTable. Its grand total should be 18,000 clients, 3,982 defaults and 22.12%.

The public release includes the report PDF. Steps 1–5 reproduce the analysis using source data you obtain locally. Step 6 describes the checks I ran on my local Power BI report and Excel audit workbook.
