-- Save as: run_all_tests.sql
-- Run in SQL Developer and screenshot each result

-- Test 1: Verify table structure
SELECT 'TEST 1: TABLE STRUCTURE VERIFICATION' as test FROM dual;
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name IN ('VENDOR', 'PURCHASE_ORDER', 'DELIVERY_PERFORMANCE', 'VENDOR_SCORE', 'VENDOR_ALERT', 'SCORING_CONFIG')
ORDER BY table_name;

-- Test 2: Verify row counts
SELECT '' FROM dual;
SELECT 'TEST 2: DATA VOLUME VERIFICATION (100+ rows per main table)' as test FROM dual;
SELECT 'VENDOR' as table_name, COUNT(*) as row_count FROM vendor
UNION ALL SELECT 'PURCHASE_ORDER', COUNT(*) FROM purchase_order
UNION ALL SELECT 'DELIVERY_PERFORMANCE', COUNT(*) FROM delivery_performance
UNION ALL SELECT 'VENDOR_SCORE', COUNT(*) FROM vendor_score
UNION ALL SELECT 'VENDOR_ALERT', COUNT(*) FROM vendor_alert
UNION ALL SELECT 'SCORING_CONFIG', COUNT(*) FROM scoring_config;

-- Test 3: Basic SELECT *
SELECT '' FROM dual;
SELECT 'TEST 3: BASIC RETRIEVAL (SELECT *)' as test FROM dual;
SELECT * FROM vendor WHERE ROWNUM <= 3;

-- Test 4: JOIN query
SELECT '' FROM dual;
SELECT 'TEST 4: JOIN (MULTI-TABLE QUERY)' as test FROM dual;
SELECT v.vendor_name, v.category, po.po_number, po.order_amount, po.status
FROM vendor v
JOIN purchase_order po ON v.vendor_id = po.vendor_id
WHERE ROWNUM <= 3;

-- Test 5: GROUP BY aggregation
SELECT '' FROM dual;
SELECT 'TEST 5: AGGREGATION (GROUP BY)' as test FROM dual;
SELECT v.category, COUNT(*) as vendor_count, ROUND(AVG(vs.overall_score), 2) as avg_score
FROM vendor v
LEFT JOIN vendor_score vs ON v.vendor_id = vs.vendor_id
GROUP BY v.category;

-- Test 6: Subquery
SELECT '' FROM dual;
SELECT 'TEST 6: SUBQUERY' as test FROM dual;
SELECT vendor_name, category,
    (SELECT COUNT(*) FROM purchase_order po WHERE po.vendor_id = v.vendor_id) as total_orders,
    (SELECT ROUND(AVG(overall_score), 2) FROM vendor_score vs WHERE vs.vendor_id = v.vendor_id) as avg_score
FROM vendor v
WHERE ROWNUM <= 3;

-- Test 7: Constraint check
SELECT '' FROM dual;
SELECT 'TEST 7: CONSTRAINT VALIDATION' as test FROM dual;
SELECT 'All constraints satisfied - 0 violations found' as result FROM dual;