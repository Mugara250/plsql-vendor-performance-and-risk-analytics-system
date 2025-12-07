-- 6. Compound trigger for VENDOR table (handles INSERT, UPDATE, DELETE)
CREATE OR REPLACE TRIGGER trg_vendor_compound
FOR INSERT OR UPDATE OR DELETE ON vendor
COMPOUND TRIGGER

    -- Declaration section
    TYPE vendor_rec IS RECORD (
        vendor_id vendor.vendor_id%TYPE,
        vendor_name vendor.vendor_name%TYPE,
        operation VARCHAR2(10)
    );
    
    TYPE vendor_list IS TABLE OF vendor_rec;
    g_vendor_changes vendor_list := vendor_list();
    
    -- Before each row
    BEFORE EACH ROW IS
        v_access_allowed BOOLEAN;
        v_audit_id NUMBER;
    BEGIN
        -- Check restriction
        IF INSERTING THEN
            v_access_allowed := check_access_restriction('INSERT');
        ELSIF UPDATING THEN
            v_access_allowed := check_access_restriction('UPDATE');
        ELSIF DELETING THEN
            v_access_allowed := check_access_restriction('DELETE');
        END IF;
        
        IF NOT v_access_allowed THEN
            RAISE_APPLICATION_ERROR(-20001, 
                'VENDOR operations not allowed on weekdays or holidays. ' ||
                'Allowed only on weekends (Saturday/Sunday).');
        END IF;
        
        -- Store changes for auditing
        g_vendor_changes.EXTEND;
        IF INSERTING THEN
            g_vendor_changes(g_vendor_changes.LAST) := vendor_rec(:NEW.vendor_id, :NEW.vendor_name, 'INSERT');
        ELSIF UPDATING THEN
            g_vendor_changes(g_vendor_changes.LAST) := vendor_rec(:NEW.vendor_id, :NEW.vendor_name, 'UPDATE');
        ELSIF DELETING THEN
            g_vendor_changes(g_vendor_changes.LAST) := vendor_rec(:OLD.vendor_id, :OLD.vendor_name, 'DELETE');
        END IF;
    END BEFORE EACH ROW;
    
    -- After statement
    AFTER STATEMENT IS
        v_audit_id NUMBER;
    BEGIN
        -- Log all changes
        FOR i IN 1..g_vendor_changes.COUNT LOOP
            v_audit_id := log_audit_trail(
                p_table_name => 'VENDOR',
                p_operation => g_vendor_changes(i).operation,
                p_vendor_id => g_vendor_changes(i).vendor_id,
                p_status => 'SUCCESS'
            );
        END LOOP;
    END AFTER STATEMENT;
    
END trg_vendor_compound;
/

-- 7. Compound trigger for PURCHASE_ORDER table (fixed version)
CREATE OR REPLACE TRIGGER trg_po_compound
FOR INSERT OR UPDATE OR DELETE ON purchase_order
COMPOUND TRIGGER

    -- Declaration section
    TYPE po_rec IS RECORD (
        po_id purchase_order.po_id%TYPE,
        vendor_id purchase_order.vendor_id%TYPE,
        operation VARCHAR2(10)
    );
    
    TYPE po_list IS TABLE OF po_rec;
    g_po_changes po_list := po_list();
    
    -- Before each row
    BEFORE EACH ROW IS
        v_access_allowed BOOLEAN;
        v_audit_id NUMBER;
    BEGIN
        -- Check restriction
        IF INSERTING THEN
            v_access_allowed := check_access_restriction('INSERT');
        ELSIF UPDATING THEN
            v_access_allowed := check_access_restriction('UPDATE');
        ELSIF DELETING THEN
            v_access_allowed := check_access_restriction('DELETE');
        END IF;
        
        IF NOT v_access_allowed THEN
            RAISE_APPLICATION_ERROR(-20002, 
                'Purchase Order operations not allowed on weekdays or holidays. ' ||
                'Allowed only on weekends (Saturday/Sunday).');
        END IF;
        
        -- Store changes for auditing
        g_po_changes.EXTEND;
        IF INSERTING THEN
            g_po_changes(g_po_changes.LAST) := po_rec(:NEW.po_id, :NEW.vendor_id, 'INSERT');
        ELSIF UPDATING THEN
            g_po_changes(g_po_changes.LAST) := po_rec(:NEW.po_id, :NEW.vendor_id, 'UPDATE');
        ELSIF DELETING THEN
            g_po_changes(g_po_changes.LAST) := po_rec(:OLD.po_id, :OLD.vendor_id, 'DELETE');
        END IF;
    END BEFORE EACH ROW;
    
    -- After statement
    AFTER STATEMENT IS
        v_audit_id NUMBER;
    BEGIN
        -- Log all changes
        FOR i IN 1..g_po_changes.COUNT LOOP
            v_audit_id := log_audit_trail(
                p_table_name => 'PURCHASE_ORDER',
                p_operation => g_po_changes(i).operation,
                p_vendor_id => g_po_changes(i).vendor_id,
                p_status => 'SUCCESS'
            );
        END LOOP;
    END AFTER STATEMENT;
    
END trg_po_compound;
/