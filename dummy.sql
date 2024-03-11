/as SYSDBA

ALTER SESSION SET CONTAINER = GPDB;

ALTER DATABASE OPEN;

-- conn pdb_user/user123@localhost:1521/pdb
-- conn pdb_user/user123@localhost:1521/gpdb
DESC author;

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
    author
WHERE
    AID = 16;

SELECT
    *
FROM
    author
WHERE
    name = 'Ajit_A._Diwan';

SELECT
    *
FROM
    wrote
WHERE
 -- aid = 5;-- 5 6 14 15 got 2 records
    aid = 16;

-- 16 got 5 records
-- aid = 37;

SELECT
    *
FROM
    wrote
WHERE
    pubid = 'GuravSDB12';

SELECT
    *
FROM
    -- publication
 -- book
 -- journal
 -- proceedings
 article
WHERE
 -- pubid = 'GuravSDB12'; --1
 -- pubid = '0029498'; --16
 -- pubid = 'CheVWOO11'; --16
 -- pubid = 'TaoO09a';--16
 pubid = 'ZouCOZ12';--16
    -- pubid = 'ZouMCOZ11';

--16

SELECT
    *
FROM
    journal
WHERE
    PUBID = 'GuravSDB12';