-- MINIMAL TEST SCRIPT - Tests only the core functionality
SET SERVEROUTPUT ON

-- Test 1: Check if system restricts access properly
DECLARE
    v_day VARCHAR2(20);
    v_access_allowed BOOLEAN;
BEGIN
    SELECT TO_CHAR(SYSDATE, 'DAY') INTO v_day FROM dual;
    v_access_allowed := check_access_restriction('TEST');
    
    DBMS_OUTPUT.PUT_LINE('Day: ' || v_day);
    DBMS_OUTPUT.PUT_LINE('Access allowed? ' || CASE WHEN v_access_allowed THEN 'YES' ELSE 'NO' END);
END;
/

-- Test 2: Try to insert (tests the trigger)
DECLARE
    v_max_id NUMBER;
BEGIN
    SELECT NVL(MAX(vendor_id), 0) + 1 INTO v_max_id FROM vendor;
    
    BEGIN
        INSERT INTO vendor (vendor_id, vendor_name, status, category)
        VALUES (v_max_id, 'Test Vendor', 'ACTIVE', 'TEST');
        DBMS_OUTPUT.PUT_LINE('Insert succeeded - Today is weekend');
        ROLLBACK;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Insert blocked - Today is weekday/holiday: ' || SQLERRM);
    END;
END;
/

-- Test 3: Verify audit logging worked
SELECT 'Audit entries: ' || COUNT(*) as audit_count FROM vendor_audit_log;