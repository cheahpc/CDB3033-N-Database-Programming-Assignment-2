SPOOL 'Task 1 Script B Output.txt'

SET ECHO ON

SET LINESIZE 1000

SET SERVEROUTPUT ON

execute merge_publication

EXECUTE display_master_publication
SPOOL OFF