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
 -- journal
 -- proceedings
    -- article
WHERE
 -- appearsin = 'CIKM2009';
    pubid = '0018408';

-- pubid = '0029498';
-- pubid = 'CheVWOO11';
-- pubid = 'TaoO09a';
-- pubid = 'ZouCOZ12';
-- pubid = 'ZouMCOZ11';

--16