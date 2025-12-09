-- ============================================
-- 01_create_pdb.sql (Alternative - No HOST command)
-- ============================================

CONNECT / AS SYSDBA

-- PROMPT Checking existing PDBs...
SELECT name, open_mode FROM v$pdbs;

-- PROMPT Creating PDB: mon_12345_john_VendorScoring_DB...
-- PROMPT NOTE: Ensure directory exists: C:\ORACLE\ORADATA\ORCL\mon_12345_john_VendorScoring_DB

CREATE PLUGGABLE DATABASE mon_12345_john_VendorScoring_DB
ADMIN USER john_vendor_admin IDENTIFIED BY john
DEFAULT TABLESPACE users
DATAFILE 'C:\ORACLE\ORADATA\ORCL\mon_27906_mushi_vendorperformanceanalytics_db\users01.dbf' 
SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE 1G
FILE_NAME_CONVERT = ('C:\ORACLE\ORADATA\ORCL\PDBSEED\', 
                     'C:\ORACLE\ORADATA\ORCL\mon_27906_vendorperformanceanalytics_db\');

-- PROMPT Opening PDB...
ALTER PLUGGABLE DATABASE mon_12345_john_VendorScoring_DB OPEN;

-- PROMPT Switching to new PDB...
ALTER SESSION SET CONTAINER = mon_12345_john_VendorScoring_DB;

-- PROMPT Verifying PDB creation...
SHOW con_name;
SELECT name, open_mode FROM v$pdbs WHERE name LIKE '%VENDORPERFORMANCE%';

-- PROMPT PDB creation completed successfully!