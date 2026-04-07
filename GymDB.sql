-- ============================================================
--  GymDB.sql  –  Gym Management System Database
--  Connection: localhost | DB: GymDB | User: root
-- ============================================================

CREATE DATABASE IF NOT EXISTS GymDB;
USE GymDB;

-- ------------------------------------------------------------
-- 1. SCHEMA
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS MembershipPlans (
    PlanID        INT           AUTO_INCREMENT PRIMARY KEY,
    PlanName      VARCHAR(50)   NOT NULL,
    DurationMonths INT          NOT NULL,
    Price         DECIMAL(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS Members (
    MemberID    INT          AUTO_INCREMENT PRIMARY KEY,
    FirstName   VARCHAR(50)  NOT NULL,
    LastName    VARCHAR(50)  NOT NULL,
    Phone       VARCHAR(15),
    MemberType  ENUM('Monthly','Annual') NOT NULL,
    JoinDate    DATE         NOT NULL DEFAULT (CURRENT_DATE),
    ExpiryDate  DATE         NOT NULL
);

CREATE TABLE IF NOT EXISTS Payments (
    PaymentID   INT           AUTO_INCREMENT PRIMARY KEY,
    MemberID    INT           NOT NULL,
    PlanID      INT           NOT NULL,
    Amount      DECIMAL(10,2) NOT NULL,
    PaymentDate DATE          NOT NULL,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID) ON DELETE CASCADE,
    FOREIGN KEY (PlanID)   REFERENCES MembershipPlans(PlanID)
);

-- ------------------------------------------------------------
-- 2. SAMPLE DATA
-- ------------------------------------------------------------

INSERT INTO MembershipPlans (PlanName, DurationMonths, Price) VALUES
    ('Monthly Basic',   1,  29.99),
    ('Monthly Premium', 1,  49.99),
    ('Annual Basic',   12, 299.99),
    ('Annual Premium', 12, 499.99);

INSERT INTO Members (FirstName, LastName, Phone, MemberType, JoinDate, ExpiryDate) VALUES
    ('Carlos',   'Mendoza',   '555-1001', 'Monthly', '2025-01-10', '2025-02-10'),
    ('Aisha',    'Thompson',  '555-1002', 'Annual',  '2025-01-15', '2026-01-15'),
    ('Ryan',     'Gallagher', '555-1003', 'Monthly', '2025-02-01', '2025-03-01'),
    ('Priya',    'Nair',      '555-1004', 'Annual',  '2025-02-20', '2026-02-20'),
    ('Ethan',    'Brooks',    '555-1005', 'Monthly', '2025-03-05', '2025-04-05'),
    ('Sofia',    'Reyes',     '555-1006', 'Annual',  '2025-03-10', '2026-03-10'),
    ('James',    'Okafor',    '555-1007', 'Monthly', '2025-04-01', '2025-05-01'),
    ('Mei',      'Lin',       '555-1008', 'Annual',  '2025-04-12', '2026-04-12'),
    ('Marcus',   'Wright',    '555-1009', 'Monthly', '2025-05-01', '2025-06-01'),
    ('Natasha',  'Ivanova',   '555-1010', 'Annual',  '2025-05-20', '2026-05-20');

INSERT INTO Payments (MemberID, PlanID, Amount, PaymentDate) VALUES
    (1,  1,  29.99, '2025-01-10'),
    (2,  4, 499.99, '2025-01-15'),
    (3,  1,  29.99, '2025-02-01'),
    (4,  3, 299.99, '2025-02-20'),
    (5,  2,  49.99, '2025-03-05'),
    (6,  4, 499.99, '2025-03-10'),
    (7,  1,  29.99, '2025-04-01'),
    (8,  3, 299.99, '2025-04-12'),
    (9,  2,  49.99, '2025-05-01'),
    (10, 4, 499.99, '2025-05-20'),
    -- Renewal payments
    (1,  1,  29.99, '2025-02-10'),
    (3,  2,  49.99, '2025-03-01'),
    (5,  1,  29.99, '2025-04-05'),
    (7,  2,  49.99, '2025-05-01');

-- ------------------------------------------------------------
-- 3. REQUIRED QUERIES FOR SCHOOL PROJECT
-- ------------------------------------------------------------

-- ── A. Simple SELECT with WHERE ──────────────────────────────
-- Retrieve all members
SELECT * FROM Members;

-- Retrieve all Annual members
SELECT MemberID, FirstName, LastName, Phone, MemberType, JoinDate, ExpiryDate
FROM Members
WHERE MemberType = 'Annual';

-- Search by partial name (used by the app's Search feature)
SELECT MemberID, FirstName, LastName, Phone, MemberType, JoinDate, ExpiryDate
FROM Members
WHERE FirstName LIKE '%Priya%'
   OR LastName  LIKE '%Reyes%';

-- ── B. JOIN – Members with their payment plan details ────────
SELECT
    m.MemberID,
    CONCAT(m.FirstName, ' ', m.LastName) AS FullName,
    m.MemberType,
    p.PaymentDate,
    mp.PlanName,
    p.Amount
FROM Members m
JOIN Payments        p  ON m.MemberID = p.MemberID
JOIN MembershipPlans mp ON p.PlanID   = mp.PlanID
ORDER BY m.MemberID, p.PaymentDate;

-- LEFT JOIN – All members, including those with no payments
SELECT
    m.MemberID,
    CONCAT(m.FirstName, ' ', m.LastName) AS FullName,
    m.MemberType,
    COALESCE(p.Amount, 0) AS AmountPaid
FROM Members m
LEFT JOIN Payments p ON m.MemberID = p.MemberID;

-- ── C. GROUP BY with Aggregate Functions ─────────────────────
-- Total revenue collected per membership type
SELECT
    m.MemberType,
    COUNT(DISTINCT m.MemberID) AS TotalMembers,
    SUM(p.Amount)              AS TotalRevenue,
    AVG(p.Amount)              AS AvgPayment,
    MIN(p.Amount)              AS MinPayment,
    MAX(p.Amount)              AS MaxPayment
FROM Members m
JOIN Payments p ON m.MemberID = p.MemberID
GROUP BY m.MemberType;

-- Number of payments and total paid per member
SELECT
    m.MemberID,
    CONCAT(m.FirstName, ' ', m.LastName) AS FullName,
    COUNT(p.PaymentID) AS PaymentCount,
    SUM(p.Amount)      AS TotalPaid
FROM Members m
JOIN Payments p ON m.MemberID = p.MemberID
GROUP BY m.MemberID, m.FirstName, m.LastName
ORDER BY TotalPaid DESC;

-- Revenue per plan, only plans that earned more than $100
SELECT
    mp.PlanName,
    SUM(p.Amount) AS TotalRevenue
FROM MembershipPlans mp
JOIN Payments p ON mp.PlanID = p.PlanID
GROUP BY mp.PlanName
HAVING SUM(p.Amount) > 100
ORDER BY TotalRevenue DESC;

-- ── D. Subqueries ─────────────────────────────────────────────
-- Members who have paid more than the average payment amount
SELECT
    CONCAT(m.FirstName, ' ', m.LastName) AS FullName,
    m.MemberType
FROM Members m
WHERE m.MemberID IN (
    SELECT p.MemberID
    FROM   Payments p
    GROUP BY p.MemberID
    HAVING SUM(p.Amount) > (SELECT AVG(Amount) FROM Payments)
);

-- Members who have never made a payment (correlated subquery)
SELECT MemberID, FirstName, LastName
FROM   Members m
WHERE  NOT EXISTS (
    SELECT 1 FROM Payments p WHERE p.MemberID = m.MemberID
);

-- Members whose membership expires within the next 30 days
SELECT MemberID, FirstName, LastName, ExpiryDate
FROM   Members
WHERE  ExpiryDate BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY)
ORDER BY ExpiryDate;

-- ── E. Additional useful operations ──────────────────────────
-- Monthly revenue trend
SELECT
    DATE_FORMAT(PaymentDate, '%Y-%m') AS Month,
    SUM(Amount)                        AS MonthlyRevenue,
    COUNT(*)                           AS PaymentCount
FROM Payments
GROUP BY DATE_FORMAT(PaymentDate, '%Y-%m')
ORDER BY Month;
