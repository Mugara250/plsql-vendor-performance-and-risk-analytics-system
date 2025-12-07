CREATE TABLE vendor (
    vendor_id      NUMBER(10)      NOT NULL,
    vendor_name    VARCHAR2(100)   NOT NULL,
    status         VARCHAR2(20)    DEFAULT 'ACTIVE',
    category       VARCHAR2(30)    DEFAULT 'STANDARD',
    created_date   DATE            DEFAULT SYSDATE NOT NULL
) TABLESPACE vendor_data;

CREATE TABLE purchase_order (
    po_id          NUMBER(12)      NOT NULL,
    vendor_id      NUMBER(10)      NOT NULL,
    po_number      VARCHAR2(30)    NOT NULL,
    order_date     DATE            DEFAULT SYSDATE NOT NULL,
    order_amount   NUMBER(12,2)    NOT NULL,
    promised_date  DATE,
    status         VARCHAR2(20)    DEFAULT 'PENDING'
) TABLESPACE vendor_data;

CREATE TABLE delivery_performance (
    delivery_id    NUMBER(10)      NOT NULL,
    po_id          NUMBER(12)      NOT NULL,
    delivery_date  DATE            DEFAULT SYSDATE NOT NULL,
    received_qty   NUMBER(8)       NOT NULL,
    defective_qty  NUMBER(8)       DEFAULT 0,
    days_late      NUMBER(5),
    defect_rate    NUMBER(5,2)
) TABLESPACE vendor_data;

CREATE TABLE vendor_score (
    score_id          NUMBER(12)   NOT NULL,
    vendor_id         NUMBER(10)   NOT NULL,
    score_date        DATE         DEFAULT SYSDATE NOT NULL,
    performance_score NUMBER(5,2),
    risk_score        NUMBER(5,2),
    overall_score     NUMBER(5,2),
    score_rank        VARCHAR2(1)
) TABLESPACE vendor_data;

CREATE TABLE vendor_alert (
    alert_id      NUMBER(12)       NOT NULL,
    vendor_id     NUMBER(10)       NOT NULL,
    alert_type    VARCHAR2(30)     NOT NULL,
    alert_date    DATE             DEFAULT SYSDATE NOT NULL,
    severity      VARCHAR2(10)     DEFAULT 'MEDIUM',
    is_resolved   CHAR(1)          DEFAULT 'N'
) TABLESPACE vendor_data;

CREATE TABLE scoring_config (
    config_id     NUMBER(5)        NOT NULL,
    config_key    VARCHAR2(50)     NOT NULL,
    config_value  VARCHAR2(100)    NOT NULL,
    description   VARCHAR2(200)    NOT NULL,
    last_updated  DATE             DEFAULT SYSDATE NOT NULL
) TABLESPACE vendor_data;