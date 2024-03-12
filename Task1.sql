CREATE OR REPLACE PROCEDURE print_publication(
    p_author_name IN VARCHAR2
) AS
 -- additional cursor for wrote using aorder
    CURSOR c_wrote_aoder(
        p_pubid CHAR,
        p_aoder NUMBER
    ) IS
    SELECT
        aid,
        pubid,
        aorder
    FROM
        wrote
    WHERE
        pubid = p_pubid AND
        aorder = p_aoder;
 -- additional cursor for wrote using pubid
    CURSOR c_wrote_pubid(
        p_pubid CHAR
    ) IS
    SELECT
        aid,
        pubid,
        aorder
    FROM
        wrote
    WHERE
        pubid = p_pubid;
 -- additional cursor for author using aid
    CURSOR c_author_aid(
        p_aid NUMBER
    ) IS
    SELECT
        aid,
        name
    FROM
        author
    WHERE
        aid = p_aid;
 -- 1st cursor - to retrieve author details
    CURSOR c_author IS
    SELECT
        aid,
        name
    FROM
        author
    WHERE
        name = p_author_name;
 -- 2nd cursor - to retrieve what author has wrote
    CURSOR c_wrote(
        p_aid NUMBER
    ) IS
    SELECT
        aid,
        pubid,
        aorder
    FROM
        wrote
    WHERE
        aid = p_aid;
 --  3rd cursor - to retrieve publication details
    CURSOR c_publications(
        p_pubid CHAR
    ) IS
    SELECT
        pubid,
        title
    FROM
        publication
    WHERE
        pubid = p_pubid;
 -- 4th cursor - book
    CURSOR c_book(
        p_pubid CHAR
    ) IS
    SELECT
        pubid,
        publisher,
        year
    FROM
        book
    WHERE
        pubid = p_pubid;
 -- 5th cursor - journal
    CURSOR c_journal(
        p_pubid CHAR
    ) IS
    SELECT
        pubid,
        volume,
        num,
        year
    FROM
        journal
    WHERE
        pubid = p_pubid;
 -- 6th cursor - proceedings
    CURSOR c_proceedings(
        p_pubid CHAR
    ) IS
    SELECT
        pubid,
        year
    FROM
        proceedings
    WHERE
        pubid = p_pubid;
 -- 7th cursor - article
    CURSOR c_article(
        p_pubid CHAR
    ) IS
    SELECT
        pubid,
        appearsin,
        startpage,
        endpage
    FROM
        article
    WHERE
        pubid = p_pubid;
 -- define a table type
    TYPE item_type IS RECORD(
        pub_year INTEGER,
        pub_id VARCHAR2(50)
    );
 -- declare a 2d array of table type
    TYPE pub_array_type IS
        TABLE OF item_type;
 -- initialize the array
    v_pub_array         pub_array_type:=pub_array_type();
 -- pub_array_type      item_type;
    v_proceedings_count INTEGER := 0;
    v_journal_count     INTEGER := 0;
    v_article_count     INTEGER := 0;
    v_book_count        INTEGER := 0;
    v_total_count       INTEGER := 0;
    v_author_count      INTEGER := 0;
    v_temp_year         INTEGER;
    v_temp_id           VARCHAR2(50);
    v_author_name       VARCHAR2(500); -- Assume 50 char for 1 author, accomodate up to 10 authors
BEGIN
 -- step 1: get author's id given author name
    FOR v_c_author IN c_author LOOP
 -- step 2: using author id, get pubid, from wrote (aid,pubid,aorder)
        FOR v_c_wrote IN c_wrote(v_c_author.aid) LOOP
            v_total_count := v_total_count + 1;
 -- step 2.1: using pubid, get publication year from {book, journal, proceedings}
            FOR v_book IN c_book(v_c_wrote.pubid) LOOP
                v_pub_array.extend(1);
                v_pub_array(v_pub_array.last).pub_year := v_book.year;
                v_pub_array(v_pub_array.last).pub_id := v_c_wrote.pubid;
                v_book_count := v_book_count + 1;
            END LOOP;

            FOR v_journal IN c_journal(v_c_wrote.pubid) LOOP
                v_pub_array.extend(1);
                v_pub_array(v_pub_array.last).pub_year := v_journal.year;
                v_pub_array(v_pub_array.last).pub_id := v_c_wrote.pubid;
                v_journal_count := v_journal_count + 1;
            END LOOP;

            FOR v_proceedings IN c_proceedings(v_c_wrote.pubid) LOOP
                v_pub_array.extend(1);
                v_pub_array(v_pub_array.last).pub_year := v_proceedings.year;
                v_pub_array(v_pub_array.last).pub_id := v_c_wrote.pubid;
                v_proceedings_count := v_proceedings_count + 1;
            END LOOP;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('                     Before');
 -- print all array content
        FOR I IN 1..V_PUB_ARRAY.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('pub_year: ' || V_PUB_ARRAY(I).PUB_YEAR || ' pub_id: ' || V_PUB_ARRAY(I).PUB_ID);
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('                     After');
 -- step 2.2: sort the array base on year
 -- BEGIN: Sort array by year using bubble sort
        FOR i IN 1..v_pub_array.COUNT-1 LOOP
            FOR j IN 1..v_pub_array.COUNT-i LOOP
                IF v_pub_array(j).pub_year > v_pub_array(j+1).pub_year THEN
 -- Swap the elements
                    v_temp_year := v_pub_array(j).pub_year;
                    v_temp_id := v_pub_array(j).pub_id;
                    v_pub_array(j).pub_year := v_pub_array(j+1).pub_year;
                    v_pub_array(j).pub_id := v_pub_array(j+1).pub_id;
                    v_pub_array(j+1).pub_year := v_temp_year;
                    v_pub_array(j+1).pub_id := v_temp_id;
                END IF;
            END LOOP;
        END LOOP;
 -- END: Sort array by year
 -- print all array content
        FOR I IN 1..V_PUB_ARRAY.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('pub_year: ' || V_PUB_ARRAY(I).PUB_YEAR || ' pub_id: ' || V_PUB_ARRAY(I).PUB_ID);
        END LOOP;

        dbms_output.put_line(' ');
        dbms_output.put_line(' ');
 -- reset the author count and author name variable after each publication
        v_author_count := 0;
        v_author_name := NULL;
    END LOOP;
 -- print the summary page
    dbms_output.put_line('-------------------- summary --------------------');
    dbms_output.put_line('proceedings: ' || v_proceedings_count);
    dbms_output.put_line('journal: ' || v_journal_count);
    dbms_output.put_line('article: ' || v_article_count);
    dbms_output.put_line('book: ' || v_book_count);
    dbms_output.put_line('total publication: ' || v_total_count);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('error: ' || sqlerrm);
END;
/