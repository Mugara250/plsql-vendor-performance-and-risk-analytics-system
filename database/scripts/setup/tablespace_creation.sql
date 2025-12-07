-- Switch to your PDB first
ALTER SESSION SET CONTAINER = mon_12345_john_VendorScoring_DB;

-- 1. DATA tablespace for user tables
CREATE TABLESPACE vendor_data 
DATAFILE 'C:\ORACLE\ORADATA\ORCL\mon_12345_john_VendorScoring_DB\vendor_data01.dbf'
SIZE 200M AUTOEXTEND ON NEXT 100M MAXSIZE 2G
EXTENT MANAGEMENT LOCAL 
SEGMENT SPACE MANAGEMENT AUTO;

-- 2. INDEX tablespace for indexes
CREATE TABLESPACE vendor_idx 
DATAFILE 'C:\ORACLE\ORADATA\ORCL\mon_12345_john_VendorScoring_DB\vendor_idx01.dbf'
SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE 1G
EXTENT MANAGEMENT LOCAL;

-- 3. TEMPORARY tablespace for sorting operations
CREATE TEMPORARY TABLESPACE vendor_temp
TEMPFILE 'C:\ORACLE\ORADATA\ORCL\mon_12345_john_VendorScoring_DB\vendor_temp01.dbf'
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