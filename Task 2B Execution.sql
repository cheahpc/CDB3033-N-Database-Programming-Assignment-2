SPOOL 'T2B TC3 Spool - Exceptions.txt'

SET ECHO ON

SET LINESIZE 1000

SET SERVEROUTPUT ON

-- Exception Null Input
EXECUTE PRINT_ARTICLE('')

-- Exception No Article Found
EXECUTE PRINT_ARTICLE('0029498')

-- Exception Not a {book, journal, proceedings} Type
EXECUTE PRINT_ARTICLE('TaoO09a')

SPOOL OFF