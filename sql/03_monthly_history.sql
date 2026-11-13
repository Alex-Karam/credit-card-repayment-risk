USE credit_card_repayment_risk;

CREATE VIEW v_monthly_repayments AS
SELECT
    client_id,
    CAST('2005-09-01' AS DATE) AS month_start,
    pay_0 AS repayment_status,
    bill_amt1 AS bill_amount,
    pay_amt1 AS payment_amount
FROM clients
UNION ALL
SELECT client_id, CAST('2005-08-01' AS DATE), pay_2, bill_amt2, pay_amt2
FROM clients
UNION ALL
SELECT client_id, CAST('2005-07-01' AS DATE), pay_3, bill_amt3, pay_amt3
FROM clients
UNION ALL
SELECT client_id, CAST('2005-06-01' AS DATE), pay_4, bill_amt4, pay_amt4
FROM clients
UNION ALL
SELECT client_id, CAST('2005-05-01' AS DATE), pay_5, bill_amt5, pay_amt5
FROM clients
UNION ALL
SELECT client_id, CAST('2005-04-01' AS DATE), pay_6, bill_amt6, pay_amt6
FROM clients;

SELECT
    COUNT(*) AS monthly_rows,
    MIN(month_start) AS first_month,
    MAX(month_start) AS last_month
FROM v_monthly_repayments;

########################################################

SELECT
    c.client_id,
    COUNT(m.month_start) AS monthly_rows,
    COUNT(DISTINCT m.month_start) AS distinct_months
FROM clients AS c
LEFT JOIN v_monthly_repayments AS m
    ON m.client_id = c.client_id
GROUP BY c.client_id
HAVING COUNT(m.month_start) <> 6
    OR COUNT(DISTINCT m.month_start) <> 6;

########################################################

SELECT
    client_id,
    month_start,
    bill_amount,
    LAG(bill_amount) OVER (
        PARTITION BY client_id
        ORDER BY month_start
    ) AS previous_bill_amount
FROM v_monthly_repayments
WHERE client_id = (
    SELECT MIN(client_id)
    FROM sample_split
    WHERE split_name = 'train'
)
ORDER BY month_start;

########################################################

SELECT
    m.client_id,
    COUNT(*) AS months_recorded,
    SUM(CASE WHEN m.repayment_status BETWEEN 1 AND 9 THEN 1 ELSE 0 END)
        AS delayed_months,
    SUM(CASE WHEN m.repayment_status IN (-2, 0) THEN 1 ELSE 0 END)
        AS undocumented_months
FROM v_monthly_repayments AS m
JOIN sample_split AS s
    ON s.client_id = m.client_id
WHERE s.split_name = 'train'
GROUP BY m.client_id
ORDER BY m.client_id
LIMIT 10;

########################################################

WITH delays_per_client AS (
    SELECT
        m.client_id,
        SUM(CASE WHEN m.repayment_status BETWEEN 1 AND 9 THEN 1 ELSE 0 END)
            AS documented_delay_months
    FROM v_monthly_repayments AS m
    JOIN sample_split AS s
        ON s.client_id = m.client_id
    WHERE s.split_name = 'train'
    GROUP BY m.client_id
)
SELECT
    d.documented_delay_months,
    COUNT(*) AS client_count,
    SUM(c.default_payment_next_month) AS default_count,
    ROUND(100.0 * SUM(c.default_payment_next_month) / COUNT(*), 2)
        AS default_rate_pct
FROM delays_per_client AS d
JOIN clients AS c
    ON c.client_id = d.client_id
GROUP BY d.documented_delay_months
ORDER BY d.documented_delay_months;

########################################################

SELECT
    c.pay_0 AS september_status,
    COUNT(*) AS client_count,
    SUM(c.default_payment_next_month) AS default_count,
    ROUND(100 * AVG(c.default_payment_next_month), 2) AS default_rate_pct
FROM clients AS c
JOIN sample_split AS s
    ON s.client_id = c.client_id
WHERE s.split_name = 'train'
GROUP BY c.pay_0
ORDER BY c.pay_0;

########################################################

WITH training_clients AS (
    SELECT
        c.limit_bal,
        c.default_payment_next_month,
        CASE
            WHEN c.limit_bal < 50000 THEN 'Under 50,000'
            WHEN c.limit_bal < 100000 THEN '50,000 to under 100,000'
            WHEN c.limit_bal < 200000 THEN '100,000 to under 200,000'
            ELSE '200,000 and above'
        END AS credit_limit_band
    FROM clients AS c
    JOIN sample_split AS s
        ON s.client_id = c.client_id
    WHERE s.split_name = 'train'
)
SELECT
    credit_limit_band,
    COUNT(*) AS client_count,
    SUM(default_payment_next_month) AS default_count,
    ROUND(100 * AVG(default_payment_next_month), 2) AS default_rate_pct
FROM training_clients
GROUP BY credit_limit_band
ORDER BY MIN(limit_bal);

########################################################

SELECT
    m.month_start,
    COUNT(*) AS client_count,
    ROUND(AVG(m.bill_amount), 2) AS avg_bill_ntd,
    ROUND(AVG(m.payment_amount), 2) AS avg_payment_ntd,
    SUM(CASE WHEN m.bill_amount < 0 THEN 1 ELSE 0 END)
        AS negative_bill_count,
    SUM(CASE WHEN m.payment_amount = 0 THEN 1 ELSE 0 END)
        AS zero_payment_count
FROM v_monthly_repayments AS m
JOIN sample_split AS s
    ON s.client_id = m.client_id
WHERE s.split_name = 'train'
GROUP BY m.month_start
ORDER BY m.month_start;

########################################################

SELECT
    c.client_id,
    c.limit_bal AS credit_limit_ntd,
    c.bill_amt2 AS august_bill_ntd,
    c.bill_amt1 AS september_bill_ntd,
    c.pay_amt1 AS september_payment_ntd,
    c.pay_0 AS september_status
FROM clients AS c
JOIN sample_split AS s
    ON s.client_id = c.client_id
WHERE s.split_name = 'train'
    AND c.bill_amt1 < 0
ORDER BY c.bill_amt1, c.client_id
LIMIT 5;

########################################################
































