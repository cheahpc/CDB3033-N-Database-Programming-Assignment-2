CREATE OR REPLACE PROCEDURE print_publication(p_author_name IN VARCHAR2) IS
    CURSOR c_publications IS
        SELECT p.pubid, p.type, p.title, p.year, b.volume, b.number
        FROM publications p
        LEFT JOIN books b ON p.pubid = b.pubid
        WHERE EXISTS (
            SELECT 1
            FROM authors a
            WHERE a.pubid = p.pubid
            AND a.author_name = p_author_name
        )
        ORDER BY p_author_name ASC, p.year ASC;

    v_proceedings_count NUMBER := 0;
    v_journal_count NUMBER := 0;
    v_article_count NUMBER := 0;
    v_book_count NUMBER := 0;
    v_total_count NUMBER := 0;
BEGIN
    FOR pub_rec IN c_publications LOOP
        DBMS_OUTPUT.PUT_LINE('Pubid: ' || pub_rec.pubid);
        DBMS_OUTPUT.PUT_LINE('Type: ' || pub_rec.type);
        DBMS_OUTPUT.PUT_LINE('Authors: ' || p_author_name);
        DBMS_OUTPUT.PUT_LINE('Title: ' || pub_rec.title);

        IF pub_rec.type = 'journal' THEN
            DBMS_OUTPUT.PUT_LINE('Volume: ' || pub_rec.volume);
            DBMS_OUTPUT.PUT_LINE('Number: ' || pub_rec.number);
        ELSIF pub_rec.type = 'article' THEN
            -- Retrieve article details from other relations
            -- and print relevant publication details
        END IF;

        DBMS_OUTPUT.NEW_LINE;

        -- Increment the count for each publication type
        IF pub_rec.type = 'proceedings' THEN
            v_proceedings_count := v_proceedings_count + 1;
        ELSIF pub_rec.type = 'journal' THEN
            v_journal_count := v_journal_count + 1;
        ELSIF pub_rec.type = 'article' THEN
            v_article_count := v_article_count + 1;
        ELSIF pub_rec.type = 'book' THEN
            v_book_count := v_book_count + 1;
        END IF;

        v_total_count := v_total_count + 1;
    END LOOP;

    -- Print the summary page
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

-- Call the procedure from an anonymous block
BEGIN
    print_publication('John Doe');
END;
/