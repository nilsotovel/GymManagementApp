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
    PlanID         INT           AUTO_INCREMENT PRIMARY KEY,
    PlanName       VARCHAR(50)   NOT NULL,
    DurationMonths INT           NOT NULL,
    Price          DECIMAL(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS Members (
    MemberID   INT          AUTO_INCREMENT PRIMARY KEY,
    FirstName  VARCHAR(50)  NOT NULL,
    LastName   VARCHAR(50)  NOT NULL,
    Phone      VARCHAR(15),
    MemberType ENUM('Monthly','Annual') NOT NULL,
    JoinDate   DATE         NOT NULL DEFAULT (CURRENT_DATE),
    ExpiryDate DATE         NOT NULL
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

-- ============================================================
-- A. SELECT and WHERE
-- ============================================================

-- Question:        How do you retrieve every record stored in a table?
-- Learning Outcome: Demonstrates the basic SELECT * syntax, which returns
--                  all columns and all rows from a table with no filtering.
SELECT * FROM Members;


-- Question:        How do you filter rows so that only records matching a
--                  specific condition are returned?
-- Learning Outcome: Demonstrates the WHERE clause with an equality operator
--                  (=) to restrict results to Annual members only.
SELECT MemberID, FirstName, LastName, Phone, MemberType, JoinDate, ExpiryDate
FROM   Members
WHERE  MemberType = 'Annual';


-- Question:        How do you search for records where a text column
--                  partially matches a value, across more than one column?
-- Learning Outcome: Demonstrates the LIKE operator with wildcard characters
--                  (%) for partial-text matching, combined with OR to search
--                  across multiple columns — the pattern used by the app's
--                  Search feature.
SELECT MemberID, FirstName, LastName, Phone, MemberType, JoinDate, ExpiryDate
FROM   Members
WHERE  FirstName LIKE '%Priya%'
   OR  LastName  LIKE '%Reyes%';


-- ============================================================
-- B. ORDER BY
-- ============================================================

-- Question:        How do you sort query results so they are presented in
--                  a meaningful order?
-- Learning Outcome: Demonstrates ORDER BY with ASC (ascending, default) and
--                  DESC (descending). Sorting is independent of filtering —
--                  it only controls the presentation of results.
SELECT MemberID, FirstName, LastName, MemberType, JoinDate
FROM   Members
ORDER BY LastName ASC, JoinDate DESC;


-- ============================================================
-- C. INNER JOIN
-- ============================================================

-- Question:        How do you combine data from multiple related tables
--                  into a single result set?
-- Learning Outcome: Demonstrates INNER JOIN across three tables (Members,
--                  Payments, MembershipPlans) using foreign-key relationships.
--                  Only rows that have a matching record in ALL joined tables
--                  are included. Also shows table aliases (m, p, mp) and
--                  CONCAT to build a computed column.
SELECT
    m.MemberID,
    CONCAT(m.FirstName, ' ', m.LastName) AS FullName,
    m.MemberType,
    p.PaymentDate,
    mp.PlanName,
    p.Amount
FROM   Members          m
JOIN   Payments         p  ON m.MemberID = p.MemberID
JOIN   MembershipPlans  mp ON p.PlanID   = mp.PlanID
ORDER BY m.MemberID, p.PaymentDate;


-- ============================================================
-- D. LEFT JOIN
-- ============================================================

-- Question:        How do you include rows from the left table even when
--                  there is no matching row in the right table?
-- Learning Outcome: Demonstrates LEFT JOIN, which keeps every row from
--                  Members regardless of whether a matching Payments row
--                  exists. COALESCE replaces NULL (no payment found) with 0,
--                  showing how to handle missing data gracefully.
SELECT
    m.MemberID,
    CONCAT(m.FirstName, ' ', m.LastName) AS FullName,
    m.MemberType,
    COALESCE(p.Amount, 0) AS AmountPaid
FROM   Members  m
LEFT JOIN Payments p ON m.MemberID = p.MemberID;


-- ============================================================
-- E. Aggregate Functions: COUNT, SUM, AVG, MIN, MAX
-- ============================================================

-- Question:        How do you calculate summary statistics across groups
--                  of rows rather than for individual records?
-- Learning Outcome: Demonstrates all five core aggregate functions in a
--                  single query grouped by MemberType.
--                  COUNT(DISTINCT ...) counts unique members per type.
--                  SUM totals revenue, AVG finds the mean payment,
--                  MIN/MAX identify the cheapest and most expensive payments.
SELECT
    m.MemberType,
    COUNT(DISTINCT m.MemberID) AS TotalMembers,
    SUM(p.Amount)              AS TotalRevenue,
    AVG(p.Amount)              AS AvgPayment,
    MIN(p.Amount)              AS MinPayment,
    MAX(p.Amount)              AS MaxPayment
FROM   Members  m
JOIN   Payments p ON m.MemberID = p.MemberID
GROUP BY m.MemberType;


-- ============================================================
-- F. GROUP BY with ORDER BY
-- ============================================================

-- Question:        How do you count and total values per entity, then rank
--                  those entities from highest to lowest?
-- Learning Outcome: Demonstrates GROUP BY to aggregate payment data per
--                  member, combined with ORDER BY on an aggregate result
--                  (TotalPaid DESC) to rank members by spending.
SELECT
    m.MemberID,
    CONCAT(m.FirstName, ' ', m.LastName) AS FullName,
    COUNT(p.PaymentID) AS PaymentCount,
    SUM(p.Amount)      AS TotalPaid
FROM   Members  m
JOIN   Payments p ON m.MemberID = p.MemberID
GROUP BY m.MemberID, m.FirstName, m.LastName
ORDER BY TotalPaid DESC;


-- ============================================================
-- G. HAVING
-- ============================================================

-- Question:        How do you filter groups produced by GROUP BY, the same
--                  way WHERE filters individual rows?
-- Learning Outcome: Demonstrates HAVING, which applies a condition to
--                  aggregate values after grouping. WHERE cannot be used
--                  with aggregate functions — HAVING is the correct clause
--                  for that. Here it keeps only plans that generated more
--                  than $100 in total revenue.
SELECT
    mp.PlanName,
    SUM(p.Amount) AS TotalRevenue
FROM   MembershipPlans  mp
JOIN   Payments         p  ON mp.PlanID = p.PlanID
GROUP BY mp.PlanName
HAVING SUM(p.Amount) > 100
ORDER BY TotalRevenue DESC;


-- ============================================================
-- H. Subquery with IN
-- ============================================================

-- Question:        How do you use the result of one query as the filter
--                  condition for an outer query?
-- Learning Outcome: Demonstrates a subquery inside WHERE ... IN (...).
--                  The inner query groups payments per member and uses
--                  HAVING to find members whose total spending exceeds the
--                  overall average (a scalar subquery). The outer query
--                  then retrieves the full member details for those IDs.
SELECT
    CONCAT(m.FirstName, ' ', m.LastName) AS FullName,
    m.MemberType
FROM   Members m
WHERE  m.MemberID IN (
    SELECT  p.MemberID
    FROM    Payments p
    GROUP BY p.MemberID
    HAVING  SUM(p.Amount) > (SELECT AVG(Amount) FROM Payments)
);


-- ============================================================
-- I. Correlated Subquery with EXISTS
-- ============================================================

-- Question:        How do you check for the absence of a related record
--                  in another table, evaluated row by row?
-- Learning Outcome: Demonstrates a correlated subquery with NOT EXISTS.
--                  Unlike IN, a correlated subquery references columns from
--                  the outer query (m.MemberID), so it is re-evaluated for
--                  every row in Members. This finds members who have made
--                  zero payments — something difficult to express with a
--                  simple JOIN.
SELECT MemberID, FirstName, LastName
FROM   Members m
WHERE  NOT EXISTS (
    SELECT 1
    FROM   Payments p
    WHERE  p.MemberID = m.MemberID
);


-- ============================================================
-- J. Date Functions with WHERE and ORDER BY
-- ============================================================

-- Question:        How do you query rows based on calculated or relative
--                  date ranges?
-- Learning Outcome: Demonstrates BETWEEN with CURRENT_DATE and
--                  DATE_ADD to build a dynamic date-range filter — no
--                  hard-coded dates needed. ORDER BY ExpiryDate sorts the
--                  results so the soonest-expiring memberships appear first.
SELECT MemberID, FirstName, LastName, ExpiryDate
FROM   Members
WHERE  ExpiryDate BETWEEN CURRENT_DATE
                      AND DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY)
ORDER BY ExpiryDate;


-- ============================================================
-- K. GROUP BY with DATE_FORMAT (Monthly Revenue Trend)
-- ============================================================

-- Question:        How do you aggregate time-series data into monthly
--                  summaries and display the results in chronological order?
-- Learning Outcome: Demonstrates DATE_FORMAT to truncate full dates into
--                  year-month strings, which are then used as GROUP BY keys.
--                  ORDER BY on the formatted string produces a correct
--                  chronological trend of monthly revenue and payment counts.
SELECT
    DATE_FORMAT(PaymentDate, '%Y-%m') AS Month,
    SUM(Amount)                        AS MonthlyRevenue,
    COUNT(*)                           AS PaymentCount
FROM   Payments
GROUP BY DATE_FORMAT(PaymentDate, '%Y-%m')
ORDER BY Month;
