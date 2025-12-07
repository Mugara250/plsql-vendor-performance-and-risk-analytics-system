CREATE OR REPLACE PACKAGE vendor_scoring_pkg AS
    -- 5 Procedures
    PROCEDURE add_new_vendor(
        p_name IN VARCHAR2,
        p_status IN VARCHAR2 DEFAULT 'ACTIVE',
        p_category IN VARCHAR2 DEFAULT 'STANDARD'
    );
    
    PROCEDURE update_vendor_score(
        p_vendor_id IN NUMBER,
        p_score_date IN DATE DEFAULT SYSDATE
    );
    
    PROCEDURE generate_alerts;
    
    PROCEDURE bulk_update_categories;
    
    PROCEDURE delete_inactive_vendors(p_days IN NUMBER DEFAULT 365);
    
    -- 3 Functions
    FUNCTION calculate_vendor_score(p_vendor_id IN NUMBER) RETURN NUMBER;
    
    FUNCTION check_vendor_status(p_vendor_id IN NUMBER) RETURN VARCHAR2;
    
    FUNCTION get_vendor_rank(p_vendor_id IN NUMBER) RETURN NUMBER;
    
END vendor_scoring_pkg;
/

CREATE OR REPLACE PACKAGE BODY vendor_scoring_pkg AS
    
    -- 1. Add new vendor
    PROCEDURE add_new_vendor(
        p_name IN VARCHAR2,
        p_status IN VARCHAR2 DEFAULT 'ACTIVE',
        p_category IN VARCHAR2 DEFAULT 'STANDARD'
    ) IS
        v_vendor_id NUMBER;
    BEGIN
        SELECT NVL(MAX(vendor_id), 0) + 1 INTO v_vendor_id FROM vendor;
        
        INSERT INTO vendor (vendor_id, vendor_name, status, category, created_date)
        VALUES (v_vendor_id, p_name, p_status, p_category, SYSDATE);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Vendor added: ID=' || v_vendor_id);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ROLLBACK;
    END add_new_vendor;
    
    -- 2. Update vendor score with cursor
    PROCEDURE update_vendor_score(
        p_vendor_id IN NUMBER,
        p_score_date IN DATE DEFAULT SYSDATE
    ) IS
        CURSOR vendor_cur IS
            SELECT vendor_id FROM vendor WHERE vendor_id = p_vendor_id;
            
        v_score NUMBER;
        v_score_id NUMBER;
    BEGIN
        OPEN vendor_cur;
        
        -- Check vendor exists
        IF vendor_cur%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Vendor not found');
            RETURN;
        END IF;
        
        CLOSE vendor_cur;
        
        -- Calculate score
        v_score := calculate_vendor_score(p_vendor_id);
        
        -- Insert score
        SELECT NVL(MAX(score_id), 0) + 1 INTO v_score_id FROM vendor_score;
        
        INSERT INTO vendor_score (score_id, vendor_id, score_date, overall_score)
        VALUES (v_score_id, p_vendor_id, p_score_date, v_score);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Score updated: ' || v_score);
        
    EXCEPTION
        WHEN OTHERS THEN
            IF vendor_cur%ISOPEN THEN CLOSE vendor_cur; END IF;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ROLLBACK;
    END update_vendor_score;
    
    -- 3. Generate alerts
    PROCEDURE generate_alerts IS
        v_alert_id NUMBER;
    BEGIN
        -- Low score alerts
        FOR score_rec IN (
            SELECT vendor_id, overall_score
            FROM vendor_score 
            WHERE overall_score < 50
            AND score_date = (SELECT MAX(score_date) 
                              FROM vendor_score vs2 
                              WHERE vs2.vendor_id = vendor_score.vendor_id)
        ) LOOP
            SELECT NVL(MAX(alert_id), 0) + 1 INTO v_alert_id FROM vendor_alert;
            
            INSERT INTO vendor_alert (alert_id, vendor_id, alert_type, alert_date, severity, is_resolved)
            VALUES (v_alert_id, score_rec.vendor_id, 'LOW_SCORE', SYSDATE, 'HIGH', 'N');
        END LOOP;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Alerts generated');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ROLLBACK;
    END generate_alerts;
    
    -- 4. Bulk update with FORALL
    PROCEDURE bulk_update_categories IS
        TYPE vendor_tab IS TABLE OF vendor.vendor_id%TYPE;
        v_vendor_ids vendor_tab;
    BEGIN
        SELECT v.vendor_id
        BULK COLLECT INTO v_vendor_ids
        FROM vendor v
        WHERE EXISTS (
            SELECT 1
            FROM purchase_order po
            JOIN delivery_performance dp ON po.po_id = dp.po_id
            WHERE po.vendor_id = v.vendor_id
            AND dp.defect_rate > 10
        );
        
        FORALL i IN 1..v_vendor_ids.COUNT
            UPDATE vendor
            SET category = 'WATCHLIST'
            WHERE vendor_id = v_vendor_ids(i);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Updated ' || SQL%ROWCOUNT || ' vendors');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ROLLBACK;
    END bulk_update_categories;
    
    -- 5. Delete inactive vendors
    PROCEDURE delete_inactive_vendors(p_days IN NUMBER DEFAULT 365) IS
        v_count NUMBER := 0;
    BEGIN
        FOR vendor_rec IN (
            SELECT vendor_id FROM vendor
            WHERE status = 'INACTIVE'
            AND created_date < SYSDATE - p_days
        ) LOOP
            DELETE FROM vendor WHERE vendor_id = vendor_rec.vendor_id;
            v_count := v_count + 1;
        END LOOP;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Deleted ' || v_count || ' vendors');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ROLLBACK;
    END delete_inactive_vendors;
    
    -- 6. Calculate vendor score
    FUNCTION calculate_vendor_score(p_vendor_id IN NUMBER) RETURN NUMBER IS
        v_score NUMBER;
    BEGIN
        SELECT 
            CASE WHEN COUNT(*) = 0 THEN 50
                 ELSE ROUND(AVG(100 - (defect_rate * 2)), 2)
            END INTO v_score
        FROM purchase_order po
        JOIN delivery_performance dp ON po.po_id = dp.po_id
        WHERE po.vendor_id = p_vendor_id
        AND po.status = 'DELIVERED';
        
        RETURN NVL(v_score, 50);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 50;
    END calculate_vendor_score;
    
    -- 7. Check vendor status
    FUNCTION check_vendor_status(p_vendor_id IN NUMBER) RETURN VARCHAR2 IS
        v_status VARCHAR2(20);
        v_alert_count NUMBER;
    BEGIN
        SELECT status INTO v_status
        FROM vendor
        WHERE vendor_id = p_vendor_id;
        
        SELECT COUNT(*) INTO v_alert_count
        FROM vendor_alert
        WHERE vendor_id = p_vendor_id
        AND is_resolved = 'N';
        
        IF v_alert_count > 0 THEN
            RETURN 'NEEDS_ATTENTION';
        ELSIF v_status = 'ACTIVE' THEN
            RETURN 'OK';
        ELSE
            RETURN 'INACTIVE';
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'NOT_FOUND';
        WHEN OTHERS THEN
            RETURN 'ERROR';
    END check_vendor_status;
    
    -- 8. Get vendor rank with window functions
    FUNCTION get_vendor_rank(p_vendor_id IN NUMBER) RETURN NUMBER IS
        v_rank NUMBER;
    BEGIN
        SELECT rank_position INTO v_rank
        FROM (
            SELECT 
                vendor_id,
                RANK() OVER (ORDER BY avg_score DESC) as rank_position
            FROM (
                SELECT 
                    v.vendor_id,
                    ROUND(AVG(vs.overall_score), 2) as avg_score
                FROM vendor v
                LEFT JOIN vendor_score vs ON v.vendor_id = vs.vendor_id
                WHERE v.status = 'ACTIVE'
                GROUP BY v.vendor_id
            )
        ) WHERE vendor_id = p_vendor_id;
        
        RETURN NVL(v_rank, 999);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 999;
    END get_vendor_rank;
    
END vendor_scoring_pkg;
/