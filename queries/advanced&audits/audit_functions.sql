-- 4. Audit logging function
CREATE OR REPLACE FUNCTION log_audit_trail(
    p_table_name  IN VARCHAR2,
    p_operation   IN VARCHAR2,
    p_vendor_id   IN NUMBER DEFAULT NULL,
    p_old_values  IN CLOB DEFAULT NULL,
    p_new_values  IN CLOB DEFAULT NULL,
    p_status      IN VARCHAR2 DEFAULT 'SUCCESS',
    p_error_msg   IN VARCHAR2 DEFAULT NULL
) RETURN NUMBER IS
    v_audit_id NUMBER;
    v_ip_address VARCHAR2(50);
BEGIN
    -- Get IP address (simplified)
    BEGIN
        SELECT SYS_CONTEXT('USERENV', 'IP_ADDRESS') INTO v_ip_address FROM dual;
    EXCEPTION
        WHEN OTHERS THEN v_ip_address := 'UNKNOWN';
    END;
    
    -- Get next audit ID
    SELECT audit_seq.NEXTVAL INTO v_audit_id FROM dual;
    
    -- Insert audit record
    INSERT INTO vendor_audit_log (
        audit_id, table_name, operation, vendor_id,
        old_values, new_values, user_id,
        ip_address, status, error_message
    ) VALUES (
        v_audit_id, p_table_name, p_operation, p_vendor_id,
        p_old_values, p_new_values, USER,
        v_ip_address, p_status, p_error_msg
    );
    
    COMMIT;
    RETURN v_audit_id;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1; -- Error code
END log_audit_trail;
/

-- 5. Restriction check function
CREATE OR REPLACE FUNCTION check_access_restriction(
    p_operation IN VARCHAR2
) RETURN BOOLEAN IS
    v_day_of_week VARCHAR2(20);
    v_is_holiday NUMBER;
BEGIN
    -- Get day of week (1=Sunday, 7=Saturday in Oracle)
    SELECT TO_CHAR(SYSDATE, 'DY') INTO v_day_of_week FROM dual;
    
    -- Check if weekday (Monday-Friday)
    IF v_day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
        -- Check if today is a holiday
        SELECT COUNT(*) INTO v_is_holiday
        FROM system_holidays
        WHERE TRUNC(holiday_date) = TRUNC(SYSDATE);
        
        IF v_is_holiday > 0 THEN
            -- It's a holiday
            log_audit_trail(
                p_table_name => 'VENDOR',
                p_operation => p_operation,
                p_status => 'DENIED',
                p_error_msg => 'Operation not allowed on holidays: ' || 
                              (SELECT holiday_name FROM system_holidays 
                               WHERE TRUNC(holiday_date) = TRUNC(SYSDATE) AND ROWNUM = 1)
            );
            RETURN FALSE; -- Deny access
        ELSE
            -- It's a weekday (not holiday)
            log_audit_trail(
                p_table_name => 'VENDOR',
                p_operation => p_operation,
                p_status => 'DENIED',
                p_error_msg => 'Operation not allowed on weekdays (Monday-Friday)'
            );
            RETURN FALSE; -- Deny access
        END IF;
    ELSE
        -- It's weekend (Saturday or Sunday)
        RETURN TRUE; -- Allow access
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        log_audit_trail(
            p_table_name => 'VENDOR',
            p_operation => p_operation,
            p_status => 'ERROR',
            p_error_msg => 'Error checking restriction: ' || SQLERRM
        );
        RETURN FALSE;
END check_access_restriction;
/