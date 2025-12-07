# **Business Rules Documentation**

## **Access Control Rules**
**Rule:** Data modifications only allowed on weekends
- **Allowed:** Saturday, Sunday
- **Blocked:** Monday-Friday
- **Blocked:** Holidays (even if on weekend)

## **Audit Logging Rules**
**Rule:** Log all security violations
- **Logged:** Blocked attempts (weekday/holiday access)
- **Logged:** System errors
- **Not logged:** Allowed weekend operations

## **Vendor Scoring Rules**
**Rule:** Automatic performance grading (A-F)
- **A:** 90-100% (Excellent)
- **B:** 80-89% (Good)
- **C:** 70-79% (Average)
- **D:** 60-69% (Poor)
- **F:** Below 60% (Unacceptable)

**Factors considered:**
1. On-time delivery percentage
2. Quality rating (1-5 scale)
3. Invoice accuracy
4. Response time

## **Risk Assessment Rules**
**Rule:** Flag vendors based on score and activity
- **HIGH RISK:** Score < 60% OR >2 late deliveries/month
- **MEDIUM RISK:** Score 60-75% OR 1-2 late deliveries
- **LOW RISK:** Score > 75% AND 0 late deliveries

## **Validation Rules**
**Rule:** Data integrity checks
- Vendor name: Required, 2-100 characters
- Status: Must be 'ACTIVE', 'INACTIVE', or 'SUSPENDED'
- Category: Must exist in predefined list
- Vendor ID: Auto-generated, unique

## **Holiday Processing Rules**
**Rule:** System-wide operation blocking
- Holidays stored in `system_holidays` table
- All operations blocked on holidays
- Holiday dates: Year-round (not just business days)

## **Compliance Rules**
**Rule:** Audit trail requirements
- Every blocked attempt must be logged
- Log includes: User, IP, timestamp, operation, error
- Logs retained for 7 years minimum
- No modifications to audit records allowed