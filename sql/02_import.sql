SELECT
    @@GLOBAL.secure_file_priv AS server_import_folder,
    @@GLOBAL.local_infile AS server_allows_local_infile;

########################################################
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/UCI_Credit_Card.csv'
INTO TABLE credit_card_repayment_risk.clients
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT
    COUNT(*) AS client_count,
    SUM(default_payment_next_month) AS default_count
FROM credit_card_repayment_risk.clients;
    
########################################################
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/client_split.csv'
INTO TABLE credit_card_repayment_risk.sample_split
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(client_id, split_name);

SELECT
    s.split_name,
    COUNT(*) AS client_count,
    SUM(c.default_payment_next_month) AS default_count
FROM credit_card_repayment_risk.sample_split AS s
JOIN credit_card_repayment_risk.clients AS c
    ON c.client_id = s.client_id
GROUP BY s.split_name
ORDER BY FIELD(s.split_name, 'train', 'validation', 'test');

########################################################
    
SELECT
    SUM(limit_bal) AS total_credit_limit,
    SUM(bill_amt1) AS september_bills,
    SUM(pay_amt1) AS september_payments
FROM credit_card_repayment_risk.clients;

########################################################
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    