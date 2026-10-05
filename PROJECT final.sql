CREATE DATABASE Customers_transactions;
UPDATE customers SET Gender=NULL WHERE Gender='';
UPDATE customers SET Age=NULL WHERE Age='';
ALTER TABLE customers MODIFY Age INT NULL;

SELECT*FROM customers;
SELECT*FROM Transactions;
DROP TABLE Transactions;

CREATE TABLE Transactions
(date_new DATE,
Id_check INT,
ID_client INT ,
Count_products DECIMAL(10,3),
Sum_payment VARCHAR(50));

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions_info.xlsx - TRANSACTIONS  FINAL VAR.csv"
INTO TABLE Transactions
FIELDS TERMINATED BY','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SHOW VARIABLES LIKE 'secure_file_priv';

SELECT Sum_payment
FROM Transactions
LIMIT 20;


UPDATE Transactions
SET Sum_payment = TRIM(SUBSTRING_INDEX(Sum_payment, ';', 1));

ALTER TABLE Transactions
MODIFY COLUMN Sum_payment DECIMAL(10,2);




#EXERCISE 1

SELECT ID_client,
COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) AS active_months,
SUM(Sum_payment) AS total_sum,
COUNT(DISTINCT Id_check) AS operations_count,
SUM(Sum_payment) * 1.0 / COUNT(DISTINCT Id_check) AS average_check,
SUM(Sum_payment) * 1.0 / 12 AS average_month_sum
FROM Transactions
WHERE date_new >= '2015-06-01'
AND date_new < '2016-06-01'
GROUP BY ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) = 12
ORDER BY ID_client;


#EXERCISE 2(a)

SELECT
MONTH(date_new) AS month_date,
SUM(Sum_payment) AS total_sum,
COUNT(DISTINCT Id_check) AS operations_count,
SUM(Sum_payment) * 1.0 / COUNT(DISTINCT Id_check) AS avg_check
FROM Transactions
WHERE date_new >= '2015-06-01'
AND date_new < '2016-06-01'
GROUP BY MONTH(date_new)
ORDER BY month_date;




#EXERCISE 2(b)
SELECT
COUNT(DISTINCT Id_check) * 1.0 / 12 AS avg_operations_month
FROM Transactions
WHERE date_new >= '2015-06-01'
AND date_new < '2016-06-01';



#EXERCISE 2(c)

SELECT
AVG(clients_count) AS avg_clients_per_month
FROM (
SELECT
YEAR(date_new) AS year_date,
MONTH(date_new) AS month_date,
COUNT(DISTINCT ID_client) AS clients_count
FROM Transactions
WHERE date_new >= '2015-06-01'
AND date_new < '2016-06-01'
GROUP BY YEAR(date_new), MONTH(date_new)
) AS monthly_clients;


#EXERCISE 2(d)

SELECT
YEAR(date_new) AS year_date,
MONTH(date_new) AS month_date,
COUNT(DISTINCT Id_check) AS operations_count,
COUNT(DISTINCT Id_check) * 100.0 /
(
SELECT COUNT(DISTINCT Id_check)
FROM Transactions
WHERE date_new >= '2015-06-01'
AND date_new < '2016-06-01'
) AS operations_percent,
SUM(Sum_payment) AS month_sum,
SUM(Sum_payment) * 100.0 /
(
SELECT SUM(Sum_payment)
FROM Transactions
WHERE date_new >= '2015-06-01'
AND date_new < '2016-06-01'
) AS sum_percent
FROM Transactions
WHERE date_new >= '2015-06-01'
AND date_new < '2016-06-01'
GROUP BY YEAR(date_new), MONTH(date_new)
ORDER BY  year_date,month_date;

#EXERCISE 2(e)

 WITH gender_rate AS
(
SELECT
DATE_FORMAT(t.date_new, '%Y-%m') AS months,
IFNULL(c.Gender, 'NA') AS gender,
COUNT(DISTINCT t.ID_client) AS client_count,
SUM(t.Sum_payment) AS sum_payment
FROM Transactions t
JOIN customers c
ON t.ID_client = c.Id_client
WHERE t.date_new >= '2015-06-01'
	AND t.date_new < '2016-06-01'
GROUP BY DATE_FORMAT(t.date_new, '%Y-%m'),IFNULL(c.Gender, 'NA')
)

SELECT months,gender,client_count * 100.0 /SUM(client_count) OVER (PARTITION BY months) AS gender_rate,sum_payment * 100.0 /SUM(sum_payment) OVER (PARTITION BY months) AS payment_rate
FROM gender_rate
ORDER BY months,gender;

  
  
  
  #EXERCISE 3
  
SELECT
CASE
WHEN c.Age IS NULL THEN 'NA'
ELSE CONCAT(FLOOR(c.Age / 10) * 10, '-',
FLOOR(c.Age / 10) * 10 + 9)
END AS age_group,
SUM(t.Sum_payment) AS total_sum,
COUNT(DISTINCT t.Id_check) AS operations_count,
SUM(t.Sum_payment) * 1.0 /
COUNT(DISTINCT t.Id_check) AS avg_check
FROM Transactions t
JOIN customers c
ON t.ID_client = c.Id_client
WHERE t.date_new >= '2015-06-01'
AND t.date_new < '2016-06-01'
GROUP BY age_group
ORDER BY age_group;

#QUARTER

SELECT
QUARTER(t.date_new) AS quarter_date,
CASE
WHEN c.Age IS NULL THEN 'NA'
ELSE CONCAT(FLOOR(c.Age / 10) * 10, '-',
FLOOR(c.Age / 10) * 10 + 9)
END AS age_group,
SUM(t.Sum_payment) AS total_sum,
COUNT(DISTINCT t.Id_check) AS operations_count,
SUM(t.Sum_payment) * 1.0 /
COUNT(DISTINCT t.Id_check) AS avg_check,
SUM(t.Sum_payment) * 100.0 /
(
SELECT SUM(Sum_payment)
FROM Transactions
WHERE date_new >= '2015-06-01'
AND date_new < '2016-06-01'
) AS percent_sum
FROM Transactions t
JOIN customers c
ON t.ID_client = c.Id_client
WHERE t.date_new >= '2015-06-01'
AND t.date_new < '2016-06-01'
GROUP BY QUARTER(t.date_new), age_group
ORDER BY quarter_date,age_group;
