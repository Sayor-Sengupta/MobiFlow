# MobiFlow – Mobile Money Transaction Intelligence

A data analytics project exploring mobile-money transaction behaviour, payment patterns, customer activity, and business performance using SQL, Python, PostgreSQL, and Power BI.

## Project Overview

**MobiFlow** is a fictional mobile-money platform used as the business context for this project.

The objective is to analyse transaction activity over a simulated 30-day operating period and generate insights that could help a digital payments business understand how its customers use the platform.

The analysis focuses on transaction volumes, transaction values, payment methods, time-based activity, and sender/receiver account behaviour.

The project uses the PaySim synthetic mobile-money transaction dataset. MobiFlow is the fictional business scenario; it is not the actual provider represented by the source data.

## Business Objectives

The analysis aims to answer the following questions:

- Which payment methods generate the highest transaction volumes and values?
- How does average transaction value vary across payment types?
- What are the transaction activity patterns across simulated days and hours?
- How are transaction values distributed across different amount bands?
- How concentrated is transaction activity among originating and receiving accounts?
- What proportion of incoming transaction volume goes to customer and merchant destinations?
- Which transaction patterns could be useful for business planning and operational decision-making?

## Technology Stack

| Tool | Purpose |
|---|---|
| Python | Data inspection, cleaning, and feature engineering |
| Pandas | Data manipulation and transformation |
| PostgreSQL | Data storage and SQL-based analysis |
| SQL | Data validation, aggregations, and analytical queries |
| Power BI | Data modelling, DAX measures, and interactive dashboards |
| Git & GitHub | Version control and project documentation |

## Project Structure

```text
Fintech/
│
├── Cleaning/
│   └── cleaning.ipynb
│
├── Data/
│   └── (Dataset files – excluded from Git)
│
├── PowerBI/
│   ├── Resources/
│   └── fintech.pbix(Excluded due to size)
│
├── SQL/
│   ├── Analysis.sql
│   └── Schema.sql
│
├── .gitignore
└── README.md
```

## Data Pipeline

The project follows a straightforward analytical workflow:

1. **Data Preparation – Python**
   - Inspected the source dataset.
   - Cleaned and prepared transaction records.
   - Created additional analytical features.
   - Exported the prepared dataset for database loading.

2. **Data Storage – PostgreSQL**
   - Created the transaction table.
   - Loaded the prepared dataset.
   - Validated record counts, unique transaction IDs, and missing values.

3. **Data Analysis – SQL**
   - Analysed transaction volume and value.
   - Compared payment methods.
   - Examined daily and hourly activity.
   - Investigated sender and receiver account behaviour.
   - Analysed transaction-value concentration.

4. **Data Visualisation – Power BI**
   - Connected Power BI to PostgreSQL.
   - Created a dimensional data model.
   - Developed measures and interactive report pages.
   - Built a three-page dashboard for business analysis.

## Feature Engineering

Additional features were created to support the analysis:

| Feature | Description |
|---|---|
| `transaction_id` | Unique row identifier generated for the prepared dataset |
| `transaction_day` | Simulated day derived from the transaction step |
| `hour_of_day` | Simulated hour derived from the transaction step |
| `transaction_amount_band` | Transaction amount grouped into four dataset-specific bands |
| `is_high_value` | Identifies transactions above the dataset's 95th-percentile amount threshold |
| `is_origin_balance_drained` | Indicates whether the originating account's recorded new balance is zero |

The transaction-day and hour fields represent simulated time, not actual calendar dates or verified transaction timestamps.

## Power BI Dashboard

The report contains three analytical pages.

### 1. Transaction Overview

Provides a high-level view of overall platform activity.

Key metrics and visuals:
- Total transaction value
- Total transaction count
- Unique originating accounts
- Unique receiving accounts
- Transaction volume by payment type
- Transaction value share by payment type
- Daily transaction activity
- Hourly transaction activity by payment type

### 2. Payment Behaviour

Examines transaction-value patterns across payment methods and time periods.

Key metrics and visuals:
- Average transaction value
- Median transaction value
- High-value transaction share
- Average transaction value by payment type
- Average transaction value by amount band
- Daily transaction activity
- Hourly transaction trends by payment type

### 3. Account Intelligence

Explores transaction activity and value distribution across originating and receiving accounts.

Key metrics and visuals:
- Unique originating accounts
- Unique receiving accounts
- Customer destination value share
- Top originating accounts by transaction value
- Top receiving accounts by transaction value
- Sender accounts by transaction frequency
- Customer versus merchant transaction volume

## Key Findings

The following findings were identified from the dataset:

| Analysis | Finding |
|---|---|
| Transaction volume | Approximately 6.36 million transactions |
| Total transaction value | Approximately 1.144 trillion dataset currency units |
| Average transaction value | Approximately 179,861.90 |
| Median transaction value | Approximately 74,871.94 |
| Highest value contribution | TRANSFER accounts for approximately 42.41% of total transaction value |
| Highest transaction volume | CASH_OUT accounts for approximately 35.17% of transactions |
| PAYMENT activity | PAYMENT represents approximately 33.81% of transaction volume but only 2.45% of transaction value |
| High-value activity | TRANSFER represents approximately 79.8% of transactions classified as high-value |
| Destination concentration | The top 10% of receiving accounts account for approximately 88.81% of incoming transaction value |
| Destination type | Customer destinations account for approximately 97.55% of incoming transaction value |

These findings describe patterns in the synthetic dataset and should not be interpreted as verified market-wide mobile-payment behaviour.

## Data Model

The Power BI model uses a fact-and-dimension structure.

- **FactTransactions:** Contains transaction-level records and numerical measures.
- **DimPaymentType:** Provides payment-type descriptions and integer keys.
- **DimBandType:** Provides transaction amount-band descriptions and sorting information.
- **Measure:** A dedicated table used to organise report measures.

The dimensional model supports filtering and analysis across payment types and transaction amount bands.

## Dataset

**Source:** PaySim – Synthetic Financial Dataset for Mobile Money

The dataset simulates mobile-money transactions and includes payment types such as:

- CASH_IN
- CASH_OUT
- DEBIT
- PAYMENT
- TRANSFER

The prepared dataset contains approximately 6.36 million transaction records.

The source dataset is synthetic. It does not represent verified customer identities, real-world transactions, or the actual operating performance of a payment provider.

## Limitations

- The dataset is synthetic and may not reproduce real-world customer behaviour.
- Transaction steps are simulated time intervals, not actual calendar timestamps.
- Account identifiers do not represent verified individuals or businesses.
- Balance fields have known limitations, particularly for merchant destinations.
- Aggregated balance differences should not be interpreted as actual net money flows.
- High-value thresholds and transaction amount bands are specific to this dataset.
- Findings should not be generalised to the wider mobile-payment industry without validation against real transaction data.



