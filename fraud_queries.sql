-- ============================================================
-- Fraud Detection & Transaction Monitoring System
-- SQL Queries | Compatible with DuckDB / PostgreSQL
-- ============================================================


-- ─── RULE 1: High Amount Flag ────────────────────────────────
SELECT
    transaction_id,
    amount,
    CASE WHEN amount > 10000 THEN 'HIGH_AMOUNT' ELSE 'NORMAL' END AS amount_flag
FROM transactions;


-- ─── RULE 2: Location Mismatch ───────────────────────────────
SELECT
    transaction_id,
    home_location,
    transaction_location,
    CASE
        WHEN home_location != transaction_location THEN 1
        ELSE 0
    END AS location_mismatch
FROM transactions;


-- ─── RULE 3: International Flag ──────────────────────────────
SELECT
    transaction_id,
    is_international,
    CASE WHEN is_international = 1 THEN 'INTL' ELSE 'DOMESTIC' END AS txn_type
FROM transactions;


-- ─── RULE 4: High Frequency Per Customer Per Day ─────────────
WITH daily_counts AS (
    SELECT
        customer_id,
        CAST(transaction_date AS DATE) AS txn_day,
        COUNT(*) AS daily_txns
    FROM transactions
    GROUP BY customer_id, CAST(transaction_date AS DATE)
)
SELECT
    customer_id,
    txn_day,
    daily_txns,
    CASE WHEN daily_txns >= 5 THEN 1 ELSE 0 END AS high_freq_flag
FROM daily_counts
ORDER BY daily_txns DESC;


-- ─── RISK SCORING (Main Query) ───────────────────────────────
WITH base AS (
    SELECT *,
        CASE WHEN amount > 10000                           THEN 40 ELSE 0 END AS score_amount,
        CASE WHEN home_location != transaction_location    THEN 30 ELSE 0 END AS score_location,
        CASE WHEN is_international = 1                     THEN 20 ELSE 0 END AS score_intl
    FROM transactions
),
scored AS (
    SELECT
        transaction_id,
        customer_id,
        amount,
        merchant,
        category,
        score_amount + score_location + score_intl AS risk_score,
        fraud_flag
    FROM base
)
SELECT
    transaction_id,
    customer_id,
    amount,
    merchant,
    category,
    risk_score,
    CASE
        WHEN risk_score >= 60 THEN 'HIGH'
        WHEN risk_score >= 30 THEN 'MEDIUM'
        ELSE                       'LOW'
    END AS risk_category,
    fraud_flag
FROM scored
ORDER BY risk_score DESC;


-- ─── SUMMARY BY RISK CATEGORY ────────────────────────────────
WITH base AS (
    SELECT *,
        CASE WHEN amount > 10000                        THEN 40 ELSE 0 END AS s1,
        CASE WHEN home_location != transaction_location THEN 30 ELSE 0 END AS s2,
        CASE WHEN is_international = 1                  THEN 20 ELSE 0 END AS s3
    FROM transactions
),
scored AS (
    SELECT *,
        s1 + s2 + s3 AS risk_score,
        CASE
            WHEN s1 + s2 + s3 >= 60 THEN 'HIGH'
            WHEN s1 + s2 + s3 >= 30 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS risk_category
    FROM base
)
SELECT
    risk_category,
    COUNT(*)                              AS total_txns,
    SUM(fraud_flag)                       AS confirmed_fraud,
    ROUND(AVG(amount), 2)                 AS avg_amount,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 1) AS fraud_pct
FROM scored
GROUP BY risk_category
ORDER BY
    CASE risk_category WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 ELSE 3 END;


-- ─── FRAUD BY CATEGORY ───────────────────────────────────────
SELECT
    category,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_count,
    ROUND(SUM(fraud_flag) * 100.0 / COUNT(*), 1) AS fraud_rate_pct
FROM transactions
GROUP BY category
ORDER BY fraud_count DESC;


-- ─── MONTHLY FRAUD TREND ─────────────────────────────────────
SELECT
    DATE_TRUNC('month', CAST(transaction_date AS DATE)) AS month,
    COUNT(*) AS total_txns,
    SUM(fraud_flag) AS fraud_count
FROM transactions
GROUP BY 1
ORDER BY 1;
