# **Data Dictionary: Vendor Performance & Risk Analytics System**

| Table | Column | Type | Constraints | Purpose |
|-------|--------|------|-------------|---------|
| **VENDOR** | vendor_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique vendor identifier |
| | vendor_name | VARCHAR2(100) | NOT NULL | Official business name |
| | status | VARCHAR2(20) | CHECK: 'ACTIVE','INACTIVE' | Current vendor status |
| | category | VARCHAR2(30) | | Strategic classification tier |
| | created_date | DATE | NOT NULL | Record creation timestamp |
| **PURCHASE_ORDER** | po_id | NUMBER(12) | PRIMARY KEY, NOT NULL | Unique purchase order ID |
| | vendor_id | NUMBER(10) | FOREIGN KEY (VENDOR), NOT NULL | References the supplying vendor |
| | po_number | VARCHAR2(30) | UNIQUE, NOT NULL | Business PO number |
| | order_date | DATE | NOT NULL | Date when order was placed |
| | order_amount | NUMBER(12,2) | NOT NULL, CHECK>0 | Total monetary value |
| | promised_date | DATE | | Originally agreed delivery date |
| | status | VARCHAR2(20) | CHECK: 'PENDING','DELIVERED','CANCELLED' | Current order status |
| **DELIVERY_PERFORMANCE** | delivery_id | NUMBER(10) | PRIMARY KEY, NOT NULL | Unique delivery record ID |
| | po_id | NUMBER(12) | FOREIGN KEY (PURCHASE_ORDER), UNIQUE, NOT NULL | References purchase order |
| | delivery_date | DATE | NOT NULL | Actual date goods received |
| | received_qty | NUMBER(8) | NOT NULL, CHECK>0 | Quantity delivered |
| | defective_qty | NUMBER(8) | CHECK≤received_qty | Quantity defective |
| | days_late | NUMBER(5) | | Calculated: delivery_date - promised_date |
| | defect_rate | NUMBER(5,2) | | Calculated: (defective_qty/received_qty)×100 |
| **VENDOR_SCORE** | score_id | NUMBER(12) | PRIMARY KEY, NOT NULL | Unique score record ID |
| | vendor_id | NUMBER(10) | FOREIGN KEY (VENDOR), NOT NULL | Vendor being evaluated |
| | score_date | DATE | NOT NULL | Date score calculated |
| | performance_score | NUMBER(5,2) | CHECK: 0-100 | Based on timeliness & quality |
| | risk_score | NUMBER(5,2) | CHECK: 0-100 | Based on volatility & consistency |
| | overall_score | NUMBER(5,2) | CHECK: 0-100 | Combined weighted score |
| | score_rank | VARCHAR2(1) | CHECK: 'A','B','C','D' | Letter grade (A=85-100, B=70-84, etc) |
| **VENDOR_ALERT** | alert_id | NUMBER(12) | PRIMARY KEY, NOT NULL | Unique alert record ID |
| | vendor_id | NUMBER(10) | FOREIGN KEY (VENDOR), NOT NULL | Vendor triggering alert |
| | alert_type | VARCHAR2(30) | CHECK: 'LOW_SCORE','LATE_DELIVERY','HIGH_DEFECTS' | Category of issue |
| | alert_date | DATE | NOT NULL | Date alert generated |
| | severity | VARCHAR2(10) | CHECK: 'LOW','MEDIUM','HIGH' | Importance level |
| | is_resolved | CHAR(1) | CHECK: 'Y','N' | Whether addressed |
| **SCORING_CONFIG** | config_id | NUMBER(5) | PRIMARY KEY, NOT NULL | Unique config ID |
| | config_key | VARCHAR2(50) | UNIQUE, NOT NULL | Parameter name |
| | config_value | VARCHAR2(100) | NOT NULL | Parameter value |
| | description | VARCHAR2(200) | NOT NULL | Business purpose |
| | last_updated | DATE | NOT NULL | Last modification timestamp |

## **Table Relationships**

| Relationship | Type | Foreign Key |
|--------------|------|-------------|
| VENDOR → PURCHASE_ORDER | One-to-Many | PURCHASE_ORDER.vendor_id |
| PURCHASE_ORDER → DELIVERY_PERFORMANCE | One-to-One | DELIVERY_PERFORMANCE.po_id |
| VENDOR → VENDOR_SCORE | One-to-Many | VENDOR_SCORE.vendor_id |
| VENDOR → VENDOR_ALERT | One-to-Many | VENDOR_ALERT.vendor_id |

## **Key Business Rules**
- **VENDOR_SCORE**: One score per vendor per day (UNIQUE constraint)
- **DELIVERY_PERFORMANCE**: One delivery per purchase order (UNIQUE constraint)
- **PURCHASE_ORDER**: Order amount must be positive (CHECK>0)
- **VENDOR**: Status limited to ACTIVE/INACTIVE (CHECK constraint)