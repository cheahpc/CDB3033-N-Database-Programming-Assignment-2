CREATE OR REPLACE PROCEDURE print_publication(
    p_author_name IN VARCHAR2
) AS
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
BEGIN
 --First, understand the what type of publication the author has written
 -- Step 1: Get Author's Publication Count
    FOR v_c_author IN c_author LOOP
        FOR v_c_wrote IN c_wrote(v_c_author.aid) LOOP
 --Step 2: For each publication, loop each type of cursor {book|journal|proceedings|article}
            FOR v_c_publications IN c_publications(v_c_wrote.pubid) LOOP
                v_total_count := v_total_count + 1;
                DBMS_OUTPUT.PUT_LINE('==================== Publication No: '|| v_total_count || ' ====================');
                DBMS_OUTPUT.PUT_LINE('Pubid: ' || v_c_wrote.pubid);
                FOR v_c_book IN c_book(v_c_publications.pubid) LOOP
                    DBMS_OUTPUT.PUT_LINE('Type: ' || 'Book');
                    DBMS_OUTPUT.PUT_LINE('Title: ' || v_c_publications.title);
                    DBMS_OUTPUT.PUT_LINE(' ');
                    DBMS_OUTPUT.PUT_LINE('==================== Details');
                    DBMS_OUTPUT.PUT_LINE('Publisher: ' || v_c_book.publisher);
                    DBMS_OUTPUT.PUT_LINE('Year: ' || v_c_book.YEAR);
                    v_book_count := v_book_count + 1;
                END LOOP;

                FOR v_c_journal IN c_journal(v_c_publications.pubid) LOOP
                    DBMS_OUTPUT.PUT_LINE('Type: ' || 'Journal');
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
                    DBMS_OUTPUT.PUT_LINE('Title: ' || v_c_publications.title);
                    DBMS_OUTPUT.PUT_LINE(' ');
                    DBMS_OUTPUT.PUT_LINE('==================== Details');
                    DBMS_OUTPUT.PUT_LINE('Year: ' || v_c_proceedings.YEAR);
                    v_proceedings_count := v_proceedings_count + 1;
                END LOOP;

                FOR v_c_article IN c_article(v_c_publications.pubid) LOOP
                    DBMS_OUTPUT.PUT_LINE('Type: ' || 'Article');
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