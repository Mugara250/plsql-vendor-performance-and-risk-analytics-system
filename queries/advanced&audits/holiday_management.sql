-- 1. Create holiday management table
CREATE TABLE system_holidays (
    holiday_id    NUMBER(5) PRIMARY KEY,
    holiday_date  DATE NOT NULL,
    holiday_name  VARCHAR2(100) NOT NULL,
    description   VARCHAR2(200),
    created_by    VARCHAR2(50) DEFAULT USER,
    created_date  DATE DEFAULT SYSDATE
);

-- 2. Create audit log table
CREATE TABLE vendor_audit_log (
    audit_id      NUMBER(12) PRIMARY KEY,
    table_name    VARCHAR2(30) NOT NULL,
    operation     VARCHAR2(10) NOT NULL,
    vendor_id     NUMBER(10),
    old_values    CLOB,
    new_values    CLOB,
    user_id       VARCHAR2(50) DEFAULT USER,
    attempt_time  TIMESTAMP DEFAULT SYSTIMESTAMP,
    ip_address    VARCHAR2(50),
    status        VARCHAR2(20) DEFAULT 'ATTEMPTED',
    error_message VARCHAR2(500)
);

-- Create sequence for audit IDs
CREATE SEQUENCE audit_seq START WITH 1 INCREMENT BY 1;

-- 3. Insert sample holidays (next month)
DECLARE
    v_next_month DATE := TRUNC(ADD_MONTHS(SYSDATE, 1), 'MM');
BEGIN
    -- New Year's Day
    INSERT INTO system_holidays VALUES (1, v_next_month, 'New Years Day', 'Public Holiday', USER, SYSDATE);
    
    -- First Monday of month
    INSERT INTO system_holidays VALUES (2, NEXT_DAY(v_next_month - 1, 'MONDAY'), 'Monthly Holiday', 'First Monday', USER, SYSDATE);
    
    -- 15th of month
    INSERT INTO system_holidays VALUES (3, v_next_month + 14, 'Mid-Month Break', 'Monthly break', USER, SYSDATE);
    
    COMMIT;
END;
/