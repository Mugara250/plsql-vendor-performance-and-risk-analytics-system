# **Vendor Performance & Risk Analytics System**

## **Purpose**
Automated system to track vendor performance, enforce security rules, and maintain audit trails for compliance.

## **What It Does**
1. **Scores Vendors** - Rates vendors automatically based on delivery time, quality, and compliance
2. **Controls Access** - Only allows data changes on weekends; blocks weekdays/holidays
3. **Logs Everything** - Keeps detailed records of who tried to do what and when
4. **Flags Risks** - Identifies problematic vendors automatically

## **Main Parts**

### **Database Tables:**
- `vendor` - Information about all vendors tracked in the system
- `purchase_order` - Tracks all purchase transactions with vendors
- `delivery_performance` - Records delivery outcomes and quality inspection results
- `vendor_score` -  Stores calculated vendor performance and risk scores
- `vendor_alert` -  Tracks system-generated alerts for vendor issues
- `scoring_config` - Stores adjustable business rules for the scoring system
- `vendor_audit_log` - Security audit trail
- `system_holidays` - Blocked dates for operations

### **Key Features:**
- **Automatic Scoring** - Vendors get A-F grades based on performance
- **Time Lock** - Can only edit data Saturday/Sunday
- **Violation Audit** - Logs all access attempts that violate weekend/holiday restrictions
- **Risk Alerts** - System flags bad vendors

## **Business Rules**
- **Allowed**: Saturday & Sunday operations
- **Blocked**: Monday-Friday & holidays
- **Logged**: Only blocked attempts (when someone tries to edit data on a weekday/holiday)

## **Technical Stuff**
- **Triggers** - Enforce rules automatically
- **Functions** - Calculate scores, check access
- **Audit Trail** - Logs: User ID + IP Address + Timestamp + Operation + Status (SUCCESS/DENIED/ERROR) + Error Message

## **Why It Matters**
- **Saves Time** - No manual vendor reviews
- **Reduces Risk** - Catches problems early
- **Compliance Ready** - Audit trail built-in
- **Better Decisions** - Data-driven vendor choices

## **Bottom Line**
System that automatically manages vendors, blocks unauthorized changes, and keeps perfect records for compliance.