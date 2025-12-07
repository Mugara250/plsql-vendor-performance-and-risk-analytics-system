-- Primary Keys
ALTER TABLE vendor ADD CONSTRAINT pk_vendor PRIMARY KEY (vendor_id);
ALTER TABLE purchase_order ADD CONSTRAINT pk_purchase_order PRIMARY KEY (po_id);
ALTER TABLE delivery_performance ADD CONSTRAINT pk_delivery PRIMARY KEY (delivery_id);
ALTER TABLE vendor_score ADD CONSTRAINT pk_vendor_score PRIMARY KEY (score_id);
ALTER TABLE vendor_alert ADD CONSTRAINT pk_vendor_alert PRIMARY KEY (alert_id);
ALTER TABLE scoring_config ADD CONSTRAINT pk_scoring_config PRIMARY KEY (config_id);

-- Foreign Keys
ALTER TABLE purchase_order ADD CONSTRAINT fk_po_vendor FOREIGN KEY (vendor_id) REFERENCES vendor(vendor_id);
ALTER TABLE delivery_performance ADD CONSTRAINT fk_delivery_po FOREIGN KEY (po_id) REFERENCES purchase_order(po_id);
ALTER TABLE vendor_score ADD CONSTRAINT fk_score_vendor FOREIGN KEY (vendor_id) REFERENCES vendor(vendor_id);
ALTER TABLE vendor_alert ADD CONSTRAINT fk_alert_vendor FOREIGN KEY (vendor_id) REFERENCES vendor(vendor_id);

-- Unique Constraints
ALTER TABLE purchase_order ADD CONSTRAINT uk_po_number UNIQUE (po_number);
ALTER TABLE delivery_performance ADD CONSTRAINT uk_delivery_po UNIQUE (po_id);
ALTER TABLE vendor_score ADD CONSTRAINT uk_vendor_score_date UNIQUE (vendor_id, score_date);
ALTER TABLE scoring_config ADD CONSTRAINT uk_config_key UNIQUE (config_key);

-- Check Constraints
ALTER TABLE vendor ADD CONSTRAINT ck_vendor_status CHECK (status IN ('ACTIVE', 'INACTIVE'));
ALTER TABLE purchase_order ADD CONSTRAINT ck_order_amount CHECK (order_amount > 0);
ALTER TABLE purchase_order ADD CONSTRAINT ck_po_status CHECK (status IN ('PENDING', 'DELIVERED', 'CANCELLED'));
ALTER TABLE delivery_performance ADD CONSTRAINT ck_received_qty CHECK (received_qty > 0);
ALTER TABLE delivery_performance ADD CONSTRAINT ck_defective_qty CHECK (defective_qty <= received_qty);
ALTER TABLE vendor_score ADD CONSTRAINT ck_performance_score CHECK (performance_score BETWEEN 0 AND 100);
ALTER TABLE vendor_score ADD CONSTRAINT ck_risk_score CHECK (risk_score BETWEEN 0 AND 100);
ALTER TABLE vendor_score ADD CONSTRAINT ck_overall_score CHECK (overall_score BETWEEN 0 AND 100);
ALTER TABLE vendor_score ADD CONSTRAINT ck_score_rank CHECK (score_rank IN ('A', 'B', 'C', 'D'));
ALTER TABLE vendor_alert ADD CONSTRAINT ck_alert_type CHECK (alert_type IN ('LOW_SCORE', 'LATE_DELIVERY', 'HIGH_DEFECTS'));
ALTER TABLE vendor_alert ADD CONSTRAINT ck_severity CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH'));
ALTER TABLE vendor_alert ADD CONSTRAINT ck_is_resolved CHECK (is_resolved IN ('Y', 'N'));