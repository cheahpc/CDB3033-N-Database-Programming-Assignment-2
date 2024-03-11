CREATE OR REPLACE PROCEDURE print_publication(
    p_author_name IN VARCHAR2
) AS
 -- Additional Cursor for wrote using aorder
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
 -- Additional Cursor for wrote using pubid
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
 -- Additional cursor for author using aid
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
    v_proceedings_count INTEGER := 0;
    v_journal_count     INTEGER := 0;
    v_article_count     INTEGER := 0;
    v_book_count        INTEGER := 0;
    v_total_count       INTEGER := 0;
    v_author_count      INTEGER := 0;
    v_author_name       VARCHAR2(500);
BEGIN
 -- Step 1: Get Author's ID
    FOR v_c_author IN c_author LOOP
 -- Step 2: Get Author's Publication ID using author id
        FOR v_c_wrote IN c_wrote(v_c_author.aid) LOOP
 --Step 3: Get Publication Details using publication id from each {book|journal|proceedings|article}
            FOR v_c_publications IN c_publications(v_c_wrote.pubid) LOOP
 --Step 3.1: Get total author count for this publication using publicaction id
                FOR v_auth_count IN c_wrote_pubid(v_c_publications.pubid) LOOP
                    v_author_count := v_author_count + 1;
                END LOOP;
 --Step 3.2: Using sequential for-loop
                FOR v_author_no IN 1..v_author_count LOOP
 -- Step 3.3: Get Author's AID using aorder
                    FOR v_c_wrote_aoder IN c_wrote_aoder(v_c_publications.pubid, v_author_no) LOOP
 -- Step 3.4: Get Author's Name using AID
                        FOR v_c_author_aid IN c_author_aid(v_c_wrote_aoder.aid) LOOP
                            IF v_author_name IS NULL THEN
                                v_author_name := v_c_author_aid.name;
                            ELSE
                                v_author_name := v_author_name || ', ' || v_c_author_aid.name;
                            END IF;
                        END LOOP;
                    END LOOP;
                END LOOP;

                v_total_count := v_total_count + 1;
                DBMS_OUTPUT.PUT_LINE('==================== Publication No: '|| v_total_count || ' ====================');
                DBMS_OUTPUT.PUT_LINE('Pubid: ' || v_c_wrote.pubid);
                FOR v_c_book IN c_book(v_c_publications.pubid) LOOP
                    DBMS_OUTPUT.PUT_LINE('Type: ' || 'Book');
                    DBMS_OUTPUT.PUT_LINE('Author: ' || v_author_name);
                    DBMS_OUTPUT.PUT_LINE('Title: ' || v_c_publications.title);
                    DBMS_OUTPUT.PUT_LINE(' ');
                    DBMS_OUTPUT.PUT_LINE('==================== Details');
                    DBMS_OUTPUT.PUT_LINE('Publisher: ' || v_c_book.publisher);
                    DBMS_OUTPUT.PUT_LINE('Year: ' || v_c_book.YEAR);
                    v_book_count := v_book_count + 1;
                END LOOP;

                FOR v_c_journal IN c_journal(v_c_publications.pubid) LOOP
                    DBMS_OUTPUT.PUT_LINE('Type: ' || 'Journal');
                    DBMS_OUTPUT.PUT_LINE('Author: ' || v_author_name);
                    DBMS_OUTPUT.PUT_LINE('Title: ' || v_c_publications.title);
                    DBMS_OUTPUT.PUT_LINE(' ');
                    DBMS_OUTPUT.PUT_LINE('==================== Details');
                    DBMS_OUTPUT.PUT_LINE('Volume: ' || v_c_journal.volume);
                    DBMS_OUTPUT.PUT_LINE('Number: ' || v_c_journal.num);
                    DBMS_OUTPUT.PUT_LINE('Year: ' || v_c_journal.YEAR);
                    v_journal_count := v_journal_count + 1;
                END LOOP;

                FOR v_c_proceedings IN c_proceedings(v_c_publications.pubid) LOOP
                    DBMS_OUTPUT.PUT_LINE('Type: ' || 'Proceedings');
                    DBMS_OUTPUT.PUT_LINE('Author: ' || v_author_name);
                    DBMS_OUTPUT.PUT_LINE('Title: ' || v_c_publications.title);
                    DBMS_OUTPUT.PUT_LINE(' ');
                    DBMS_OUTPUT.PUT_LINE('==================== Details');
                    DBMS_OUTPUT.PUT_LINE('Year: ' || v_c_proceedings.YEAR);
                    v_proceedings_count := v_proceedings_count + 1;
                END LOOP;

                FOR v_c_article IN c_article(v_c_publications.pubid) LOOP
                    DBMS_OUTPUT.PUT_LINE('Type: ' || 'Article');
                    DBMS_OUTPUT.PUT_LINE('Author: ' || v_author_name);
                    DBMS_OUTPUT.PUT_LINE('Title: ' || v_c_publications.title);
                    DBMS_OUTPUT.PUT_LINE(' ');
                    DBMS_OUTPUT.PUT_LINE('==================== Details');
                    DBMS_OUTPUT.PUT_LINE('Appearsin: ' || v_c_article.appearsin);
                    DBMS_OUTPUT.PUT_LINE('Startpage: ' || v_c_article.startpage);
                    DBMS_OUTPUT.PUT_LINE('Endpage: ' || v_c_article.endpage);
                    v_article_count := v_article_count + 1;
                END LOOP;
            END LOOP;

            DBMS_OUTPUT.PUT_LINE(' ');
            DBMS_OUTPUT.PUT_LINE(' ');
 -- Reset the author count and author name variable after each publication
            V_AUTHOR_COUNT := 0;
            V_AUTHOR_NAME := NULL;
        END LOOP;
    END LOOP;
 -- Print the summary page
    DBMS_OUTPUT.PUT_LINE('-------------------- Summary --------------------');
    DBMS_OUTPUT.PUT_LINE('Proceedings: ' || v_proceedings_count);
    DBMS_OUTPUT.PUT_LINE('Journal: ' || v_journal_count);
    DBMS_OUTPUT.PUT_LINE('Article: ' || v_article_count);
    DBMS_OUTPUT.PUT_LINE('Book: ' || v_book_count);
    DBMS_OUTPUT.PUT_LINE('Total Publication: ' || v_total_count);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/