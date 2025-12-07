-- Foreign Key indexes
CREATE INDEX idx_po_vendor_id ON purchase_order(vendor_id) TABLESPACE vendor_idx;
CREATE INDEX idx_delivery_po_id ON delivery_performance(po_id) TABLESPACE vendor_idx;
CREATE INDEX idx_score_vendor_id ON vendor_score(vendor_id) TABLESPACE vendor_idx;
CREATE INDEX idx_alert_vendor_id ON vendor_alert(vendor_id) TABLESPACE vendor_idx;

-- Query performance indexes
CREATE INDEX idx_vendor_status ON vendor(status) TABLESPACE vendor_idx;
CREATE INDEX idx_po_status ON purchase_order(status) TABLESPACE vendor_idx;
CREATE INDEX idx_po_order_date ON purchase_order(order_date DESC) TABLESPACE vendor_idx;
CREATE INDEX idx_delivery_date ON delivery_performance(delivery_date) TABLESPACE vendor_idx;
CREATE INDEX idx_score_date ON vendor_score(score_date DESC) TABLESPACE vendor_idx;
CREATE INDEX idx_alert_date ON vendor_alert(alert_date DESC) TABLESPACE vendor_idx;

-- Composite indexes for common queries
CREATE INDEX idx_vendor_score_composite ON vendor_score(vendor_id, score_date, overall_score) TABLESPACE vendor_idx;
CREATE INDEX idx_po_vendor_composite ON purchase_order(vendor_id, order_date, status) TABLESPACE vendor_idx;
CREATE INDEX idx_alert_vendor_status ON vendor_alert(vendor_id, is_resolved, alert_date) TABLESPACE vendor_idx;