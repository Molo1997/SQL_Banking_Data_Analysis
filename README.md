# SQL Banking Data Analysis Project

## Project Overview

This project analyzes banking customer data to generate comprehensive insights about clients, their accounts, and transaction patterns. The SQL scripts create multiple temporary tables and combine them to produce a final table with detailed customer indicators.

## Dataset

The project works with a banking database containing the following main tables:
- `cliente`: Customer information (ID, name, birth date)
- `conto`: Account information linked to customers
- `tipo_conto`: Account types (Base, Business, Private, Family)
- `transazioni`: Transaction records
- `tipo_transazione`: Transaction types with directional indicators (inflow/outflow)

## Project Structure

The SQL script performs the following operations:

### 1. Customer Age Calculation
- Creates a temporary table with customer demographic information
- Calculates age based on the reference date (October 24, 2024)
- Verifies distinct customer count (200 customers)

### 2. Transaction Indicators
- Identifies customers with active accounts (142 customers)
- Creates temporary tables linking accounts, transaction types, and transaction data
- Calculates key transaction indicators:
  - Number of outflow transactions
  - Number of inflow transactions
  - Total outflow amount
  - Total inflow amount

### 3. Account Indicators
- Calculates the total number of accounts per customer
- Breaks down accounts by type:
  - Base Accounts
  - Business Accounts
  - Private Accounts
  - Family Accounts

### 4. Transaction Indicators by Account Type
- Creates detailed transaction metrics segmented by account type
- For each account type, calculates:
  - Number of outflow transactions
  - Number of inflow transactions
  - Total outflow amount
  - Total inflow amount

### 5. Final Consolidated Table
- Combines all previously calculated indicators into a comprehensive table
- Links all metrics to individual customer IDs
- Provides a complete customer profile with 26 different financial indicators

## Usage

1. Ensure you have access to the banking database with the required tables.
2. Execute the SQL script in your database management system.
3. The script will generate a final table named `final_indicatori_cliente` containing all customer indicators.
4. This table can be used for further analysis, reporting, or as input for customer segmentation models.

## Notes

- The script uses temporary tables extensively to build up the final result.
- All calculations use October 24, 2024 as the reference date for age calculations.
- The script handles missing data gracefully using LEFT JOINs to ensure all 200 customers appear in the final table, even if they don't have accounts or transactions.
- Performance considerations: The script is optimized to minimize multiple scans of large tables by creating appropriate temporary tables.

## Results

The final table `final_indicatori_cliente` contains a comprehensive profile for each customer with the following metrics:
- Customer ID and age
- Transaction counts and amounts (total inflows and outflows)
- Account counts by type
- Detailed transaction metrics for each account type

This data can be used for:
- Customer segmentation
- Targeted marketing
- Risk assessment
- Product recommendation
- Financial behavior analysis
