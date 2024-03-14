/as SYSDBA

ALTER SESSION SET CONTAINER = GPDB;

ALTER DATABASE OPEN;

-- conn pdb_user/user123@localhost:1521/pdb
-- conn pdb_user/user123@localhost:1521/gpdb
DESC author;

DESC wrote;

DESC publication;

DESC book;

DESC journal;

DESC proceedings;

DESC article;

DESC publication_master;

SELECT
    *
FROM
    publication_master;

SELECT
    *
FROM
    author;

SELECT
    *
FROM
    publication;

SELECT
    *
FROM
    wrote;

SELECT
    *
FROM
    proceedings;

SELECT
    *
FROM
    journal;

SELECT
    *
FROM
    book;

SELECT
    *
FROM
    article;

SELECT
    *
FROM
    wrote
WHERE
    aid = 1;

-- pubid = 'PVLDB4_11';

SELECT
    *
FROM
    publication
 -- wrote
 -- book
 --  journal
 -- proceedings
 -- article
WHERE
 -- appearsin = 'CIKM2009';
    pubid = 'CIKM2009';

-- Sample output
EXECUTE PRINT_ARTICLE('ICDE2011')

EXECUTE PRINT_ARTICLE('VLDBJ21_1')

-- Exception Null Input
EXECUTE PRINT_ARTICLE('')

-- Exception No Article Found
EXECUTE PRINT_ARTICLE('0029498')

-- Exception Not a {book, journal, proceedings} Type
EXECUTE PRINT_ARTICLE('TaoO09a')