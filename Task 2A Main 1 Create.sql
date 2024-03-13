-- create the publication_master table
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

-- drop the table
DROP TABLE publication_master;