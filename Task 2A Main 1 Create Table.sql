SPOOL 'Task 2A Main 1 Create Table Spool.txt'

SET ECHO ON

SET LINESIZE 1000

SET SERVEROUTPUT ON

-- drop the table if it exists
DROP TABLE publication_master;

-- create the table
CREATE TABLE publication_master (
    pubid CHAR(10) NOT NULL,
    type VARCHAR2(50) NOT NULL,
    detail1 VARCHAR2(100) NOT NULL,
    detail2 VARCHAR2(100),
    detail3 VARCHAR2(100),
    detail4 VARCHAR2(100),
    PRIMARY KEY (pubid),
    FOREIGN KEY (pubid) REFERENCES publication (pubid)
);

SPOOL OFF