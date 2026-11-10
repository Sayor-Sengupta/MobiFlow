---- Creating Schema --------------
CREATE TABLE public.transactions (
    step INTEGER,
    payment_type VARCHAR(20),
    amount NUMERIC(18, 2),
    origin_customer_id VARCHAR(30),
    origin_old_balance NUMERIC(18, 2),
    origin_new_balance NUMERIC(18, 2),
    destination_customer_id VARCHAR(30),
    destination_old_balance NUMERIC(18, 2),
    destination_new_balance NUMERIC(18, 2),
    is_fraud SMALLINT,
    is_flagged_fraud SMALLINT,
    transaction_id BIGINT PRIMARY KEY,
    transaction_day INTEGER,
    hour_of_day INTEGER,
    transaction_amount_band VARCHAR(20),
    is_high_value SMALLINT,
    is_origin_balance_drained SMALLINT
);


---- BASIC Validation ---------
SELECT * FROM transactions limit 50
SELECT COUNT(*) from transactions 
SELECT
    COUNT(*) FILTER (WHERE step IS NULL) AS step_nulls,
    COUNT(*) FILTER (WHERE payment_type IS NULL) AS payment_type_nulls,
    COUNT(*) FILTER (WHERE amount IS NULL) AS amount_nulls,
    COUNT(*) FILTER (WHERE origin_customer_id IS NULL) AS origin_customer_id_nulls,
    COUNT(*) FILTER (WHERE origin_old_balance IS NULL) AS origin_old_balance_nulls,
    COUNT(*) FILTER (WHERE origin_new_balance IS NULL) AS origin_new_balance_nulls,
    COUNT(*) FILTER (WHERE destination_customer_id IS NULL) AS destination_customer_id_nulls,
    COUNT(*) FILTER (WHERE destination_old_balance IS NULL) AS destination_old_balance_nulls,
    COUNT(*) FILTER (WHERE destination_new_balance IS NULL) AS destination_new_balance_nulls,
    COUNT(*) FILTER (WHERE is_fraud IS NULL) AS is_fraud_nulls,
    COUNT(*) FILTER (WHERE is_flagged_fraud IS NULL) AS is_flagged_fraud_nulls,
    COUNT(*) FILTER (WHERE transaction_id IS NULL) AS transaction_id_nulls,
    COUNT(*) FILTER (WHERE transaction_day IS NULL) AS transaction_day_nulls,
    COUNT(*) FILTER (WHERE hour_of_day IS NULL) AS hour_of_day_nulls,
    COUNT(*) FILTER (WHERE transaction_amount_band IS NULL) AS transaction_amount_band_nulls,
    COUNT(*) FILTER (WHERE is_high_value IS NULL) AS is_high_value_nulls,
    COUNT(*) FILTER (WHERE is_origin_balance_drained IS NULL) AS is_origin_balance_drained_nulls
FROM transactions;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT transaction_id) AS unique_transaction_ids
FROM public.transactions;

SELECT
    payment_type,
    COUNT(*) AS transaction_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM public.transactions
GROUP BY payment_type
ORDER BY transaction_count DESC;

SELECT
    MIN(amount) AS minimum_amount,
    MAX(amount) AS maximum_amount,
    ROUND(AVG(amount), 2) AS average_amount,
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY amount) AS median_amount
FROM public.transactions;
