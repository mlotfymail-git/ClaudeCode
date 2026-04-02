-- ============================================================
-- Car Rental System (CRS) - Master Installation Script
-- Run this script as the schema owner to install all objects.
-- ============================================================

WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;
SET ECHO ON
SET FEEDBACK ON

PROMPT ============================================================
PROMPT  Car Rental System (CRS) - Installing Database Objects
PROMPT ============================================================

PROMPT --- Step 1: Creating Sequences ---
@@../db/01_sequences.sql

PROMPT --- Step 2: Creating Tables ---
@@../db/02_tables.sql

PROMPT --- Step 3: Creating Indexes ---
@@../db/03_indexes.sql

PROMPT --- Step 4: Loading Sample Data ---
@@../db/04_sample_data.sql

PROMPT --- Step 5: Compiling PL/SQL Packages ---
@@../plsql/pkg_rental.sql
@@../plsql/pkg_vehicle.sql
@@../plsql/pkg_reports.sql

PROMPT --- Verifying compilation ---
SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_name IN ('PKG_RENTAL', 'PKG_VEHICLE', 'PKG_REPORTS')
 ORDER BY object_name;

PROMPT ============================================================
PROMPT  Installation Complete
PROMPT ============================================================
