# PDB Setup Guide - Vendor Performance and Risk Analytics System

## Prerequisites
- Oracle Database 12c or higher with Multitenant option
- SYSDBA privileges for initial PDB creation
- Sufficient disk space (minimum 500MB recommended)

## Setup Instructions

### Step 1: Update Script Variables
Before running any scripts, replace these placeholders:
- `[StudentID]` → Your student ID number
- `[FirstName]` → Your first name (lowercase for password)
- `[Your Group]` → Your group name

### Step 2: Run Setup Scripts in Order
```bash
# Connect as SYSDBA
sqlplus / as sysdba

# Run scripts in sequence:
@01_create_pdb.sql
@02_create_tablespaces.sql
@03_create_admin_user.sql
@04_verify_setup.sql