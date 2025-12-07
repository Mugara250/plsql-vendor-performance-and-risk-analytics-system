-- Clean all tables first
DELETE FROM vendor_alert;
DELETE FROM vendor_score;
DELETE FROM delivery_performance;
DELETE FROM purchase_order;
DELETE FROM vendor;
DELETE FROM scoring_config;
COMMIT;

-- Step 1: Insert 150 vendors
INSERT INTO vendor (vendor_id, vendor_name, status, category, created_date)
SELECT 
    level,
    'Vendor ' || level,
    CASE WHEN MOD(level, 10) != 0 THEN 'ACTIVE' ELSE 'INACTIVE' END,
    CASE 
        WHEN level <= 30 THEN 'STRATEGIC'
        WHEN level <= 90 THEN 'PREFERRED'
        ELSE 'STANDARD'
    END,
    SYSDATE - DBMS_RANDOM.VALUE(1, 365)
FROM dual 
CONNECT BY level <= 150;
COMMIT;

-- Step 2: Insert 500 purchase orders
INSERT INTO purchase_order (po_id, vendor_id, po_number, order_date, order_amount, promised_date, status)
SELECT 
    level,
    TRUNC(DBMS_RANDOM.VALUE(1, 151)),
    'PO' || TO_CHAR(level),
    SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 180)),
    ROUND(DBMS_RANDOM.VALUE(100, 10000), 2),
    SYSDATE - TRUNC(DBMS_RANDOM.VALUE(0, 179)),
    CASE 
        WHEN MOD(level, 15) = 0 THEN 'CANCELLED'
        WHEN MOD(level, 10) = 0 THEN 'PENDING'
        ELSE 'DELIVERED'
    END
FROM dual 
CONNECT BY level <= 500;
COMMIT;

-- Step 3: Insert delivery data
INSERT INTO delivery_performance (delivery_id, po_id, delivery_date, received_qty, defective_qty)
SELECT 
    ROWNUM,
    po_id,
    SYSDATE - TRUNC(DBMS_RANDOM.VALUE(0, 150)),
    TRUNC(DBMS_RANDOM.VALUE(500, 2000)),
    TRUNC(DBMS_RANDOM.VALUE(0, 100))
FROM purchase_order 
WHERE status = 'DELIVERED'
AND ROWNUM <= 400;
COMMIT;

UPDATE delivery_performance dp
SET 
    days_late = GREATEST(0, dp.delivery_date - (SELECT promised_date FROM purchase_order po WHERE po.po_id = dp.po_id)),
    defect_rate = ROUND((dp.defective_qty / NULLIF(dp.received_qty, 0)) * 100, 2)
WHERE dp.received_qty > 0;
COMMIT;

-- Step 4: Insert vendor scores
INSERT INTO vendor_score (score_id, vendor_id, score_date, performance_score, risk_score, overall_score, score_rank)
SELECT 
    ROWNUM,
    TRUNC(DBMS_RANDOM.VALUE(1, 151)),
    TRUNC(SYSDATE) - TRUNC(DBMS_RANDOM.VALUE(0, 90)) + (ROWNUM / 86400),
    ROUND(DBMS_RANDOM.VALUE(40, 100), 2),
    ROUND(DBMS_RANDOM.VALUE(10, 70), 2),
    ROUND(DBMS_RANDOM.VALUE(50, 100), 2),
    CASE 
        WHEN DBMS_RANDOM.VALUE(0, 100) >= 85 THEN 'A'
        WHEN DBMS_RANDOM.VALUE(0, 100) >= 70 THEN 'B'
        WHEN DBMS_RANDOM.VALUE(0, 100) >= 50 THEN 'C'
        ELSE 'D'
    END
FROM dual 
CONNECT BY level <= 450;
COMMIT;

-- Step 5: Insert vendor alerts
DECLARE
    max_id NUMBER;
BEGIN
    SELECT NVL(MAX(alert_id), 0) INTO max_id FROM vendor_alert;
    
    INSERT INTO vendor_alert (alert_id, vendor_id, alert_type, alert_date, severity, is_resolved)
    SELECT 
        max_id + ROWNUM,
        TRUNC(DBMS_RANDOM.VALUE(1, 151)),
        CASE MOD(ROWNUM, 3)
            WHEN 0 THEN 'LOW_SCORE'
            WHEN 1 THEN 'LATE_DELIVERY'
            WHEN 2 THEN 'HIGH_DEFECTS'
        END,
        SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 60)),
        CASE MOD(ROWNUM, 5)
            WHEN 0 THEN 'HIGH'
            WHEN 1 THEN 'MEDIUM'
            ELSE 'LOW'
        END,
        CASE WHEN MOD(ROWNUM, 4) = 0 THEN 'Y' ELSE 'N' END
    FROM dual 
    CONNECT BY level <= 200;
    
    COMMIT;
END;
/

-- Step 6: Insert scoring config (only if empty)
DECLARE
    config_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO config_count FROM scoring_config;
    
    IF config_count = 0 THEN
        INSERT INTO scoring_config (config_id, config_key, config_value, description, last_updated)
        SELECT 1, 'MIN_SCORE_ALERT', '50', 'Minimum overall score before alert triggers', SYSDATE FROM dual UNION ALL
        SELECT 2, 'DEFECT_THRESHOLD', '10', 'Maximum acceptable defect rate percentage', SYSDATE FROM dual UNION ALL
        SELECT 3, 'LATE_THRESHOLD', '7', 'Days late before delivery alert triggers', SYSDATE FROM dual UNION ALL
        SELECT 4, 'PERFORMANCE_WEIGHT', '70', 'Weight for performance score in calculation', SYSDATE FROM dual UNION ALL
        SELECT 5, 'RISK_WEIGHT', '30', 'Weight for risk score in calculation', SYSDATE FROM dual UNION ALL
        SELECT 6, 'SCORE_A_MIN', '85', 'Minimum score for A grade', SYSDATE FROM dual UNION ALL
        SELECT 7, 'SCORE_B_MIN', '70', 'Minimum score for B grade', SYSDATE FROM dual UNION ALL
        SELECT 8, 'SCORE_C_MIN', '50', 'Minimum score for C grade', SYSDATE FROM dual;
        
        COMMIT;
    END IF;
END;
/

-- Final count
SELECT 'VENDOR' as table_name, COUNT(*) as row_count FROM vendor
UNION ALL 
SELECT 'PURCHASE_ORDER', COUNT(*) FROM purchase_order
UNION ALL 
SELECT 'DELIVERY_PERFORMANCE', COUNT(*) FROM delivery_performance
UNION ALL 
SELECT 'VENDOR_SCORE', COUNT(*) FROM vendor_score
UNION ALL 
SELECT 'VENDOR_ALERT', COUNT(*) FROM vendor_alert
UNION ALL 
SELECT 'SCORING_CONFIG', COUNT(*) FROM scoring_config
ORDER BY table_name;