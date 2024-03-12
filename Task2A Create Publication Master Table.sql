-- create the publication_master table
CREATE TABLE publication_master (
    pubid CHAR(10) PRIMARY KEY,
    type VARCHAR2(50),
    detail1 VARCHAR2(100),
    detail2 VARCHAR2(100),
    detail3 VARCHAR2(100),
    detail4 VARCHAR2(100)
);

-- drop the table
DROP TABLE publication_master;