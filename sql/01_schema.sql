CREATE SCHEMA IF NOT EXISTS credit_card_repayment_risk;
USE credit_card_repayment_risk;

SELECT DATABASE() AS active_schema;

CREATE TABLE credit_card_repayment_risk.clients (
    client_id INT UNSIGNED PRIMARY KEY,
    limit_bal DECIMAL(12, 2) NOT NULL,
    sex TINYINT UNSIGNED NOT NULL,
    education TINYINT UNSIGNED NOT NULL,
    marriage TINYINT UNSIGNED NOT NULL,
    age TINYINT UNSIGNED NOT NULL,
    pay_0 TINYINT NOT NULL,
    pay_2 TINYINT NOT NULL,
    pay_3 TINYINT NOT NULL,
    pay_4 TINYINT NOT NULL,
    pay_5 TINYINT NOT NULL,
    pay_6 TINYINT NOT NULL,
    bill_amt1 DECIMAL(12, 2) NOT NULL,
    bill_amt2 DECIMAL(12, 2) NOT NULL,
    bill_amt3 DECIMAL(12, 2) NOT NULL,
    bill_amt4 DECIMAL(12, 2) NOT NULL,
    bill_amt5 DECIMAL(12, 2) NOT NULL,
    bill_amt6 DECIMAL(12, 2) NOT NULL,
    pay_amt1 DECIMAL(12, 2) NOT NULL,
    pay_amt2 DECIMAL(12, 2) NOT NULL,
    pay_amt3 DECIMAL(12, 2) NOT NULL,
    pay_amt4 DECIMAL(12, 2) NOT NULL,
    pay_amt5 DECIMAL(12, 2) NOT NULL,
    pay_amt6 DECIMAL(12, 2) NOT NULL,
    default_payment_next_month TINYINT UNSIGNED NOT NULL,
    CONSTRAINT chk_clients_default_flag
        CHECK (default_payment_next_month IN (0, 1))
);

SHOW TABLES FROM credit_card_repayment_risk;

CREATE TABLE credit_card_repayment_risk.sample_split (
    client_id INT UNSIGNED PRIMARY KEY,
    split_name VARCHAR(10) NOT NULL,
    CONSTRAINT chk_sample_split_name
        CHECK (split_name IN ('train', 'validation', 'test')),
    CONSTRAINT fk_sample_split_client
        FOREIGN KEY (client_id)
        REFERENCES credit_card_repayment_risk.clients (client_id)
);

SHOW TABLES FROM credit_card_repayment_risk;





