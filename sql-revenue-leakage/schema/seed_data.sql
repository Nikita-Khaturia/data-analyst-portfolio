-- =============================================================================
-- Revenue Leakage Identification -- Seed Data
-- =============================================================================
-- This data set contains INTENTIONAL discrepancies that the analysis queries
-- are designed to detect:
--
--   1. Invoices dated after contract end_date           (~$180K leakage)
--   2. Billed unit prices that differ from tier prices  (~$95K leakage)
--   3. Duplicate invoices (same customer, amount, date) (~$45K leakage)
--   4. Contracted discounts not applied to line totals  (~$120K leakage)
--   5. Billing against cancelled/terminated contracts   (~$60K leakage)
--
-- Total seeded leakage: ~$500K
-- =============================================================================

-- -------------------------------------------------------------------------
-- CUSTOMERS (20 rows)
-- -------------------------------------------------------------------------
INSERT INTO customers VALUES (1,  'Apex Financial Group',      'Enterprise',  'Northeast',  '2019-03-15');
INSERT INTO customers VALUES (2,  'BrightPath Healthcare',     'Enterprise',  'Southeast',  '2019-06-01');
INSERT INTO customers VALUES (3,  'Cascade Logistics',         'Mid-Market',  'West',       '2020-01-10');
INSERT INTO customers VALUES (4,  'DataNova Analytics',        'Enterprise',  'Northeast',  '2019-11-20');
INSERT INTO customers VALUES (5,  'EverGreen Energy',          'Mid-Market',  'Midwest',    '2020-04-05');
INSERT INTO customers VALUES (6,  'Frontier Manufacturing',    'Enterprise',  'Southeast',  '2018-09-12');
INSERT INTO customers VALUES (7,  'GlobalTech Solutions',      'Enterprise',  'West',       '2019-01-25');
INSERT INTO customers VALUES (8,  'Horizon Media Partners',    'Mid-Market',  'Northeast',  '2020-07-18');
INSERT INTO customers VALUES (9,  'Ironclad Insurance',        'Enterprise',  'Midwest',    '2019-05-30');
INSERT INTO customers VALUES (10, 'Jetstream Aviation',        'Mid-Market',  'Southeast',  '2020-11-02');
INSERT INTO customers VALUES (11, 'Keystone Property Mgmt',    'SMB',         'Northeast',  '2021-02-14');
INSERT INTO customers VALUES (12, 'Lakeside Retail Corp',      'SMB',         'Midwest',    '2021-06-22');
INSERT INTO customers VALUES (13, 'Momentum Sports Inc',       'SMB',         'West',       '2021-08-30');
INSERT INTO customers VALUES (14, 'NorthStar Consulting',      'Mid-Market',  'Northeast',  '2020-03-17');
INSERT INTO customers VALUES (15, 'Optima Pharmaceuticals',    'Enterprise',  'Southeast',  '2019-10-05');
INSERT INTO customers VALUES (16, 'PeakView Capital',          'Mid-Market',  'West',       '2020-12-11');
INSERT INTO customers VALUES (17, 'Quantum Biotech',           'Enterprise',  'Northeast',  '2019-07-08');
INSERT INTO customers VALUES (18, 'Redwood Construction',      'SMB',         'Midwest',    '2021-04-19');
INSERT INTO customers VALUES (19, 'Summit Education Group',    'SMB',         'Southeast',  '2021-09-25');
INSERT INTO customers VALUES (20, 'TrueNorth Logistics',       'Mid-Market',  'West',       '2020-05-13');

-- -------------------------------------------------------------------------
-- PRODUCTS (8 rows)
-- -------------------------------------------------------------------------
INSERT INTO products VALUES (1, 'Platform Core License',      'Software');
INSERT INTO products VALUES (2, 'Advanced Analytics Module',  'Software');
INSERT INTO products VALUES (3, 'API Gateway Access',         'Infrastructure');
INSERT INTO products VALUES (4, 'Data Storage (per TB)',      'Infrastructure');
INSERT INTO products VALUES (5, 'Premium Support',            'Services');
INSERT INTO products VALUES (6, 'Implementation Services',    'Services');
INSERT INTO products VALUES (7, 'Security Compliance Add-On', 'Software');
INSERT INTO products VALUES (8, 'Training & Enablement',      'Services');

-- -------------------------------------------------------------------------
-- PRICING TIERS (24 rows)
-- Some products have overlapping date ranges -- an intentional data issue.
-- -------------------------------------------------------------------------
INSERT INTO pricing_tiers VALUES (1,  1, 'Standard',  500.00,  '2020-01-01', '2023-12-31');
INSERT INTO pricing_tiers VALUES (2,  1, 'Premium',   750.00,  '2020-01-01', '2023-12-31');
INSERT INTO pricing_tiers VALUES (3,  1, 'Standard',  550.00,  '2024-01-01', NULL);
INSERT INTO pricing_tiers VALUES (4,  1, 'Premium',   825.00,  '2024-01-01', NULL);
INSERT INTO pricing_tiers VALUES (5,  2, 'Standard',  300.00,  '2020-01-01', '2023-12-31');
INSERT INTO pricing_tiers VALUES (6,  2, 'Premium',   450.00,  '2020-01-01', '2023-12-31');
INSERT INTO pricing_tiers VALUES (7,  2, 'Standard',  330.00,  '2024-01-01', NULL);
INSERT INTO pricing_tiers VALUES (8,  2, 'Premium',   495.00,  '2024-01-01', NULL);
INSERT INTO pricing_tiers VALUES (9,  3, 'Standard',  200.00,  '2020-01-01', '2023-12-31');
INSERT INTO pricing_tiers VALUES (10, 3, 'Premium',   350.00,  '2020-01-01', '2023-12-31');
INSERT INTO pricing_tiers VALUES (11, 3, 'Standard',  220.00,  '2024-01-01', NULL);
INSERT INTO pricing_tiers VALUES (12, 3, 'Premium',   385.00,  '2024-01-01', NULL);
INSERT INTO pricing_tiers VALUES (13, 4, 'Standard',  150.00,  '2020-01-01', '2023-12-31');
INSERT INTO pricing_tiers VALUES (14, 4, 'Premium',   250.00,  '2020-01-01', '2023-12-31');
INSERT INTO pricing_tiers VALUES (15, 4, 'Standard',  165.00,  '2024-01-01', NULL);
INSERT INTO pricing_tiers VALUES (16, 4, 'Premium',   275.00,  '2024-01-01', NULL);
INSERT INTO pricing_tiers VALUES (17, 5, 'Standard',  1000.00, '2020-01-01', NULL);
INSERT INTO pricing_tiers VALUES (18, 5, 'Premium',   1800.00, '2020-01-01', NULL);
INSERT INTO pricing_tiers VALUES (19, 6, 'Standard',  5000.00, '2020-01-01', NULL);
INSERT INTO pricing_tiers VALUES (20, 6, 'Premium',   8500.00, '2020-01-01', NULL);
INSERT INTO pricing_tiers VALUES (21, 7, 'Standard',  400.00,  '2020-01-01', '2023-12-31');
INSERT INTO pricing_tiers VALUES (22, 7, 'Standard',  440.00,  '2024-01-01', NULL);
INSERT INTO pricing_tiers VALUES (23, 8, 'Standard',  250.00,  '2020-01-01', '2023-12-31');
INSERT INTO pricing_tiers VALUES (24, 8, 'Standard',  275.00,  '2024-01-01', NULL);

-- -------------------------------------------------------------------------
-- CONTRACTS (40 rows)
-- Statuses: Active, Expired, Cancelled, Terminated
-- Some expired/cancelled contracts will still have invoices -- that is the bug.
-- -------------------------------------------------------------------------
-- Active contracts
INSERT INTO contracts VALUES (1,  1,  'Multi-Year',      '2023-01-01', '2025-12-31', 120000.00, 10.00, TRUE,  'Active');
INSERT INTO contracts VALUES (2,  2,  'Annual',          '2024-01-01', '2024-12-31', 96000.00,  5.00,  TRUE,  'Active');
INSERT INTO contracts VALUES (3,  3,  'Annual',          '2024-03-01', '2025-02-28', 48000.00,  8.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (4,  4,  'Multi-Year',      '2022-07-01', '2025-06-30', 200000.00, 12.00, TRUE,  'Active');
INSERT INTO contracts VALUES (5,  5,  'Annual',          '2024-06-01', '2025-05-31', 36000.00,  5.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (6,  6,  'Multi-Year',      '2023-04-01', '2026-03-31', 150000.00, 15.00, TRUE,  'Active');
INSERT INTO contracts VALUES (7,  7,  'Annual',          '2024-01-01', '2024-12-31', 180000.00, 10.00, TRUE,  'Active');
INSERT INTO contracts VALUES (8,  8,  'Annual',          '2024-09-01', '2025-08-31', 42000.00,  0.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (9,  9,  'Multi-Year',      '2023-01-01', '2025-12-31', 160000.00, 12.00, TRUE,  'Active');
INSERT INTO contracts VALUES (10, 10, 'Annual',          '2024-04-01', '2025-03-31', 30000.00,  5.00,  FALSE, 'Active');

-- Expired contracts (should NOT have invoices after end_date)
INSERT INTO contracts VALUES (11, 1,  'Annual',          '2022-01-01', '2022-12-31', 90000.00,  8.00,  FALSE, 'Expired');
INSERT INTO contracts VALUES (12, 3,  'Annual',          '2023-01-01', '2023-12-31', 45000.00,  5.00,  FALSE, 'Expired');
INSERT INTO contracts VALUES (13, 5,  'Annual',          '2023-06-01', '2024-05-31', 34000.00,  0.00,  FALSE, 'Expired');
INSERT INTO contracts VALUES (14, 7,  'Annual',          '2023-01-01', '2023-12-31', 170000.00, 10.00, FALSE, 'Expired');
INSERT INTO contracts VALUES (15, 9,  'Annual',          '2022-01-01', '2022-12-31', 140000.00, 10.00, FALSE, 'Expired');
INSERT INTO contracts VALUES (16, 11, 'Month-to-Month',  '2022-06-01', '2023-05-31', 18000.00,  0.00,  FALSE, 'Expired');
INSERT INTO contracts VALUES (17, 14, 'Annual',          '2022-04-01', '2023-03-31', 55000.00,  5.00,  FALSE, 'Expired');
INSERT INTO contracts VALUES (18, 15, 'Multi-Year',      '2021-01-01', '2023-12-31', 180000.00, 12.00, FALSE, 'Expired');
INSERT INTO contracts VALUES (19, 17, 'Annual',          '2022-07-01', '2023-06-30', 160000.00, 8.00,  FALSE, 'Expired');
INSERT INTO contracts VALUES (20, 20, 'Annual',          '2023-01-01', '2023-12-31', 40000.00,  5.00,  FALSE, 'Expired');

-- Cancelled contracts (should NOT have any invoices after cancellation)
INSERT INTO contracts VALUES (21, 2,  'Annual',          '2023-01-01', '2023-12-31', 85000.00,  5.00,  FALSE, 'Cancelled');
INSERT INTO contracts VALUES (22, 6,  'Annual',          '2023-07-01', '2024-06-30', 140000.00, 10.00, FALSE, 'Cancelled');
INSERT INTO contracts VALUES (23, 12, 'Month-to-Month',  '2022-01-01', '2022-12-31', 15000.00,  0.00,  FALSE, 'Cancelled');
INSERT INTO contracts VALUES (24, 13, 'Annual',          '2023-03-01', '2024-02-29', 22000.00,  0.00,  FALSE, 'Cancelled');
INSERT INTO contracts VALUES (25, 16, 'Annual',          '2023-06-01', '2024-05-31', 38000.00,  5.00,  FALSE, 'Cancelled');

-- Terminated contracts
INSERT INTO contracts VALUES (26, 4,  'Annual',          '2021-07-01', '2022-06-30', 185000.00, 10.00, FALSE, 'Terminated');
INSERT INTO contracts VALUES (27, 8,  'Month-to-Month',  '2023-01-01', '2023-06-30', 24000.00,  0.00,  FALSE, 'Terminated');
INSERT INTO contracts VALUES (28, 10, 'Annual',          '2023-01-01', '2023-12-31', 28000.00,  5.00,  FALSE, 'Terminated');

-- Additional active contracts for breadth
INSERT INTO contracts VALUES (29, 11, 'Annual',          '2024-01-01', '2024-12-31', 20000.00,  0.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (30, 12, 'Annual',          '2024-03-01', '2025-02-28', 18000.00,  0.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (31, 13, 'Annual',          '2024-06-01', '2025-05-31', 24000.00,  5.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (32, 14, 'Annual',          '2024-04-01', '2025-03-31', 60000.00,  8.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (33, 15, 'Multi-Year',      '2024-01-01', '2026-12-31', 195000.00, 12.00, TRUE,  'Active');
INSERT INTO contracts VALUES (34, 16, 'Annual',          '2024-06-01', '2025-05-31', 42000.00,  5.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (35, 17, 'Multi-Year',      '2024-01-01', '2026-12-31', 175000.00, 10.00, TRUE,  'Active');
INSERT INTO contracts VALUES (36, 18, 'Month-to-Month',  '2024-01-01', '2024-12-31', 12000.00,  0.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (37, 19, 'Annual',          '2024-05-01', '2025-04-30', 16000.00,  0.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (38, 20, 'Annual',          '2024-01-01', '2024-12-31', 45000.00,  5.00,  FALSE, 'Active');
INSERT INTO contracts VALUES (39, 2,  'Annual',          '2025-01-01', '2025-12-31', 100000.00, 7.00,  TRUE,  'Active');
INSERT INTO contracts VALUES (40, 6,  'Annual',          '2024-07-01', '2025-06-30', 155000.00, 12.00, TRUE,  'Active');

-- -------------------------------------------------------------------------
-- INVOICES (165 rows)
-- -------------------------------------------------------------------------
-- Legitimate invoices on active contracts
INSERT INTO invoices VALUES (1,   1,  1,  '2024-01-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (2,   1,  1,  '2024-02-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (3,   1,  1,  '2024-03-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (4,   1,  1,  '2024-04-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (5,   1,  1,  '2024-05-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (6,   1,  1,  '2024-06-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (7,   2,  2,  '2024-01-15', 8000.00,   'Paid');
INSERT INTO invoices VALUES (8,   2,  2,  '2024-02-15', 8000.00,   'Paid');
INSERT INTO invoices VALUES (9,   2,  2,  '2024-03-15', 8000.00,   'Paid');
INSERT INTO invoices VALUES (10,  2,  2,  '2024-04-15', 8000.00,   'Paid');
INSERT INTO invoices VALUES (11,  3,  3,  '2024-03-15', 4000.00,   'Paid');
INSERT INTO invoices VALUES (12,  3,  3,  '2024-04-15', 4000.00,   'Paid');
INSERT INTO invoices VALUES (13,  3,  3,  '2024-05-15', 4000.00,   'Paid');
INSERT INTO invoices VALUES (14,  4,  4,  '2024-01-15', 16667.00,  'Paid');
INSERT INTO invoices VALUES (15,  4,  4,  '2024-02-15', 16667.00,  'Paid');
INSERT INTO invoices VALUES (16,  4,  4,  '2024-03-15', 16667.00,  'Paid');
INSERT INTO invoices VALUES (17,  4,  4,  '2024-04-15', 16667.00,  'Paid');
INSERT INTO invoices VALUES (18,  5,  5,  '2024-06-15', 3000.00,   'Paid');
INSERT INTO invoices VALUES (19,  5,  5,  '2024-07-15', 3000.00,   'Paid');
INSERT INTO invoices VALUES (20,  5,  5,  '2024-08-15', 3000.00,   'Paid');
INSERT INTO invoices VALUES (21,  6,  6,  '2024-01-15', 12500.00,  'Paid');
INSERT INTO invoices VALUES (22,  6,  6,  '2024-02-15', 12500.00,  'Paid');
INSERT INTO invoices VALUES (23,  6,  6,  '2024-03-15', 12500.00,  'Paid');
INSERT INTO invoices VALUES (24,  6,  6,  '2024-04-15', 12500.00,  'Paid');
INSERT INTO invoices VALUES (25,  7,  7,  '2024-01-15', 15000.00,  'Paid');
INSERT INTO invoices VALUES (26,  7,  7,  '2024-02-15', 15000.00,  'Paid');
INSERT INTO invoices VALUES (27,  7,  7,  '2024-03-15', 15000.00,  'Paid');
INSERT INTO invoices VALUES (28,  7,  7,  '2024-04-15', 15000.00,  'Paid');
INSERT INTO invoices VALUES (29,  8,  8,  '2024-09-15', 3500.00,   'Paid');
INSERT INTO invoices VALUES (30,  8,  8,  '2024-10-15', 3500.00,   'Paid');
INSERT INTO invoices VALUES (31,  9,  9,  '2024-01-15', 13333.00,  'Paid');
INSERT INTO invoices VALUES (32,  9,  9,  '2024-02-15', 13333.00,  'Paid');
INSERT INTO invoices VALUES (33,  9,  9,  '2024-03-15', 13333.00,  'Paid');
INSERT INTO invoices VALUES (34,  10, 10, '2024-04-15', 2500.00,   'Paid');
INSERT INTO invoices VALUES (35,  10, 10, '2024-05-15', 2500.00,   'Paid');
INSERT INTO invoices VALUES (36,  10, 10, '2024-06-15', 2500.00,   'Paid');

-- More legitimate invoices on active contracts (29-40)
INSERT INTO invoices VALUES (37,  29, 11, '2024-01-15', 1667.00,   'Paid');
INSERT INTO invoices VALUES (38,  29, 11, '2024-02-15', 1667.00,   'Paid');
INSERT INTO invoices VALUES (39,  30, 12, '2024-03-15', 1500.00,   'Paid');
INSERT INTO invoices VALUES (40,  30, 12, '2024-04-15', 1500.00,   'Paid');
INSERT INTO invoices VALUES (41,  31, 13, '2024-06-15', 2000.00,   'Paid');
INSERT INTO invoices VALUES (42,  31, 13, '2024-07-15', 2000.00,   'Paid');
INSERT INTO invoices VALUES (43,  32, 14, '2024-04-15', 5000.00,   'Paid');
INSERT INTO invoices VALUES (44,  32, 14, '2024-05-15', 5000.00,   'Paid');
INSERT INTO invoices VALUES (45,  33, 15, '2024-01-15', 16250.00,  'Paid');
INSERT INTO invoices VALUES (46,  33, 15, '2024-02-15', 16250.00,  'Paid');
INSERT INTO invoices VALUES (47,  33, 15, '2024-03-15', 16250.00,  'Paid');
INSERT INTO invoices VALUES (48,  34, 16, '2024-06-15', 3500.00,   'Paid');
INSERT INTO invoices VALUES (49,  34, 16, '2024-07-15', 3500.00,   'Paid');
INSERT INTO invoices VALUES (50,  35, 17, '2024-01-15', 14583.00,  'Paid');
INSERT INTO invoices VALUES (51,  35, 17, '2024-02-15', 14583.00,  'Paid');
INSERT INTO invoices VALUES (52,  35, 17, '2024-03-15', 14583.00,  'Paid');
INSERT INTO invoices VALUES (53,  36, 18, '2024-01-15', 1000.00,   'Paid');
INSERT INTO invoices VALUES (54,  36, 18, '2024-02-15', 1000.00,   'Paid');
INSERT INTO invoices VALUES (55,  37, 19, '2024-05-15', 1333.00,   'Paid');
INSERT INTO invoices VALUES (56,  37, 19, '2024-06-15', 1333.00,   'Paid');
INSERT INTO invoices VALUES (57,  38, 20, '2024-01-15', 3750.00,   'Paid');
INSERT INTO invoices VALUES (58,  38, 20, '2024-02-15', 3750.00,   'Paid');
INSERT INTO invoices VALUES (59,  38, 20, '2024-03-15', 3750.00,   'Paid');
INSERT INTO invoices VALUES (60,  39, 2,  '2025-01-15', 8333.00,   'Paid');
INSERT INTO invoices VALUES (61,  39, 2,  '2025-02-15', 8333.00,   'Pending');
INSERT INTO invoices VALUES (62,  40, 6,  '2024-07-15', 12917.00,  'Paid');
INSERT INTO invoices VALUES (63,  40, 6,  '2024-08-15', 12917.00,  'Paid');

-- Additional legitimate invoices
INSERT INTO invoices VALUES (64,  1,  1,  '2024-07-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (65,  1,  1,  '2024-08-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (66,  1,  1,  '2024-09-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (67,  2,  2,  '2024-05-15', 8000.00,   'Paid');
INSERT INTO invoices VALUES (68,  2,  2,  '2024-06-15', 8000.00,   'Paid');
INSERT INTO invoices VALUES (69,  4,  4,  '2024-05-15', 16667.00,  'Paid');
INSERT INTO invoices VALUES (70,  4,  4,  '2024-06-15', 16667.00,  'Paid');
INSERT INTO invoices VALUES (71,  6,  6,  '2024-05-15', 12500.00,  'Paid');
INSERT INTO invoices VALUES (72,  6,  6,  '2024-06-15', 12500.00,  'Paid');
INSERT INTO invoices VALUES (73,  7,  7,  '2024-05-15', 15000.00,  'Paid');
INSERT INTO invoices VALUES (74,  7,  7,  '2024-06-15', 15000.00,  'Paid');
INSERT INTO invoices VALUES (75,  9,  9,  '2024-04-15', 13333.00,  'Paid');
INSERT INTO invoices VALUES (76,  9,  9,  '2024-05-15', 13333.00,  'Paid');
INSERT INTO invoices VALUES (77,  9,  9,  '2024-06-15', 13333.00,  'Paid');

-- =========================================================================
-- LEAKAGE TYPE 1: Invoices AFTER contract expiry (~$180K)
-- These invoices are dated after the contract end_date on expired contracts.
-- =========================================================================
-- Contract 11 (cust 1) expired 2022-12-31 -- invoices in 2023
INSERT INTO invoices VALUES (78,  11, 1,  '2023-01-15', 7500.00,   'Paid');
INSERT INTO invoices VALUES (79,  11, 1,  '2023-02-15', 7500.00,   'Paid');
INSERT INTO invoices VALUES (80,  11, 1,  '2023-03-15', 7500.00,   'Paid');
INSERT INTO invoices VALUES (81,  11, 1,  '2023-04-15', 7500.00,   'Paid');
-- Contract 14 (cust 7) expired 2023-12-31 -- invoices in 2024
INSERT INTO invoices VALUES (82,  14, 7,  '2024-01-15', 14167.00,  'Paid');
INSERT INTO invoices VALUES (83,  14, 7,  '2024-02-15', 14167.00,  'Paid');
INSERT INTO invoices VALUES (84,  14, 7,  '2024-03-15', 14167.00,  'Paid');
-- Contract 15 (cust 9) expired 2022-12-31 -- invoices in 2023
INSERT INTO invoices VALUES (85,  15, 9,  '2023-01-15', 11667.00,  'Paid');
INSERT INTO invoices VALUES (86,  15, 9,  '2023-02-15', 11667.00,  'Paid');
-- Contract 18 (cust 15) expired 2023-12-31 -- invoices in 2024
INSERT INTO invoices VALUES (87,  18, 15, '2024-01-15', 15000.00,  'Paid');
INSERT INTO invoices VALUES (88,  18, 15, '2024-02-15', 15000.00,  'Paid');
INSERT INTO invoices VALUES (89,  18, 15, '2024-03-15', 15000.00,  'Paid');
-- Contract 19 (cust 17) expired 2023-06-30 -- invoices after
INSERT INTO invoices VALUES (90,  19, 17, '2023-07-15', 13333.00,  'Paid');
INSERT INTO invoices VALUES (91,  19, 17, '2023-08-15', 13333.00,  'Paid');
-- Total expired-contract invoices: 30000 + 42501 + 23334 + 45000 + 26666 = ~$167.5K
-- Adding a few more to push toward $180K
-- Contract 20 (cust 20) expired 2023-12-31
INSERT INTO invoices VALUES (92,  20, 20, '2024-01-15', 3333.00,   'Paid');
INSERT INTO invoices VALUES (93,  20, 20, '2024-02-15', 3333.00,   'Paid');
INSERT INTO invoices VALUES (94,  20, 20, '2024-03-15', 3333.00,   'Paid');
INSERT INTO invoices VALUES (95,  20, 20, '2024-04-15', 3333.00,   'Paid');

-- =========================================================================
-- LEAKAGE TYPE 3: Duplicate invoices (~$45K)
-- Same contract, same customer, same amount, same date (or within 1 day).
-- =========================================================================
-- Duplicate of invoice 1 (contract 1, cust 1, 2024-01-15, $10,000)
INSERT INTO invoices VALUES (96,  1,  1,  '2024-01-15', 10000.00,  'Paid');
-- Duplicate of invoice 14 (contract 4, cust 4, 2024-01-15, $16,667)
INSERT INTO invoices VALUES (97,  4,  4,  '2024-01-15', 16667.00,  'Paid');
-- Duplicate of invoice 25 (contract 7, cust 7, 2024-01-15, $15,000)
INSERT INTO invoices VALUES (98,  7,  7,  '2024-01-15', 15000.00,  'Paid');
-- Duplicate of invoice 48 (contract 34, cust 16, 2024-06-15, $3,500)
INSERT INTO invoices VALUES (99,  34, 16, '2024-06-15', 3500.00,   'Paid');
-- Total duplicates: 10000 + 16667 + 15000 + 3500 = $45,167

-- =========================================================================
-- LEAKAGE TYPE 5: Billing on cancelled/terminated contracts (~$60K)
-- =========================================================================
-- Contract 21 (cust 2) cancelled -- but invoices issued
INSERT INTO invoices VALUES (100, 21, 2,  '2023-06-15', 7083.00,   'Paid');
INSERT INTO invoices VALUES (101, 21, 2,  '2023-07-15', 7083.00,   'Paid');
INSERT INTO invoices VALUES (102, 21, 2,  '2023-08-15', 7083.00,   'Paid');
-- Contract 22 (cust 6) cancelled -- but invoices issued
INSERT INTO invoices VALUES (103, 22, 6,  '2023-10-15', 11667.00,  'Paid');
INSERT INTO invoices VALUES (104, 22, 6,  '2023-11-15', 11667.00,  'Paid');
-- Contract 24 (cust 13) cancelled -- but invoices issued
INSERT INTO invoices VALUES (105, 24, 13, '2023-06-15', 1833.00,   'Paid');
INSERT INTO invoices VALUES (106, 24, 13, '2023-07-15', 1833.00,   'Paid');
INSERT INTO invoices VALUES (107, 24, 13, '2023-08-15', 1833.00,   'Paid');
INSERT INTO invoices VALUES (108, 24, 13, '2023-09-15', 1833.00,   'Paid');
-- Total cancelled: 21249 + 23334 + 7332 + some terminated below
-- Contract 26 (cust 4) terminated
INSERT INTO invoices VALUES (109, 26, 4,  '2022-07-15', 3000.00,   'Paid');
INSERT INTO invoices VALUES (110, 26, 4,  '2022-08-15', 3000.00,   'Paid');
-- Total leakage type 5: ~$60.4K (cancelled + terminated billing)

-- More legitimate invoices to round out data set
INSERT INTO invoices VALUES (111, 3,  3,  '2024-06-15', 4000.00,   'Paid');
INSERT INTO invoices VALUES (112, 3,  3,  '2024-07-15', 4000.00,   'Paid');
INSERT INTO invoices VALUES (113, 5,  5,  '2024-09-15', 3000.00,   'Paid');
INSERT INTO invoices VALUES (114, 5,  5,  '2024-10-15', 3000.00,   'Paid');
INSERT INTO invoices VALUES (115, 6,  6,  '2024-07-15', 12500.00,  'Paid');
INSERT INTO invoices VALUES (116, 6,  6,  '2024-08-15', 12500.00,  'Paid');
INSERT INTO invoices VALUES (117, 7,  7,  '2024-07-15', 15000.00,  'Paid');
INSERT INTO invoices VALUES (118, 7,  7,  '2024-08-15', 15000.00,  'Paid');
INSERT INTO invoices VALUES (119, 8,  8,  '2024-11-15', 3500.00,   'Paid');
INSERT INTO invoices VALUES (120, 8,  8,  '2024-12-15', 3500.00,   'Paid');
INSERT INTO invoices VALUES (121, 9,  9,  '2024-07-15', 13333.00,  'Paid');
INSERT INTO invoices VALUES (122, 9,  9,  '2024-08-15', 13333.00,  'Paid');
INSERT INTO invoices VALUES (123, 10, 10, '2024-07-15', 2500.00,   'Paid');
INSERT INTO invoices VALUES (124, 10, 10, '2024-08-15', 2500.00,   'Paid');
INSERT INTO invoices VALUES (125, 29, 11, '2024-03-15', 1667.00,   'Paid');
INSERT INTO invoices VALUES (126, 30, 12, '2024-05-15', 1500.00,   'Paid');
INSERT INTO invoices VALUES (127, 31, 13, '2024-08-15', 2000.00,   'Paid');
INSERT INTO invoices VALUES (128, 32, 14, '2024-06-15', 5000.00,   'Paid');
INSERT INTO invoices VALUES (129, 33, 15, '2024-04-15', 16250.00,  'Paid');
INSERT INTO invoices VALUES (130, 34, 16, '2024-08-15', 3500.00,   'Paid');
INSERT INTO invoices VALUES (131, 35, 17, '2024-04-15', 14583.00,  'Paid');
INSERT INTO invoices VALUES (132, 36, 18, '2024-03-15', 1000.00,   'Paid');
INSERT INTO invoices VALUES (133, 37, 19, '2024-07-15', 1333.00,   'Paid');
INSERT INTO invoices VALUES (134, 38, 20, '2024-04-15', 3750.00,   'Paid');
INSERT INTO invoices VALUES (135, 38, 20, '2024-05-15', 3750.00,   'Paid');
INSERT INTO invoices VALUES (136, 40, 6,  '2024-09-15', 12917.00,  'Paid');
INSERT INTO invoices VALUES (137, 40, 6,  '2024-10-15', 12917.00,  'Paid');
INSERT INTO invoices VALUES (138, 40, 6,  '2024-11-15', 12917.00,  'Paid');
INSERT INTO invoices VALUES (139, 1,  1,  '2024-10-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (140, 1,  1,  '2024-11-15', 10000.00,  'Paid');
INSERT INTO invoices VALUES (141, 2,  2,  '2024-07-15', 8000.00,   'Paid');
INSERT INTO invoices VALUES (142, 2,  2,  '2024-08-15', 8000.00,   'Paid');
INSERT INTO invoices VALUES (143, 4,  4,  '2024-07-15', 16667.00,  'Paid');
INSERT INTO invoices VALUES (144, 4,  4,  '2024-08-15', 16667.00,  'Paid');
INSERT INTO invoices VALUES (145, 33, 15, '2024-05-15', 16250.00,  'Paid');
INSERT INTO invoices VALUES (146, 33, 15, '2024-06-15', 16250.00,  'Paid');
INSERT INTO invoices VALUES (147, 35, 17, '2024-05-15', 14583.00,  'Paid');
INSERT INTO invoices VALUES (148, 35, 17, '2024-06-15', 14583.00,  'Paid');
INSERT INTO invoices VALUES (149, 32, 14, '2024-07-15', 5000.00,   'Paid');
INSERT INTO invoices VALUES (150, 32, 14, '2024-08-15', 5000.00,   'Paid');

-- Pending / Overdue invoices
INSERT INTO invoices VALUES (151, 1,  1,  '2024-12-15', 10000.00,  'Pending');
INSERT INTO invoices VALUES (152, 4,  4,  '2024-09-15', 16667.00,  'Overdue');
INSERT INTO invoices VALUES (153, 6,  6,  '2024-09-15', 12500.00,  'Pending');
INSERT INTO invoices VALUES (154, 9,  9,  '2024-09-15', 13333.00,  'Pending');
INSERT INTO invoices VALUES (155, 33, 15, '2024-07-15', 16250.00,  'Pending');
INSERT INTO invoices VALUES (156, 35, 17, '2024-07-15', 14583.00,  'Pending');

-- A few more to hit 165
INSERT INTO invoices VALUES (157, 3,  3,  '2024-08-15', 4000.00,   'Paid');
INSERT INTO invoices VALUES (158, 5,  5,  '2024-11-15', 3000.00,   'Paid');
INSERT INTO invoices VALUES (159, 10, 10, '2024-09-15', 2500.00,   'Paid');
INSERT INTO invoices VALUES (160, 29, 11, '2024-04-15', 1667.00,   'Paid');
INSERT INTO invoices VALUES (161, 30, 12, '2024-06-15', 1500.00,   'Paid');
INSERT INTO invoices VALUES (162, 31, 13, '2024-09-15', 2000.00,   'Paid');
INSERT INTO invoices VALUES (163, 34, 16, '2024-09-15', 3500.00,   'Paid');
INSERT INTO invoices VALUES (164, 36, 18, '2024-04-15', 1000.00,   'Paid');
INSERT INTO invoices VALUES (165, 37, 19, '2024-08-15', 1333.00,   'Paid');

-- -------------------------------------------------------------------------
-- INVOICE LINES (~350 rows)
-- Includes LEAKAGE TYPE 2 (pricing mismatches ~$95K) and
-- LEAKAGE TYPE 4 (discount not applied ~$120K)
-- -------------------------------------------------------------------------

-- Helper note: We embed pricing errors and discount errors in line items.
-- A "correct" line for contract 1 (10% discount) with product 1 tier 3
-- at $550/unit would be: quantity * 550 * 0.90 = line_total.
-- We intentionally omit or mis-apply these.

-- === Invoice 1 (contract 1, 10% discount, $10,000 total) ===
-- LEAKAGE TYPE 4: Discount NOT applied (should be 10% off)
INSERT INTO invoice_lines VALUES (1,   1,  1, 10, 550.00,  5500.00,  3);  -- correct: 10*550*0.9=4950, billed 5500 -> +$550
INSERT INTO invoice_lines VALUES (2,   1,  2, 10, 330.00,  3300.00,  7);  -- correct: 10*330*0.9=2970, billed 3300 -> +$330
INSERT INTO invoice_lines VALUES (3,   1,  5, 1,  1000.00, 1000.00,  17); -- correct: 1*1000*0.9=900, billed 1000 -> +$100

-- === Invoice 2-6 (contract 1, similar pattern, discount not applied) ===
INSERT INTO invoice_lines VALUES (4,   2,  1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (5,   2,  2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (6,   2,  5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (7,   3,  1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (8,   3,  2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (9,   3,  5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (10,  4,  1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (11,  4,  2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (12,  4,  5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (13,  5,  1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (14,  5,  2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (15,  5,  5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (16,  6,  1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (17,  6,  2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (18,  6,  5, 1,  1000.00, 1000.00,  17);

-- === Invoices 64-66 (contract 1 continued, discount not applied) ===
INSERT INTO invoice_lines VALUES (19,  64, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (20,  64, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (21,  64, 5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (22,  65, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (23,  65, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (24,  65, 5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (25,  66, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (26,  66, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (27,  66, 5, 1,  1000.00, 1000.00,  17);
-- Discount leakage on contract 1: 9 invoices * (550+330+100) = 9 * 980 = $8,820

-- === Invoice 7-10 (contract 2, 5% discount, partially applied correctly) ===
INSERT INTO invoice_lines VALUES (28,  7,  1, 8,  550.00,  4400.00,  3);  -- should be 8*550*0.95=4180 -> +$220
INSERT INTO invoice_lines VALUES (29,  7,  3, 10, 220.00,  2200.00,  11); -- should be 10*220*0.95=2090 -> +$110
INSERT INTO invoice_lines VALUES (30,  7,  5, 1,  1000.00, 1000.00,  17); -- should be 1*1000*0.95=950 -> +$50
INSERT INTO invoice_lines VALUES (31,  8,  1, 8,  550.00,  4400.00,  3);
INSERT INTO invoice_lines VALUES (32,  8,  3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (33,  8,  5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (34,  9,  1, 8,  550.00,  4400.00,  3);
INSERT INTO invoice_lines VALUES (35,  9,  3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (36,  9,  5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (37,  10, 1, 8,  550.00,  4400.00,  3);
INSERT INTO invoice_lines VALUES (38,  10, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (39,  10, 5, 1,  1000.00, 1000.00,  17);
-- Discount leakage contract 2: 4 invoices * (220+110+50) = 4 * 380 = $1,520

-- === Invoices 67-68 (contract 2 continued) ===
INSERT INTO invoice_lines VALUES (40,  67, 1, 8,  550.00,  4400.00,  3);
INSERT INTO invoice_lines VALUES (41,  67, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (42,  67, 5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (43,  68, 1, 8,  550.00,  4400.00,  3);
INSERT INTO invoice_lines VALUES (44,  68, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (45,  68, 5, 1,  1000.00, 1000.00,  17);
-- Additional discount leakage contract 2: 2 * 380 = $760

-- === Invoices 11-13 (contract 3, 8% discount - NOT applied) ===
INSERT INTO invoice_lines VALUES (46,  11, 1, 5,  550.00,  2750.00,  3);  -- should: 5*550*0.92=2530 -> +$220
INSERT INTO invoice_lines VALUES (47,  11, 4, 5,  165.00,  825.00,   15); -- should: 5*165*0.92=759 -> +$66
INSERT INTO invoice_lines VALUES (48,  12, 1, 5,  550.00,  2750.00,  3);
INSERT INTO invoice_lines VALUES (49,  12, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (50,  13, 1, 5,  550.00,  2750.00,  3);
INSERT INTO invoice_lines VALUES (51,  13, 4, 5,  165.00,  825.00,   15);
-- Contract 3 discount leakage: 3 * (220+66) = 3 * 286 = $858

-- === Invoices 14-17, 69-70 (contract 4, 12% discount NOT applied) ===
INSERT INTO invoice_lines VALUES (52,  14, 1, 15, 550.00,  8250.00,  3);  -- should: 15*550*0.88=7260 -> +$990
INSERT INTO invoice_lines VALUES (53,  14, 2, 15, 330.00,  4950.00,  7);  -- should: 15*330*0.88=4356 -> +$594
INSERT INTO invoice_lines VALUES (54,  14, 7, 5,  440.00,  2200.00,  22); -- should: 5*440*0.88=1936 -> +$264
INSERT INTO invoice_lines VALUES (55,  15, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (56,  15, 2, 15, 330.00,  4950.00,  7);
INSERT INTO invoice_lines VALUES (57,  15, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (58,  16, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (59,  16, 2, 15, 330.00,  4950.00,  7);
INSERT INTO invoice_lines VALUES (60,  16, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (61,  17, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (62,  17, 2, 15, 330.00,  4950.00,  7);
INSERT INTO invoice_lines VALUES (63,  17, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (64,  69, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (65,  69, 2, 15, 330.00,  4950.00,  7);
INSERT INTO invoice_lines VALUES (66,  69, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (67,  70, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (68,  70, 2, 15, 330.00,  4950.00,  7);
INSERT INTO invoice_lines VALUES (69,  70, 7, 5,  440.00,  2200.00,  22);
-- Contract 4 discount leakage: 6 * (990+594+264) = 6 * 1848 = $11,088

-- === Invoices 18-20, 113-114 (contract 5, 5% discount NOT applied) ===
INSERT INTO invoice_lines VALUES (70,  18, 1, 3,  550.00,  1650.00,  3);  -- should: 3*550*0.95=1567.50 -> +$82.50
INSERT INTO invoice_lines VALUES (71,  18, 4, 5,  165.00,  825.00,   15); -- should: 5*165*0.95=783.75 -> +$41.25
INSERT INTO invoice_lines VALUES (72,  19, 1, 3,  550.00,  1650.00,  3);
INSERT INTO invoice_lines VALUES (73,  19, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (74,  20, 1, 3,  550.00,  1650.00,  3);
INSERT INTO invoice_lines VALUES (75,  20, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (76,  113, 1, 3, 550.00,  1650.00,  3);
INSERT INTO invoice_lines VALUES (77,  113, 4, 5, 165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (78,  114, 1, 3, 550.00,  1650.00,  3);
INSERT INTO invoice_lines VALUES (79,  114, 4, 5, 165.00,  825.00,   15);
-- Contract 5 discount leakage: 5 * (82.50+41.25) = 5 * 123.75 = $618.75

-- === Invoices 21-24, 71-72, 115-116 (contract 6, 15% discount NOT applied) ===
INSERT INTO invoice_lines VALUES (80,  21, 1, 10, 550.00,  5500.00,  3);  -- should: 10*550*0.85=4675 -> +$825
INSERT INTO invoice_lines VALUES (81,  21, 2, 10, 330.00,  3300.00,  7);  -- should: 10*330*0.85=2805 -> +$495
INSERT INTO invoice_lines VALUES (82,  21, 7, 5,  440.00,  2200.00,  22); -- should: 5*440*0.85=1870 -> +$330
INSERT INTO invoice_lines VALUES (83,  22, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (84,  22, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (85,  22, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (86,  23, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (87,  23, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (88,  23, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (89,  24, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (90,  24, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (91,  24, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (92,  71, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (93,  71, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (94,  71, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (95,  72, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (96,  72, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (97,  72, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (98,  115, 1, 10, 550.00, 5500.00,  3);
INSERT INTO invoice_lines VALUES (99,  115, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (100, 115, 7, 5,  440.00, 2200.00,  22);
INSERT INTO invoice_lines VALUES (101, 116, 1, 10, 550.00, 5500.00,  3);
INSERT INTO invoice_lines VALUES (102, 116, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (103, 116, 7, 5,  440.00, 2200.00,  22);
-- Contract 6 discount leakage: 8 * (825+495+330) = 8 * 1650 = $13,200

-- === Invoices 25-28, 73-74, 117-118 (contract 7, 10% discount NOT applied) ===
INSERT INTO invoice_lines VALUES (104, 25, 1, 15, 550.00,  8250.00,  3);  -- should: 15*550*0.9=7425 -> +$825
INSERT INTO invoice_lines VALUES (105, 25, 2, 10, 330.00,  3300.00,  7);  -- should: 10*330*0.9=2970 -> +$330
INSERT INTO invoice_lines VALUES (106, 25, 3, 10, 220.00,  2200.00,  11); -- should: 10*220*0.9=1980 -> +$220
INSERT INTO invoice_lines VALUES (107, 26, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (108, 26, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (109, 26, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (110, 27, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (111, 27, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (112, 27, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (113, 28, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (114, 28, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (115, 28, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (116, 73, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (117, 73, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (118, 73, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (119, 74, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (120, 74, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (121, 74, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (122, 117, 1, 15, 550.00, 8250.00,  3);
INSERT INTO invoice_lines VALUES (123, 117, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (124, 117, 3, 10, 220.00, 2200.00,  11);
INSERT INTO invoice_lines VALUES (125, 118, 1, 15, 550.00, 8250.00,  3);
INSERT INTO invoice_lines VALUES (126, 118, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (127, 118, 3, 10, 220.00, 2200.00,  11);
-- Contract 7 discount leakage: 8 * (825+330+220) = 8 * 1375 = $11,000

-- === Invoices 31-33, 75-77, 121-122 (contract 9, 12% discount NOT applied) ===
INSERT INTO invoice_lines VALUES (128, 31, 1, 12, 550.00,  6600.00,  3);  -- should: 12*550*0.88=5808 -> +$792
INSERT INTO invoice_lines VALUES (129, 31, 2, 10, 330.00,  3300.00,  7);  -- should: 10*330*0.88=2904 -> +$396
INSERT INTO invoice_lines VALUES (130, 31, 5, 1,  1800.00, 1800.00,  18); -- should: 1*1800*0.88=1584 -> +$216
INSERT INTO invoice_lines VALUES (131, 32, 1, 12, 550.00,  6600.00,  3);
INSERT INTO invoice_lines VALUES (132, 32, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (133, 32, 5, 1,  1800.00, 1800.00,  18);
INSERT INTO invoice_lines VALUES (134, 33, 1, 12, 550.00,  6600.00,  3);
INSERT INTO invoice_lines VALUES (135, 33, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (136, 33, 5, 1,  1800.00, 1800.00,  18);
INSERT INTO invoice_lines VALUES (137, 75, 1, 12, 550.00,  6600.00,  3);
INSERT INTO invoice_lines VALUES (138, 75, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (139, 75, 5, 1,  1800.00, 1800.00,  18);
INSERT INTO invoice_lines VALUES (140, 76, 1, 12, 550.00,  6600.00,  3);
INSERT INTO invoice_lines VALUES (141, 76, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (142, 76, 5, 1,  1800.00, 1800.00,  18);
INSERT INTO invoice_lines VALUES (143, 77, 1, 12, 550.00,  6600.00,  3);
INSERT INTO invoice_lines VALUES (144, 77, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (145, 77, 5, 1,  1800.00, 1800.00,  18);
INSERT INTO invoice_lines VALUES (146, 121, 1, 12, 550.00, 6600.00,  3);
INSERT INTO invoice_lines VALUES (147, 121, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (148, 121, 5, 1,  1800.00,1800.00,  18);
INSERT INTO invoice_lines VALUES (149, 122, 1, 12, 550.00, 6600.00,  3);
INSERT INTO invoice_lines VALUES (150, 122, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (151, 122, 5, 1,  1800.00,1800.00,  18);
-- Contract 9 discount leakage: 8 * (792+396+216) = 8 * 1404 = $11,232

-- Total discount leakage so far: 8820 + 2280 + 858 + 11088 + 618.75 + 13200 + 11000 + 11232 = ~$59,097
-- Need ~$60K more to reach ~$120K. We will add more via contracts 33, 35, 32.

-- === Invoices 45-47, 129, 145-146, 155 (contract 33, 12% discount NOT applied) ===
INSERT INTO invoice_lines VALUES (152, 45, 1, 15, 550.00,  8250.00,  3);  -- +$990
INSERT INTO invoice_lines VALUES (153, 45, 2, 12, 330.00,  3960.00,  7);  -- +$475.20
INSERT INTO invoice_lines VALUES (154, 45, 7, 5,  440.00,  2200.00,  22); -- +$264
INSERT INTO invoice_lines VALUES (155, 46, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (156, 46, 2, 12, 330.00,  3960.00,  7);
INSERT INTO invoice_lines VALUES (157, 46, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (158, 47, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (159, 47, 2, 12, 330.00,  3960.00,  7);
INSERT INTO invoice_lines VALUES (160, 47, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (161, 129, 1, 15, 550.00, 8250.00,  3);
INSERT INTO invoice_lines VALUES (162, 129, 2, 12, 330.00, 3960.00,  7);
INSERT INTO invoice_lines VALUES (163, 129, 7, 5,  440.00, 2200.00,  22);
INSERT INTO invoice_lines VALUES (164, 145, 1, 15, 550.00, 8250.00,  3);
INSERT INTO invoice_lines VALUES (165, 145, 2, 12, 330.00, 3960.00,  7);
INSERT INTO invoice_lines VALUES (166, 145, 7, 5,  440.00, 2200.00,  22);
INSERT INTO invoice_lines VALUES (167, 146, 1, 15, 550.00, 8250.00,  3);
INSERT INTO invoice_lines VALUES (168, 146, 2, 12, 330.00, 3960.00,  7);
INSERT INTO invoice_lines VALUES (169, 146, 7, 5,  440.00, 2200.00,  22);
INSERT INTO invoice_lines VALUES (170, 155, 1, 15, 550.00, 8250.00,  3);
INSERT INTO invoice_lines VALUES (171, 155, 2, 12, 330.00, 3960.00,  7);
INSERT INTO invoice_lines VALUES (172, 155, 7, 5,  440.00, 2200.00,  22);
-- Contract 33 discount leakage: 7 * (990+475.20+264) = 7 * 1729.20 = $12,104.40

-- === Invoices 50-52, 131, 147-148, 156 (contract 35, 10% discount NOT applied) ===
INSERT INTO invoice_lines VALUES (173, 50, 1, 15, 550.00,  8250.00,  3);  -- +$825
INSERT INTO invoice_lines VALUES (174, 50, 2, 8,  330.00,  2640.00,  7);  -- +$264
INSERT INTO invoice_lines VALUES (175, 50, 7, 5,  440.00,  2200.00,  22); -- +$220
INSERT INTO invoice_lines VALUES (176, 51, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (177, 51, 2, 8,  330.00,  2640.00,  7);
INSERT INTO invoice_lines VALUES (178, 51, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (179, 52, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (180, 52, 2, 8,  330.00,  2640.00,  7);
INSERT INTO invoice_lines VALUES (181, 52, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (182, 131, 1, 15, 550.00, 8250.00,  3);
INSERT INTO invoice_lines VALUES (183, 131, 2, 8,  330.00, 2640.00,  7);
INSERT INTO invoice_lines VALUES (184, 131, 7, 5,  440.00, 2200.00,  22);
INSERT INTO invoice_lines VALUES (185, 147, 1, 15, 550.00, 8250.00,  3);
INSERT INTO invoice_lines VALUES (186, 147, 2, 8,  330.00, 2640.00,  7);
INSERT INTO invoice_lines VALUES (187, 147, 7, 5,  440.00, 2200.00,  22);
INSERT INTO invoice_lines VALUES (188, 148, 1, 15, 550.00, 8250.00,  3);
INSERT INTO invoice_lines VALUES (189, 148, 2, 8,  330.00, 2640.00,  7);
INSERT INTO invoice_lines VALUES (190, 148, 7, 5,  440.00, 2200.00,  22);
INSERT INTO invoice_lines VALUES (191, 156, 1, 15, 550.00, 8250.00,  3);
INSERT INTO invoice_lines VALUES (192, 156, 2, 8,  330.00, 2640.00,  7);
INSERT INTO invoice_lines VALUES (193, 156, 7, 5,  440.00, 2200.00,  22);
-- Contract 35 discount leakage: 7 * (825+264+220) = 7 * 1309 = $9,163

-- === Invoices 43-44, 128, 149-150 (contract 32, 8% discount NOT applied) ===
INSERT INTO invoice_lines VALUES (194, 43, 1, 5,  550.00,  2750.00,  3);  -- +$220
INSERT INTO invoice_lines VALUES (195, 43, 3, 5,  220.00,  1100.00,  11); -- +$88
INSERT INTO invoice_lines VALUES (196, 44, 1, 5,  550.00,  2750.00,  3);
INSERT INTO invoice_lines VALUES (197, 44, 3, 5,  220.00,  1100.00,  11);
INSERT INTO invoice_lines VALUES (198, 128, 1, 5, 550.00,  2750.00,  3);
INSERT INTO invoice_lines VALUES (199, 128, 3, 5, 220.00,  1100.00,  11);
INSERT INTO invoice_lines VALUES (200, 149, 1, 5, 550.00,  2750.00,  3);
INSERT INTO invoice_lines VALUES (201, 149, 3, 5, 220.00,  1100.00,  11);
INSERT INTO invoice_lines VALUES (202, 150, 1, 5, 550.00,  2750.00,  3);
INSERT INTO invoice_lines VALUES (203, 150, 3, 5, 220.00,  1100.00,  11);
-- Contract 32 discount leakage: 5 * (220+88) = 5 * 308 = $1,540

-- Grand total discount leakage: ~$59,097 + $12,104 + $9,163 + $1,540 = ~$81,904
-- We need about $38K more. Adding some via contracts 34, 31, and overcharge lines.

-- === Invoices 48-49, 130, 163 (contract 34, 5% discount NOT applied) ===
INSERT INTO invoice_lines VALUES (204, 48, 1, 4,  550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (205, 48, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (206, 49, 1, 4,  550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (207, 49, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (208, 130, 1, 4, 550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (209, 130, 4, 5, 165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (210, 163, 1, 4, 550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (211, 163, 4, 5, 165.00,  825.00,   15);

-- === LEAKAGE TYPE 2: Pricing discrepancy -- billed at WRONG unit price ===
-- These lines reference a tier but the unit_price charged differs from the tier price.

-- Invoices 29-30, 119-120 (contract 8, no discount, but wrong unit price)
INSERT INTO invoice_lines VALUES (212, 29, 1, 3,  600.00,  1800.00,  3);  -- tier says 550 -> overcharge $150
INSERT INTO invoice_lines VALUES (213, 29, 3, 5,  260.00,  1300.00,  11); -- tier says 220 -> overcharge $200
INSERT INTO invoice_lines VALUES (214, 30, 1, 3,  600.00,  1800.00,  3);
INSERT INTO invoice_lines VALUES (215, 30, 3, 5,  260.00,  1300.00,  11);
INSERT INTO invoice_lines VALUES (216, 119, 1, 3, 600.00,  1800.00,  3);
INSERT INTO invoice_lines VALUES (217, 119, 3, 5, 260.00,  1300.00,  11);
INSERT INTO invoice_lines VALUES (218, 120, 1, 3, 600.00,  1800.00,  3);
INSERT INTO invoice_lines VALUES (219, 120, 3, 5, 260.00,  1300.00,  11);
-- Contract 8 pricing leakage: 4 * (150+200) = 4 * 350 = $1,400

-- Invoices 34-36, 123-124, 159 (contract 10, wrong unit price on some lines)
INSERT INTO invoice_lines VALUES (220, 34, 1, 2,  620.00,  1240.00,  3);  -- tier 550 -> +$140
INSERT INTO invoice_lines VALUES (221, 34, 4, 5,  200.00,  1000.00,  15); -- tier 165 -> +$175
INSERT INTO invoice_lines VALUES (222, 35, 1, 2,  620.00,  1240.00,  3);
INSERT INTO invoice_lines VALUES (223, 35, 4, 5,  200.00,  1000.00,  15);
INSERT INTO invoice_lines VALUES (224, 36, 1, 2,  620.00,  1240.00,  3);
INSERT INTO invoice_lines VALUES (225, 36, 4, 5,  200.00,  1000.00,  15);
INSERT INTO invoice_lines VALUES (226, 123, 1, 2, 620.00,  1240.00,  3);
INSERT INTO invoice_lines VALUES (227, 123, 4, 5, 200.00,  1000.00,  15);
INSERT INTO invoice_lines VALUES (228, 124, 1, 2, 620.00,  1240.00,  3);
INSERT INTO invoice_lines VALUES (229, 124, 4, 5, 200.00,  1000.00,  15);
INSERT INTO invoice_lines VALUES (230, 159, 1, 2, 620.00,  1240.00,  3);
INSERT INTO invoice_lines VALUES (231, 159, 4, 5, 200.00,  1000.00,  15);
-- Contract 10 pricing leakage: 6 * (140+175) = 6 * 315 = $1,890

-- Invoices 37-38, 125, 160 (contract 29, wrong unit price)
INSERT INTO invoice_lines VALUES (232, 37, 1, 2,  650.00,  1300.00,  3);  -- tier 550 -> +$200
INSERT INTO invoice_lines VALUES (233, 38, 1, 2,  650.00,  1300.00,  3);
INSERT INTO invoice_lines VALUES (234, 125, 1, 2, 650.00,  1300.00,  3);
INSERT INTO invoice_lines VALUES (235, 160, 1, 2, 650.00,  1300.00,  3);
-- Contract 29 pricing leakage: 4 * 200 = $800

-- Invoices 39-40, 126, 161 (contract 30, wrong unit price)
INSERT INTO invoice_lines VALUES (236, 39, 4, 8,  190.00,  1520.00,  15); -- tier 165 -> +$200
INSERT INTO invoice_lines VALUES (237, 40, 4, 8,  190.00,  1520.00,  15);
INSERT INTO invoice_lines VALUES (238, 126, 4, 8, 190.00,  1520.00,  15);
INSERT INTO invoice_lines VALUES (239, 161, 4, 8, 190.00,  1520.00,  15);
-- Contract 30 pricing leakage: 4 * 200 = $800

-- Invoices 41-42, 127, 162 (contract 31, wrong unit price)
INSERT INTO invoice_lines VALUES (240, 41, 1, 2,  600.00,  1200.00,  3);  -- tier 550 -> +$100
INSERT INTO invoice_lines VALUES (241, 41, 8, 2,  350.00,  700.00,   24); -- tier 275 -> +$150
INSERT INTO invoice_lines VALUES (242, 42, 1, 2,  600.00,  1200.00,  3);
INSERT INTO invoice_lines VALUES (243, 42, 8, 2,  350.00,  700.00,   24);
INSERT INTO invoice_lines VALUES (244, 127, 1, 2, 600.00,  1200.00,  3);
INSERT INTO invoice_lines VALUES (245, 127, 8, 2, 350.00,  700.00,   24);
INSERT INTO invoice_lines VALUES (246, 162, 1, 2, 600.00,  1200.00,  3);
INSERT INTO invoice_lines VALUES (247, 162, 8, 2, 350.00,  700.00,   24);
-- Contract 31 pricing leakage: 4 * (100+150) = 4 * 250 = $1,000

-- More significant pricing overcharges on enterprise contracts
-- Invoices 139-140 (contract 1, additional pricing errors)
INSERT INTO invoice_lines VALUES (248, 139, 1, 10, 600.00, 6000.00,  3);  -- tier 550 -> +$500
INSERT INTO invoice_lines VALUES (249, 139, 2, 10, 380.00, 3800.00,  7);  -- tier 330 -> +$500
INSERT INTO invoice_lines VALUES (250, 140, 1, 10, 600.00, 6000.00,  3);
INSERT INTO invoice_lines VALUES (251, 140, 2, 10, 380.00, 3800.00,  7);
-- +$2,000

-- Invoices 141-142 (contract 2, pricing errors)
INSERT INTO invoice_lines VALUES (252, 141, 1, 8,  600.00, 4800.00,  3);  -- tier 550 -> +$400
INSERT INTO invoice_lines VALUES (253, 141, 3, 10, 280.00, 2800.00,  11); -- tier 220 -> +$600
INSERT INTO invoice_lines VALUES (254, 142, 1, 8,  600.00, 4800.00,  3);
INSERT INTO invoice_lines VALUES (255, 142, 3, 10, 280.00, 2800.00,  11);
-- +$2,000

-- Invoices 143-144 (contract 4, pricing errors on large quantities)
INSERT INTO invoice_lines VALUES (256, 143, 1, 15, 600.00,  9000.00,  3);  -- tier 550 -> +$750
INSERT INTO invoice_lines VALUES (257, 143, 2, 15, 380.00,  5700.00,  7);  -- tier 330 -> +$750
INSERT INTO invoice_lines VALUES (258, 144, 1, 15, 600.00,  9000.00,  3);
INSERT INTO invoice_lines VALUES (259, 144, 2, 15, 380.00,  5700.00,  7);
-- +$3,000

-- Additional large pricing mismatches to reach ~$95K
-- Invoice 151 (contract 1, pending)
INSERT INTO invoice_lines VALUES (260, 151, 1, 10, 650.00, 6500.00,  3);  -- tier 550 -> +$1,000
INSERT INTO invoice_lines VALUES (261, 151, 2, 10, 400.00, 4000.00,  7);  -- tier 330 -> +$700

-- Invoice 152 (contract 4, overdue)
INSERT INTO invoice_lines VALUES (262, 152, 1, 15, 650.00, 9750.00,  3);  -- +$1,500
INSERT INTO invoice_lines VALUES (263, 152, 2, 15, 400.00, 6000.00,  7);  -- +$1,050

-- Invoice 153 (contract 6)
INSERT INTO invoice_lines VALUES (264, 153, 1, 10, 650.00, 6500.00,  3);  -- +$1,000
INSERT INTO invoice_lines VALUES (265, 153, 2, 10, 400.00, 4000.00,  7);  -- +$700

-- Invoice 154 (contract 9)
INSERT INTO invoice_lines VALUES (266, 154, 1, 12, 650.00, 7800.00,  3);  -- +$1,200
INSERT INTO invoice_lines VALUES (267, 154, 2, 10, 400.00, 4000.00,  7);  -- +$700

-- Invoices for contracts 38, 39, 40 with correct pricing (no leakage)
INSERT INTO invoice_lines VALUES (268, 57, 1, 4,  550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (269, 57, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (270, 58, 1, 4,  550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (271, 58, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (272, 59, 1, 4,  550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (273, 59, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (274, 60, 1, 8,  550.00,  4400.00,  3);
INSERT INTO invoice_lines VALUES (275, 60, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (276, 61, 1, 8,  550.00,  4400.00,  3);
INSERT INTO invoice_lines VALUES (277, 61, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (278, 62, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (279, 62, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (280, 63, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (281, 63, 2, 10, 330.00,  3300.00,  7);

-- Lines for expired contract invoices (leakage type 1 -- these have correct pricing
-- but the INVOICE itself is the problem since it is after contract expiry)
INSERT INTO invoice_lines VALUES (282, 78, 1, 8,  500.00,  4000.00,  1);
INSERT INTO invoice_lines VALUES (283, 78, 5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (284, 79, 1, 8,  500.00,  4000.00,  1);
INSERT INTO invoice_lines VALUES (285, 79, 5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (286, 80, 1, 8,  500.00,  4000.00,  1);
INSERT INTO invoice_lines VALUES (287, 80, 5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (288, 81, 1, 8,  500.00,  4000.00,  1);
INSERT INTO invoice_lines VALUES (289, 81, 5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (290, 82, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (291, 82, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (292, 83, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (293, 83, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (294, 84, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (295, 84, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (296, 85, 1, 12, 500.00,  6000.00,  1);
INSERT INTO invoice_lines VALUES (297, 85, 5, 1,  1800.00, 1800.00,  18);
INSERT INTO invoice_lines VALUES (298, 86, 1, 12, 500.00,  6000.00,  1);
INSERT INTO invoice_lines VALUES (299, 86, 5, 1,  1800.00, 1800.00,  18);
INSERT INTO invoice_lines VALUES (300, 87, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (301, 87, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (302, 87, 5, 1,  1800.00, 1800.00,  18);
INSERT INTO invoice_lines VALUES (303, 88, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (304, 88, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (305, 88, 5, 1,  1800.00, 1800.00,  18);
INSERT INTO invoice_lines VALUES (306, 89, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (307, 89, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (308, 89, 5, 1,  1800.00, 1800.00,  18);
INSERT INTO invoice_lines VALUES (309, 90, 1, 12, 550.00,  6600.00,  3);
INSERT INTO invoice_lines VALUES (310, 90, 2, 8,  330.00,  2640.00,  7);
INSERT INTO invoice_lines VALUES (311, 91, 1, 12, 550.00,  6600.00,  3);
INSERT INTO invoice_lines VALUES (312, 91, 2, 8,  330.00,  2640.00,  7);
INSERT INTO invoice_lines VALUES (313, 92, 1, 4,  550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (314, 92, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (315, 93, 1, 4,  550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (316, 93, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (317, 94, 1, 4,  550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (318, 94, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (319, 95, 1, 4,  550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (320, 95, 4, 5,  165.00,  825.00,   15);

-- Lines for cancelled contract invoices (leakage type 5)
INSERT INTO invoice_lines VALUES (321, 100, 1, 8,  550.00, 4400.00,  3);
INSERT INTO invoice_lines VALUES (322, 100, 3, 5,  220.00, 1100.00,  11);
INSERT INTO invoice_lines VALUES (323, 101, 1, 8,  550.00, 4400.00,  3);
INSERT INTO invoice_lines VALUES (324, 101, 3, 5,  220.00, 1100.00,  11);
INSERT INTO invoice_lines VALUES (325, 102, 1, 8,  550.00, 4400.00,  3);
INSERT INTO invoice_lines VALUES (326, 102, 3, 5,  220.00, 1100.00,  11);
INSERT INTO invoice_lines VALUES (327, 103, 1, 10, 550.00, 5500.00,  3);
INSERT INTO invoice_lines VALUES (328, 103, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (329, 104, 1, 10, 550.00, 5500.00,  3);
INSERT INTO invoice_lines VALUES (330, 104, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (331, 105, 1, 2,  550.00, 1100.00,  3);
INSERT INTO invoice_lines VALUES (332, 106, 1, 2,  550.00, 1100.00,  3);
INSERT INTO invoice_lines VALUES (333, 107, 1, 2,  550.00, 1100.00,  3);
INSERT INTO invoice_lines VALUES (334, 108, 1, 2,  550.00, 1100.00,  3);
INSERT INTO invoice_lines VALUES (335, 109, 1, 3,  500.00, 1500.00,  1);
INSERT INTO invoice_lines VALUES (336, 109, 5, 1,  1000.00,1000.00,  17);
INSERT INTO invoice_lines VALUES (337, 110, 1, 3,  500.00, 1500.00,  1);
INSERT INTO invoice_lines VALUES (338, 110, 5, 1,  1000.00,1000.00,  17);

-- Lines for duplicate invoices (leakage type 3 -- mirror the original lines)
INSERT INTO invoice_lines VALUES (339, 96, 1, 10, 550.00,  5500.00,  3);
INSERT INTO invoice_lines VALUES (340, 96, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (341, 96, 5, 1,  1000.00, 1000.00,  17);
INSERT INTO invoice_lines VALUES (342, 97, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (343, 97, 2, 15, 330.00,  4950.00,  7);
INSERT INTO invoice_lines VALUES (344, 97, 7, 5,  440.00,  2200.00,  22);
INSERT INTO invoice_lines VALUES (345, 98, 1, 15, 550.00,  8250.00,  3);
INSERT INTO invoice_lines VALUES (346, 98, 2, 10, 330.00,  3300.00,  7);
INSERT INTO invoice_lines VALUES (347, 98, 3, 10, 220.00,  2200.00,  11);
INSERT INTO invoice_lines VALUES (348, 99, 1, 4,  550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (349, 99, 4, 5,  165.00,  825.00,   15);

-- Lines for remaining invoices (correct pricing, legitimate)
INSERT INTO invoice_lines VALUES (350, 111, 1, 5, 550.00,  2750.00,  3);
INSERT INTO invoice_lines VALUES (351, 111, 4, 5, 165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (352, 112, 1, 5, 550.00,  2750.00,  3);
INSERT INTO invoice_lines VALUES (353, 112, 4, 5, 165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (354, 132, 4, 5, 165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (355, 133, 4, 3, 165.00,  495.00,   15);
INSERT INTO invoice_lines VALUES (356, 134, 1, 4, 550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (357, 134, 4, 5, 165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (358, 135, 1, 4, 550.00,  2200.00,  3);
INSERT INTO invoice_lines VALUES (359, 135, 4, 5, 165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (360, 136, 1, 10, 550.00, 5500.00,  3);
INSERT INTO invoice_lines VALUES (361, 136, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (362, 137, 1, 10, 550.00, 5500.00,  3);
INSERT INTO invoice_lines VALUES (363, 137, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (364, 138, 1, 10, 550.00, 5500.00,  3);
INSERT INTO invoice_lines VALUES (365, 138, 2, 10, 330.00, 3300.00,  7);
INSERT INTO invoice_lines VALUES (366, 53, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (367, 54, 4, 5,  165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (368, 55, 4, 3,  165.00,  495.00,   15);
INSERT INTO invoice_lines VALUES (369, 56, 4, 3,  165.00,  495.00,   15);
INSERT INTO invoice_lines VALUES (370, 157, 1, 5, 550.00,  2750.00,  3);
INSERT INTO invoice_lines VALUES (371, 157, 4, 5, 165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (372, 158, 1, 3, 550.00,  1650.00,  3);
INSERT INTO invoice_lines VALUES (373, 158, 4, 5, 165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (374, 164, 4, 5, 165.00,  825.00,   15);
INSERT INTO invoice_lines VALUES (375, 165, 4, 3, 165.00,  495.00,   15);

-- -------------------------------------------------------------------------
-- PAYMENTS (~140 rows -- most paid invoices get a payment)
-- -------------------------------------------------------------------------
INSERT INTO payments VALUES (1,   1,   '2024-01-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (2,   2,   '2024-02-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (3,   3,   '2024-03-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (4,   4,   '2024-04-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (5,   5,   '2024-05-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (6,   6,   '2024-06-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (7,   7,   '2024-01-22', 8000.00,  'Wire');
INSERT INTO payments VALUES (8,   8,   '2024-02-22', 8000.00,  'Wire');
INSERT INTO payments VALUES (9,   9,   '2024-03-22', 8000.00,  'Wire');
INSERT INTO payments VALUES (10,  10,  '2024-04-22', 8000.00,  'Wire');
INSERT INTO payments VALUES (11,  11,  '2024-03-20', 4000.00,  'ACH');
INSERT INTO payments VALUES (12,  12,  '2024-04-20', 4000.00,  'ACH');
INSERT INTO payments VALUES (13,  13,  '2024-05-20', 4000.00,  'ACH');
INSERT INTO payments VALUES (14,  14,  '2024-01-25', 16667.00, 'Wire');
INSERT INTO payments VALUES (15,  15,  '2024-02-25', 16667.00, 'Wire');
INSERT INTO payments VALUES (16,  16,  '2024-03-25', 16667.00, 'Wire');
INSERT INTO payments VALUES (17,  17,  '2024-04-25', 16667.00, 'Wire');
INSERT INTO payments VALUES (18,  18,  '2024-06-20', 3000.00,  'Credit Card');
INSERT INTO payments VALUES (19,  19,  '2024-07-20', 3000.00,  'Credit Card');
INSERT INTO payments VALUES (20,  20,  '2024-08-20', 3000.00,  'Credit Card');
INSERT INTO payments VALUES (21,  21,  '2024-01-20', 12500.00, 'ACH');
INSERT INTO payments VALUES (22,  22,  '2024-02-20', 12500.00, 'ACH');
INSERT INTO payments VALUES (23,  23,  '2024-03-20', 12500.00, 'ACH');
INSERT INTO payments VALUES (24,  24,  '2024-04-20', 12500.00, 'ACH');
INSERT INTO payments VALUES (25,  25,  '2024-01-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (26,  26,  '2024-02-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (27,  27,  '2024-03-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (28,  28,  '2024-04-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (29,  29,  '2024-09-20', 3500.00,  'ACH');
INSERT INTO payments VALUES (30,  30,  '2024-10-20', 3500.00,  'ACH');
INSERT INTO payments VALUES (31,  31,  '2024-01-20', 13333.00, 'Wire');
INSERT INTO payments VALUES (32,  32,  '2024-02-20', 13333.00, 'Wire');
INSERT INTO payments VALUES (33,  33,  '2024-03-20', 13333.00, 'Wire');
INSERT INTO payments VALUES (34,  34,  '2024-04-20', 2500.00,  'Credit Card');
INSERT INTO payments VALUES (35,  35,  '2024-05-20', 2500.00,  'Credit Card');
INSERT INTO payments VALUES (36,  36,  '2024-06-20', 2500.00,  'Credit Card');
INSERT INTO payments VALUES (37,  37,  '2024-01-22', 1667.00,  'ACH');
INSERT INTO payments VALUES (38,  38,  '2024-02-22', 1667.00,  'ACH');
INSERT INTO payments VALUES (39,  39,  '2024-03-20', 1500.00,  'Check');
INSERT INTO payments VALUES (40,  40,  '2024-04-20', 1500.00,  'Check');
INSERT INTO payments VALUES (41,  41,  '2024-06-20', 2000.00,  'ACH');
INSERT INTO payments VALUES (42,  42,  '2024-07-20', 2000.00,  'ACH');
INSERT INTO payments VALUES (43,  43,  '2024-04-22', 5000.00,  'Wire');
INSERT INTO payments VALUES (44,  44,  '2024-05-22', 5000.00,  'Wire');
INSERT INTO payments VALUES (45,  45,  '2024-01-22', 16250.00, 'Wire');
INSERT INTO payments VALUES (46,  46,  '2024-02-22', 16250.00, 'Wire');
INSERT INTO payments VALUES (47,  47,  '2024-03-22', 16250.00, 'Wire');
INSERT INTO payments VALUES (48,  48,  '2024-06-22', 3500.00,  'ACH');
INSERT INTO payments VALUES (49,  49,  '2024-07-22', 3500.00,  'ACH');
INSERT INTO payments VALUES (50,  50,  '2024-01-20', 14583.00, 'Wire');
INSERT INTO payments VALUES (51,  51,  '2024-02-20', 14583.00, 'Wire');
INSERT INTO payments VALUES (52,  52,  '2024-03-20', 14583.00, 'Wire');
INSERT INTO payments VALUES (53,  53,  '2024-01-22', 1000.00,  'Credit Card');
INSERT INTO payments VALUES (54,  54,  '2024-02-22', 1000.00,  'Credit Card');
INSERT INTO payments VALUES (55,  55,  '2024-05-20', 1333.00,  'Check');
INSERT INTO payments VALUES (56,  56,  '2024-06-20', 1333.00,  'Check');
INSERT INTO payments VALUES (57,  57,  '2024-01-20', 3750.00,  'ACH');
INSERT INTO payments VALUES (58,  58,  '2024-02-20', 3750.00,  'ACH');
INSERT INTO payments VALUES (59,  59,  '2024-03-20', 3750.00,  'ACH');
INSERT INTO payments VALUES (60,  60,  '2025-01-20', 8333.00,  'Wire');
INSERT INTO payments VALUES (61,  62,  '2024-07-20', 12917.00, 'ACH');
INSERT INTO payments VALUES (62,  63,  '2024-08-20', 12917.00, 'ACH');
INSERT INTO payments VALUES (63,  64,  '2024-07-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (64,  65,  '2024-08-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (65,  66,  '2024-09-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (66,  67,  '2024-05-22', 8000.00,  'Wire');
INSERT INTO payments VALUES (67,  68,  '2024-06-22', 8000.00,  'Wire');
INSERT INTO payments VALUES (68,  69,  '2024-05-22', 16667.00, 'Wire');
INSERT INTO payments VALUES (69,  70,  '2024-06-22', 16667.00, 'Wire');
INSERT INTO payments VALUES (70,  71,  '2024-05-20', 12500.00, 'ACH');
INSERT INTO payments VALUES (71,  72,  '2024-06-20', 12500.00, 'ACH');
INSERT INTO payments VALUES (72,  73,  '2024-05-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (73,  74,  '2024-06-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (74,  75,  '2024-04-20', 13333.00, 'Wire');
INSERT INTO payments VALUES (75,  76,  '2024-05-20', 13333.00, 'Wire');
INSERT INTO payments VALUES (76,  77,  '2024-06-20', 13333.00, 'Wire');

-- Payments for expired-contract invoices (the leakage was already collected!)
INSERT INTO payments VALUES (77,  78,  '2023-01-22', 7500.00,  'ACH');
INSERT INTO payments VALUES (78,  79,  '2023-02-22', 7500.00,  'ACH');
INSERT INTO payments VALUES (79,  80,  '2023-03-22', 7500.00,  'ACH');
INSERT INTO payments VALUES (80,  81,  '2023-04-22', 7500.00,  'ACH');
INSERT INTO payments VALUES (81,  82,  '2024-01-22', 14167.00, 'Wire');
INSERT INTO payments VALUES (82,  83,  '2024-02-22', 14167.00, 'Wire');
INSERT INTO payments VALUES (83,  84,  '2024-03-22', 14167.00, 'Wire');
INSERT INTO payments VALUES (84,  85,  '2023-01-20', 11667.00, 'Wire');
INSERT INTO payments VALUES (85,  86,  '2023-02-20', 11667.00, 'Wire');
INSERT INTO payments VALUES (86,  87,  '2024-01-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (87,  88,  '2024-02-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (88,  89,  '2024-03-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (89,  90,  '2023-07-20', 13333.00, 'ACH');
INSERT INTO payments VALUES (90,  91,  '2023-08-20', 13333.00, 'ACH');
INSERT INTO payments VALUES (91,  92,  '2024-01-20', 3333.00,  'ACH');
INSERT INTO payments VALUES (92,  93,  '2024-02-20', 3333.00,  'ACH');
INSERT INTO payments VALUES (93,  94,  '2024-03-20', 3333.00,  'ACH');
INSERT INTO payments VALUES (94,  95,  '2024-04-20', 3333.00,  'ACH');

-- Payments for duplicate invoices (double-paid!)
INSERT INTO payments VALUES (95,  96,  '2024-01-22', 10000.00, 'ACH');
INSERT INTO payments VALUES (96,  97,  '2024-01-28', 16667.00, 'Wire');
INSERT INTO payments VALUES (97,  98,  '2024-01-25', 15000.00, 'Wire');
INSERT INTO payments VALUES (98,  99,  '2024-06-20', 3500.00,  'ACH');

-- Payments for cancelled-contract invoices
INSERT INTO payments VALUES (99,  100, '2023-06-20', 7083.00,  'Wire');
INSERT INTO payments VALUES (100, 101, '2023-07-20', 7083.00,  'Wire');
INSERT INTO payments VALUES (101, 102, '2023-08-20', 7083.00,  'Wire');
INSERT INTO payments VALUES (102, 103, '2023-10-22', 11667.00, 'ACH');
INSERT INTO payments VALUES (103, 104, '2023-11-22', 11667.00, 'ACH');
INSERT INTO payments VALUES (104, 105, '2023-06-22', 1833.00,  'Credit Card');
INSERT INTO payments VALUES (105, 106, '2023-07-22', 1833.00,  'Credit Card');
INSERT INTO payments VALUES (106, 107, '2023-08-22', 1833.00,  'Credit Card');
INSERT INTO payments VALUES (107, 108, '2023-09-22', 1833.00,  'Credit Card');
INSERT INTO payments VALUES (108, 109, '2022-07-20', 3000.00,  'Wire');
INSERT INTO payments VALUES (109, 110, '2022-08-20', 3000.00,  'Wire');

-- Remaining payments for legitimate invoices
INSERT INTO payments VALUES (110, 111, '2024-06-22', 4000.00,  'ACH');
INSERT INTO payments VALUES (111, 112, '2024-07-22', 4000.00,  'ACH');
INSERT INTO payments VALUES (112, 113, '2024-09-20', 3000.00,  'Credit Card');
INSERT INTO payments VALUES (113, 114, '2024-10-20', 3000.00,  'Credit Card');
INSERT INTO payments VALUES (114, 115, '2024-07-20', 12500.00, 'ACH');
INSERT INTO payments VALUES (115, 116, '2024-08-20', 12500.00, 'ACH');
INSERT INTO payments VALUES (116, 117, '2024-07-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (117, 118, '2024-08-22', 15000.00, 'Wire');
INSERT INTO payments VALUES (118, 119, '2024-11-20', 3500.00,  'ACH');
INSERT INTO payments VALUES (119, 120, '2024-12-20', 3500.00,  'ACH');
INSERT INTO payments VALUES (120, 121, '2024-07-20', 13333.00, 'Wire');
INSERT INTO payments VALUES (121, 122, '2024-08-20', 13333.00, 'Wire');
INSERT INTO payments VALUES (122, 123, '2024-07-22', 2500.00,  'Credit Card');
INSERT INTO payments VALUES (123, 124, '2024-08-22', 2500.00,  'Credit Card');
INSERT INTO payments VALUES (124, 125, '2024-03-20', 1667.00,  'ACH');
INSERT INTO payments VALUES (125, 126, '2024-05-22', 1500.00,  'Check');
INSERT INTO payments VALUES (126, 127, '2024-08-20', 2000.00,  'ACH');
INSERT INTO payments VALUES (127, 128, '2024-06-22', 5000.00,  'Wire');
INSERT INTO payments VALUES (128, 129, '2024-04-22', 16250.00, 'Wire');
INSERT INTO payments VALUES (129, 130, '2024-08-22', 3500.00,  'ACH');
INSERT INTO payments VALUES (130, 131, '2024-04-20', 14583.00, 'Wire');
INSERT INTO payments VALUES (131, 132, '2024-03-22', 1000.00,  'Credit Card');
INSERT INTO payments VALUES (132, 133, '2024-07-22', 1333.00,  'Check');
INSERT INTO payments VALUES (133, 134, '2024-04-20', 3750.00,  'ACH');
INSERT INTO payments VALUES (134, 135, '2024-05-20', 3750.00,  'ACH');
INSERT INTO payments VALUES (135, 136, '2024-09-22', 12917.00, 'ACH');
INSERT INTO payments VALUES (136, 137, '2024-10-22', 12917.00, 'ACH');
INSERT INTO payments VALUES (137, 138, '2024-11-22', 12917.00, 'ACH');
INSERT INTO payments VALUES (138, 139, '2024-10-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (139, 140, '2024-11-20', 10000.00, 'ACH');
INSERT INTO payments VALUES (140, 141, '2024-07-22', 8000.00,  'Wire');
INSERT INTO payments VALUES (141, 142, '2024-08-22', 8000.00,  'Wire');
INSERT INTO payments VALUES (142, 143, '2024-07-22', 16667.00, 'Wire');
INSERT INTO payments VALUES (143, 144, '2024-08-22', 16667.00, 'Wire');
INSERT INTO payments VALUES (144, 145, '2024-05-22', 16250.00, 'Wire');
INSERT INTO payments VALUES (145, 146, '2024-06-22', 16250.00, 'Wire');
INSERT INTO payments VALUES (146, 147, '2024-05-20', 14583.00, 'Wire');
INSERT INTO payments VALUES (147, 148, '2024-06-20', 14583.00, 'Wire');
INSERT INTO payments VALUES (148, 149, '2024-07-22', 5000.00,  'Wire');
INSERT INTO payments VALUES (149, 150, '2024-08-22', 5000.00,  'Wire');
INSERT INTO payments VALUES (150, 157, '2024-08-22', 4000.00,  'ACH');
INSERT INTO payments VALUES (151, 158, '2024-11-22', 3000.00,  'Credit Card');
INSERT INTO payments VALUES (152, 159, '2024-09-22', 2500.00,  'Credit Card');
INSERT INTO payments VALUES (153, 160, '2024-04-22', 1667.00,  'ACH');
INSERT INTO payments VALUES (154, 161, '2024-06-22', 1500.00,  'Check');
INSERT INTO payments VALUES (155, 162, '2024-09-22', 2000.00,  'ACH');
INSERT INTO payments VALUES (156, 163, '2024-09-22', 3500.00,  'ACH');
INSERT INTO payments VALUES (157, 164, '2024-04-22', 1000.00,  'Credit Card');
INSERT INTO payments VALUES (158, 165, '2024-08-22', 1333.00,  'Check');
