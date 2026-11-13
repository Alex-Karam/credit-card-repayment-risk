USE credit_card_repayment_risk;

CREATE VIEW v_customer_features AS
WITH monthly_summary AS (
    SELECT
        client_id,
        SUM(CASE WHEN repayment_status BETWEEN 1 AND 9 THEN 1 ELSE 0 END)
            AS documented_delay_months,
        SUM(CASE WHEN repayment_status IN (-2, 0) THEN 1 ELSE 0 END)
            AS undocumented_months
    FROM v_monthly_repayments
    GROUP BY client_id
)
SELECT
    c.client_id,
    c.limit_bal,
    c.pay_0, c.pay_2, c.pay_3, c.pay_4, c.pay_5, c.pay_6,
    c.bill_amt1, c.bill_amt2, c.bill_amt3,
    c.bill_amt4, c.bill_amt5, c.bill_amt6,
    c.pay_amt1, c.pay_amt2, c.pay_amt3,
    c.pay_amt4, c.pay_amt5, c.pay_amt6,
    m.documented_delay_months,
    m.undocumented_months,
    c.bill_amt1 / NULLIF(c.limit_bal, 0) AS september_bill_to_limit
FROM clients AS c
LEFT JOIN monthly_summary AS m
    ON m.client_id = c.client_id;

SELECT
    COUNT(*) AS feature_rows,
    COUNT(DISTINCT client_id) AS unique_clients,
    COUNT(*) - COUNT(documented_delay_months) AS missing_monthly_summaries,
    SUM(limit_bal) AS total_credit_limit
FROM v_customer_features;

########################################################

SELECT
    f.*,
    s.split_name,
    c.default_payment_next_month
FROM v_customer_features AS f
JOIN sample_split AS s
    ON s.client_id = f.client_id
JOIN clients AS c
    ON c.client_id = f.client_id
ORDER BY f.client_id;

########################################################

































































































































































