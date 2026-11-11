-- =============================================================================
-- Expense Tracker Web Application - Database Schema & Seed Data
-- Database Engine: MySQL 8.x / MariaDB
-- =============================================================================

-- 1. Create Database
CREATE DATABASE IF NOT EXISTS expense_tracker
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE expense_tracker;

-- 2. Create Transactions Table
DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(20) NOT NULL COMMENT 'INCOME or EXPENSE',
    amount DECIMAL(12, 2) NOT NULL COMMENT 'Monetary value with precision',
    category VARCHAR(100) NOT NULL COMMENT 'Food, Transport, Education, Shopping, Salary, etc.',
    description VARCHAR(500) NULL COMMENT 'Optional description of the transaction',
    transaction_date DATE NOT NULL COMMENT 'Date of the transaction (YYYY-MM-DD)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Audit timestamp',
    
    -- Performance Indexes for dashboard and monthly filtering
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_type (type),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 3. Seed Initial Demo Data
-- =============================================================================

INSERT INTO transactions (type, amount, category, description, transaction_date, created_at) VALUES
('INCOME',  65000.00, 'Salary',        'Monthly Salary Credited',                '2026-11-01', NOW()),
('EXPENSE',  3500.00, 'Food',          'Grocery shopping at DMart',              '2026-11-04', NOW()),
('EXPENSE',  1200.00, 'Transport',     'Monthly Metro card recharge',            '2026-11-08', NOW()),
('EXPENSE',  4500.00, 'Education',     'Cloud Computing Certification Course',   '2026-11-12', NOW()),
('EXPENSE',  2800.00, 'Entertainment', 'Weekend dinner and movie with friends',  '2026-11-18', NOW()),
('EXPENSE',  1850.00, 'Shopping',      'Electronics & Project Components',      '2026-11-22', NOW()),
('INCOME',   5000.00, 'Allowance',     'Academic Project Stipend',               '2026-11-25', NOW());

-- =============================================================================
-- 4. Key Analytical Queries (Used by Spring Boot backend for Dashboard & Viva)
-- =============================================================================

-- A. Total Income
SELECT COALESCE(SUM(amount), 0.00) AS total_income 
FROM transactions 
WHERE type = 'INCOME';

-- B. Total Expenses
SELECT COALESCE(SUM(amount), 0.00) AS total_expenses 
FROM transactions 
WHERE type = 'EXPENSE';

-- C. Available Balance
SELECT 
    (SELECT COALESCE(SUM(amount), 0.00) FROM transactions WHERE type = 'INCOME') -
    (SELECT COALESCE(SUM(amount), 0.00) FROM transactions WHERE type = 'EXPENSE') AS available_balance;

-- D. Category-wise Expense Breakdown (for Pie Chart)
SELECT 
    category,
    SUM(amount) AS total_spent,
    ROUND((SUM(amount) / (SELECT SUM(amount) FROM transactions WHERE type = 'EXPENSE')) * 100, 2) AS percentage
FROM transactions
WHERE type = 'EXPENSE'
GROUP BY category
ORDER BY total_spent DESC;

-- E. Monthly Report (Example for November 2026)
SELECT 
    type,
    category,
    amount,
    transaction_date,
    description
FROM transactions
WHERE transaction_date BETWEEN '2026-11-01' AND '2026-11-30'
ORDER BY transaction_date DESC;
