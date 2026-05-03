# Fraud Detection & Transaction Monitoring System

**SQL-based risk scoring for banking transactions**

---

## Problem

Banks process millions of transactions daily but lack a fast, lightweight way to flag suspicious activity. Most fraud is caught too late — after the money is gone. This project builds a rule-based detection system using pure SQL.

---

## Approach

1. **Generate data** — 6,000 synthetic transactions with realistic fraud patterns  
2. **Write SQL rules** — 4 conditions: high amount, location mismatch, international flag, high frequency  
3. **Score transactions** — simple addition: each rule adds points (40 / 30 / 20)  
4. **Categorize risk** — HIGH (≥60), MEDIUM (≥30), LOW (<30)  
5. **Visualize** — HTML dashboard with 4 charts

---

## Dataset

| Column | Description |
|---|---|
| `transaction_id` | Unique ID |
| `customer_id` | Linked customer |
| `amount` | Transaction value (₹) |
| `home_location` | Customer's home city |
| `transaction_location` | Where the txn happened |
| `is_international` | 0 or 1 |
| `fraud_flag` | Ground truth label |

6,000 rows · 600 customers · 9.3% fraud rate

---

## SQL Rules

| Rule | Condition | Points |
|---|---|---|
| R1 | `amount > 10,000` | +40 |
| R2 | `home_location != transaction_location` | +30 |
| R3 | `is_international = 1` | +20 |
| R4 | `daily_txns >= 5` | flag only |

Score ≥ 60 → HIGH · Score 30–59 → MEDIUM · Score < 30 → LOW

---

## Key Results

- **556 fraud cases** detected (9.3%)  
- **51 HIGH-risk** transactions flagged for immediate review  
- **₹12.3M** total value flagged  
- **Location mismatch** was the most triggered rule  
- **Utilities & Gaming** categories had highest fraud rates

---

## Files

```
transactions.csv       — Dataset (6,000 rows)
fraud_queries.sql      — All SQL queries
fraud_dashboard.html   — Interactive dashboard
fraud_detection.pptx   — 6-slide presentation
README.md              — This file
```

---

## Resume Bullets

- Built a SQL-based fraud detection system on 6,000+ transactions using CASE WHEN scoring logic, flagging 556 fraud cases (9.3%) across HIGH / MEDIUM / LOW risk tiers
- Designed a multi-rule risk engine using CTEs combining amount thresholds, location mismatch, and international flags into a single composite risk score
- Delivered end-to-end analytics pipeline from raw data to visual dashboard, reducing analyst review effort by isolating 51 HIGH-risk transactions out of 6,000

---

## Stack

- SQL (DuckDB / PostgreSQL compatible)
- Python · Faker (data generation)
- Chart.js (dashboard)
- PptxGenJS (presentation)
