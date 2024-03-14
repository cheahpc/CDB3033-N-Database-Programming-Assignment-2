SPOOL 'T2A TC3 Spool - Display Merge Publication.txt'

SET ECHO ON

SET LINESIZE 1000

SET SERVEROUTPUT ON

-- Merge publications
EXECUTE merge_publication

-- Display the merged table
EXECUTE display_master_publication

SPOOL OFF