-- ============================================
-- 02_create_tablespaces.sql
-- Creates tablespaces for Vendor Scoring System
-- Must be run after PDB creation
-- ============================================

-- Ensure we're in the correct PDB
ALTER SESSION SET CONTAINER = mon_27906_mushi_vendorperformanceanalytics_db;

PROMPT Creating project tablespaces...

-- 1. DATA tablespace for user tables
CREATE TABLESPACE vendor_data 
DATAFILE 'C:\oracle\oradata\ORCL\mon_27906_mushi_vendorperformanceanalytics_db\VENDOR_DATA01.DBF'
SIZE 200M AUTOEXTEND ON NEXT 100M MAXSIZE 2G
EXTENT MANAGEMENT LOCAL 
SEGMENT SPACE MANAGEMENT AUTO;

-- 2. INDEX tablespace for indexes
CREATE TABLESPACE vendor_idx 
DATAFILE 'C:\oracle\oradata\ORCL\mon_27906_mushi_vendorperformanceanalytics_db\VENDOR_IDX01.DBF'
SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE 1G
EXTENT MANAGEMENT LOCAL;

-- 3. TEMPORARY tablespace for sorting operations
CREATE TEMPORARY TABLESPACE vendor_temp
TEMPFILE 'C:\oracle\oradata\ORCL\mon_27906_mushi_vendorperformanceanalytics_db\VENDOR_TEMP01.DBF'
SIZE 100M AUTOEXTEND ON NEXT 25M MAXSIZE 500M;

-- Verify tablespace creation
PROMPT Verifying tablespace creation...
SELECT tablespace_name, file_name, bytes/1024/1024 AS size_mb, autoextensible
FROM dba_data_files 
WHERE tablespace_name LIKE 'VENDOR%'
UNION ALL
SELECT tablespace_name, file_name, bytes/1024/1024 AS size_mb, autoextensible
FROM dba_temp_files 
WHERE tablespace_name LIKE 'VENDOR%';

PROMPT Tablespaces created successfully!