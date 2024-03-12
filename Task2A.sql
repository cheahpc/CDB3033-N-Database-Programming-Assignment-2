-- Create the publication_master table
CREATE TABLE publication_master (
    pubid INTEGER,
    type VARCHAR2(50),
    detail1 VARCHAR2(100),
    detail2 VARCHAR2(100),
    detail3 VARCHAR2(100),
    detail4 VARCHAR2(100)
);

-- Create the merge_publication stored procedure
CREATE OR REPLACE PROCEDURE merge_publication AS
    total_records NUMBER := 0;
BEGIN
 -- Merge data from the publication table
    INSERT INTO publication_master (
        publication_id,
        type,
        detail1,
        detail2,
        detail3,
        detail4
    )
        SELECT
            publication_id,
            'publication',
            detail1,
            detail2,
            detail3,
            detail4
        FROM
            publication;
    total_records := total_records + SQL%ROWCOUNT;
 -- Merge data from the proceedings table
    INSERT INTO publication_master (
        publication_id,
        type,
        detail1,
        detail2,
        detail3,
        detail4
    )
        SELECT
            publication_id,
            'proceedings',
            detail1,
            detail2,
            detail3,
            detail4
        FROM
            proceedings;
    total_records := total_records + SQL%ROWCOUNT;
 -- Merge data from the journal table
    INSERT INTO publication_master (
        publication_id,
        type,
        detail1,
        detail2,
        detail3,
        detail4
    )
        SELECT
            publication_id,
            'journal',
            detail1,
            detail2,
            detail3,
            detail4
        FROM
            journal;
    total_records := total_records + SQL%ROWCOUNT;
 -- Merge data from the book table
    INSERT INTO publication_master (
        publication_id,
        type,
        detail1,
        detail2,
        detail3,
        detail4
    )
        SELECT
            publication_id,
            'book',
            detail1,
            detail2,
            detail3,
            detail4
        FROM
            book;
    total_records := total_records + SQL%ROWCOUNT;
 -- Merge data from the article table
    INSERT INTO publication_master (
        publication_id,
        type,
        detail1,
        detail2,
        detail3,
        detail4
    )
        SELECT
            publication_id,
            'article',
            detail1,
            detail2,
            detail3,
            detail4
        FROM
            article;
    total_records := total_records + SQL%ROWCOUNT;
 -- Display the number of records successfully posted
    DBMS_OUTPUT.PUT_LINE('Total records successfully posted: ' || total_records);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No publication details found in proceedings, journal, article, and book tables.');
END;
/