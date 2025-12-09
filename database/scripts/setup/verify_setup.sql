-- ============================================
-- 04_verify_setup.sql
-- Verifies complete database setup
-- Run after all setup scripts
-- ============================================

-- Ensure we're in the correct PDB
ALTER SESSION SET CONTAINER = mon_27906_mushi_vendoranalyticsperformance_db;

PROMPT ========================================
PROMPT DATABASE SETUP VERIFICATION REPORT
PROMPT ========================================

-- 1. PDB Information
PROMPT 1. PDB Status:
SELECT name, open_mode, restricted, open_time 
FROM v$pdbs 
WHERE name LIKE '%VENDORPERFORMANCE%';

-- 2. Tablespace Information
PROMPT 
PROMPT 2. Tablespace Configuration:
SELECT 
    tablespace_name,
    file_name,
    ROUND(bytes/1024/1024, 2) as size_mb,
    autoextensible,
    ROUND(maxbytes/1024/1024, 2) as max_size_mb,
    increment_by
FROM dba_data_files 
WHERE tablespace_name IN ('VENDOR_DATA', 'VENDOR_IDX', 'USERS')
UNION ALL
SELECT 
    tablespace_name,
    file_name,
    ROUND(bytes/1024/1024, 2) as size_mb,
    autoextensible,
    ROUND(maxbytes/1024/1024, 2) as max_size_mb,
    increment_by
FROM dba_temp_files 
WHERE tablespace_name = 'VENDOR_TEMP'
ORDER BY tablespace_name;

-- 3. User Information
PROMPT 
PROMPT 3. User Configuration:
SELECT 
    username,
    default_tablespace,
    temporary_tablespace,
    account_status,
    created
FROM dba_users 
WHERE username IN ('VENDOR_ADMIN', UPPER('mushi_vendor_admin'))
ORDER BY username;

-- 4. Memory Parameters
PROMPT 
PROMPT 4. Memory Configuration:
SELECT 
    name,
    value/1024/1024 as value_mb,
    ispdb_modifiable
FROM v$parameter 
WHERE name IN ('sga_target', 'pga_aggregate_target', 'memory_target');

-- 5. Archive Log Status
PROMPT 
PROMPT 5. Archive Log Configuration:
SELECT 
    log_mode,
    flashback_on,
    force_logging
FROM v$database;

-- 6. System Resource Usage
PROMPT 
PROMPT 6. System Resource Summary:
SELECT 
    'Data Files Size (MB)' as metric,
    SUM(bytes)/1024/1024 as value
FROM dba_data_files
UNION ALL
SELECT 
    'Temp Files Size (MB)' as metric,
    SUM(bytes)/1024/1024 as value
FROM dba_temp_files
UNION ALL
SELECT 
    'Number of Users' as metric,
    COUNT(*) as value
FROM dba_users
WHERE username NOT IN ('SYS', 'SYSTEM');

PROMPT 
PROMPT ========================================
PROMPT SETUP VERIFICATION COMPLETE
PROMPT ========================================