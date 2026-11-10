SELECT * FROM transactions limit 100

---------------- Overall transaction KPIs - What is the overall scale and value of transaction activity?----------------

SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT origin_customer_id) AS unique_senders,
    COUNT(DISTINCT destination_customer_id) AS unique_receivers,
    ROUND(SUM(amount), 2) AS total_transaction_value,
    ROUND(AVG(amount), 2) AS average_transaction_value,
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY amount)::NUMERIC, 2
    ) AS median_transaction_value,
    ROUND(MIN(amount), 2) AS minimum_transaction_value,
    ROUND(MAX(amount), 2) AS maximum_transaction_value
FROM public.transactions;

--------------- Transaction performance by payment type ------------------
-- Which transaction type contributes the most value?
-- Which transaction type has the highest average transaction amount?
-- Does transaction value contribution differ from transaction volume contribution?

SELECT
    payment_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_transaction_value,
    ROUND(AVG(amount), 2) AS average_transaction_value,
    ROUND(
        SUM(amount) * 100.0 /
        SUM(SUM(amount)) OVER (), 2
    ) AS value_contribution_pct,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (), 2
    ) AS volume_contribution_pct
FROM public.transactions
GROUP BY payment_type
ORDER BY total_transaction_value DESC;


--------------Transaction activity by simulated day -  The dataset covers 744 simulated hours, equivalent to 31 days. ------------
-- Which simulated day has the highest transaction volume?
-- Is transaction activity consistent throughout the 31 days?
-- Are there noticeable changes in transaction value?

SELECT
    transaction_day,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_transaction_value,
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM public.transactions
GROUP BY transaction_day
ORDER BY transaction_day;


---------- Hourly transaction patterns -----------
-- Which simulated hour has the highest transaction volume?
-- When is transaction activity lowest?
-- Does average transaction value change across hours?

SELECT
    hour_of_day,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_transaction_value,
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM public.transactions
GROUP BY hour_of_day
ORDER BY hour_of_day;

------------- Payment type by simulated hour -----------
-- Does CASH_OUT dominate particular hours?
-- Are PAYMENT transactions distributed differently from TRANSFER transactions?
-- Which payment types contribute most during peak hours?
SELECT
    hour_of_day,
    payment_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_transaction_value
FROM public.transactions
GROUP BY hour_of_day, payment_type
ORDER BY hour_of_day, transaction_count DESC;
---------------- Customer transaction activity ------------------
-- Which accounts generate the highest transaction value?
-- Which accounts transact most frequently?
-- Is transaction activity concentrated among a small number of accounts?

SELECT
    origin_customer_id,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_transaction_value,
    ROUND(AVG(amount), 2) AS average_transaction_value,
    ROUND(MAX(amount), 2) AS highest_transaction
FROM public.transactions
GROUP BY origin_customer_id
ORDER BY total_transaction_value DESC
LIMIT 20;

------ Customer balance movement ------------------
-- Which payment types are associated with the largest aggregate decrease in origin balances?
-- How does balance movement differ across payment types?
SELECT
    payment_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(origin_old_balance), 2) AS opening_balance_total,
    ROUND(SUM(origin_new_balance), 2) AS closing_balance_total,
    ROUND(
        SUM(origin_old_balance - origin_new_balance), 2
    ) AS balance_decrease_total
FROM public.transactions
GROUP BY payment_type
ORDER BY balance_decrease_total DESC;

-------------- High-value transaction analysis ---------------
-- Which payment types account for the highest-value transactions?
-- Where is high-value transaction activity concentrated
SELECT
    payment_type,
    COUNT(*) AS high_value_transactions,
    ROUND(SUM(amount), 2) AS total_transaction_value,
    ROUND(AVG(amount), 2) AS average_transaction_value,
    ROUND(MAX(amount), 2) AS maximum_transaction_value
FROM public.transactions
WHERE is_high_value = 1
GROUP BY payment_type
ORDER BY total_transaction_value DESC;


-------------- Customer Transaction Frequency Concentration Analysis -----------



WITH account_activity AS (
    SELECT
        origin_customer_id,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_transaction_value
    FROM public.transactions
    GROUP BY origin_customer_id
),
ranked_accounts AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY transaction_count DESC, origin_customer_id
        ) AS account_rank,
        COUNT(*) OVER () AS total_accounts
    FROM account_activity
)
SELECT
    ROUND(
        SUM(transaction_count) FILTER (
            WHERE account_rank <= CEIL(total_accounts * 0.01)
        ) * 100.0 / SUM(transaction_count),
        2
    ) AS top_1_pct_transaction_share,

    ROUND(
        SUM(transaction_count) FILTER (
            WHERE account_rank <= CEIL(total_accounts * 0.05)
        ) * 100.0 / SUM(transaction_count),
        2
    ) AS top_5_pct_transaction_share,

    ROUND(
        SUM(transaction_count) FILTER (
            WHERE account_rank <= CEIL(total_accounts * 0.10)
        ) * 100.0 / SUM(transaction_count),
        2
    ) AS top_10_pct_transaction_share

FROM ranked_accounts;






--------------- Transaction value concentration ----------------------
WITH account_activity AS (
    SELECT
        origin_customer_id,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_transaction_value
    FROM public.transactions
    GROUP BY origin_customer_id
),
ranked_accounts AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY total_transaction_value DESC,
                     origin_customer_id
        ) AS account_rank,
        COUNT(*) OVER () AS total_accounts
    FROM account_activity
)
SELECT
    ROUND(
        SUM(total_transaction_value) FILTER (
            WHERE account_rank <= CEIL(total_accounts * 0.01)
        ) * 100.0 / SUM(total_transaction_value), 2
    ) AS top_1_pct_value_share,

    ROUND(
        SUM(total_transaction_value) FILTER (
            WHERE account_rank <= CEIL(total_accounts * 0.05)
        ) * 100.0 / SUM(total_transaction_value), 2
    ) AS top_5_pct_value_share,

    ROUND(
        SUM(total_transaction_value) FILTER (
            WHERE account_rank <= CEIL(total_accounts * 0.10)
        ) * 100.0 / SUM(total_transaction_value), 2
    ) AS top_10_pct_value_share

FROM ranked_accounts;




----------- Destination account activity -------------------
SELECT
    destination_customer_id,
    COUNT(*) AS incoming_transaction_count,
    ROUND(SUM(amount), 2) AS total_incoming_value,
    ROUND(AVG(amount), 2) AS average_incoming_value
FROM public.transactions
GROUP BY destination_customer_id
ORDER BY total_incoming_value DESC
LIMIT 20;


-- Top destination accounts by transaction frequency
-- Business question: Which destination accounts receive the highest number of transactions?
SELECT
    destination_customer_id,
    COUNT(*) AS incoming_transaction_count,
    ROUND(SUM(amount), 2) AS total_incoming_value,
    ROUND(AVG(amount), 2) AS average_incoming_value
FROM public.transactions
GROUP BY destination_customer_id
ORDER BY incoming_transaction_count DESC
LIMIT 20;

-- Destination account value concentration
-- Business question: What percentage of total incoming transaction value is received by the top 1%, 5% and 10% of destination accounts?
WITH destination_activity AS (
    SELECT
        destination_customer_id,
        COUNT(*) AS incoming_transaction_count,
        SUM(amount) AS total_incoming_value
    FROM public.transactions
    GROUP BY destination_customer_id
),
ranked_destinations AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY total_incoming_value DESC,
                     destination_customer_id
        ) AS account_rank,
        COUNT(*) OVER () AS total_accounts
    FROM destination_activity
)
SELECT
    ROUND(
        SUM(total_incoming_value) FILTER (
            WHERE account_rank <= CEIL(total_accounts * 0.01)
        ) * 100.0 / SUM(total_incoming_value), 2
    ) AS top_1_pct_value_share,

    ROUND(
        SUM(total_incoming_value) FILTER (
            WHERE account_rank <= CEIL(total_accounts * 0.05)
        ) * 100.0 / SUM(total_incoming_value), 2
    ) AS top_5_pct_value_share,

    ROUND(
        SUM(total_incoming_value) FILTER (
            WHERE account_rank <= CEIL(total_accounts * 0.10)
        ) * 100.0 / SUM(total_incoming_value), 2
    ) AS top_10_pct_value_share

FROM ranked_destinations;

-- Merchant vs customer destination analysis
-- PaySim uses destination IDs beginning with M to represent merchant accounts. Other destination IDs represent customer accounts.
-- Business question: How does incoming transaction activity differ between merchant and customer destinations?
SELECT
    CASE
        WHEN destination_customer_id LIKE 'M%'
            THEN 'Merchant'
        ELSE 'Customer'
    END AS destination_type,

    COUNT(*) AS incoming_transaction_count,
    COUNT(DISTINCT destination_customer_id) AS unique_destinations,
    ROUND(SUM(amount), 2) AS total_incoming_value,
    ROUND(AVG(amount), 2) AS average_incoming_value,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
    ) AS transaction_volume_share

FROM public.transactions
GROUP BY
    CASE
        WHEN destination_customer_id LIKE 'M%'
            THEN 'Merchant'
        ELSE 'Customer'
    END
ORDER BY total_incoming_value DESC;

