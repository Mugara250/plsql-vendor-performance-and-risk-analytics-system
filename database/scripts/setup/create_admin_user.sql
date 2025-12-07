-- ============================================
-- 02_create_tablespaces.sql
-- Creates tablespaces for Vendor Scoring System
-- Must be run after PDB creation
-- ============================================

-- Ensure we're in the correct PDB
ALTER SESSION SET CONTAINER = mon_[StudentID]_[FirstName]_VendorScoring_DB;

PROMPT Creating project tablespaces...

-- 1. DATA tablespace for user tables
CREATE TABLESPACE vendor_data 
DATAFILE '/u01/app/oracle/oradata/CDB1/mon_[StudentID]_[FirstName]_VendorScoring_DB/vendor_data01.dbf'
SIZE 200M AUTOEXTEND ON NEXT 100M MAXSIZE 2G
EXTENT MANAGEMENT LOCAL 
SEGMENT SPACE MANAGEMENT AUTO;

-- 2. INDEX tablespace for indexes
CREATE TABLESPACE vendor_idx 
DATAFILE '/u01/app/oracle/oradata/CDB1/mon_[StudentID]_[FirstName]_VendorScoring_DB/vendor_idx01.dbf'
SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE 1G
EXTENT MANAGEMENT LOCAL;

-- 3. TEMPORARY tablespace for sorting operations
CREATE TEMPORARY TABLESPACE vendor_temp
TEMPFILE '/u01/app/oracle/oradata/CDB1/mon_[StudentID]_[FirstName]_VendorScoring_DB/vendor_temp01.dbf'
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