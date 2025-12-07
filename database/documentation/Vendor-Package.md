# **vendor_pkg - Quick Reference**

**Purpose:** Manage vendors, calculate scores, assess risks

## **Main Functions**

### **Add & Update**
```sql
vendor_pkg.add_vendor('Company', 'Category', 'ACTIVE');
vendor_pkg.update_vendor_score(101);
```

### **Scoring & Risk**
```sql
-- Get grade (A-F)
grade := vendor_pkg.calculate_performance_score(101);

-- Check risk level
risk := vendor_pkg.assess_vendor_risk(101); -- Returns LOW/MEDIUM/HIGH
```

### **Reports**
```sql
-- Single vendor
SELECT vendor_pkg.get_vendor_report(101) FROM dual;

-- All vendors
SELECT vendor_pkg.get_vendor_statistics() FROM dual;
```

## **Quick Examples**
```sql
-- 1. Add vendor
vendor_pkg.add_vendor('ABC Supplies', 'OFFICE', 'ACTIVE');

-- 2. Check risk
IF vendor_pkg.assess_vendor_risk(101) = 'HIGH' THEN
    DBMS_OUTPUT.PUT_LINE('High risk - review needed');
END IF;

-- 3. Get report
SELECT vendor_pkg.get_vendor_report(101) FROM dual;
```
