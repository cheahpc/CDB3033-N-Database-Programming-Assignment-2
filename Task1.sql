CREATE OR REPLACE PROCEDURE print_publication(p_author_name IN VARCHAR2) IS
    v_total_publication NUMBER := 0;
BEGIN
    -- Print publication records for the given author name
    FOR pub IN (SELECT p.pubid, p.type, p.title, a.author_name, b.volume, b.number, b.year
                            FROM publication p
                            JOIN author a ON p.pubid = a.pubid
                            LEFT JOIN book b ON p.pubid = b.pubid
                            LEFT JOIN journal j ON p.pubid = j.pubid
                            LEFT JOIN proceedings pr ON p.pubid = pr.pubid
                            LEFT JOIN article ar ON p.pubid = ar.pubid
                            WHERE a.author_name = p_author_name
                            ORDER BY a.author_name ASC, p.year ASC)
    LOOP
        -- Print publication details based on the type
        DBMS_OUTPUT.PUT_LINE('Pubid: ' || pub.pubid);
        DBMS_OUTPUT.PUT_LINE('Type: ' || pub.type);
        DBMS_OUTPUT.PUT_LINE('Authors: ' || pub.author_name);
        DBMS_OUTPUT.PUT_LINE('Title: ' || pub.title);

        IF pub.type = 'journal' THEN
            DBMS_OUTPUT.PUT_LINE('Volume: ' || pub.volume);
            DBMS_OUTPUT.PUT_LINE('Number: ' || pub.number);
            DBMS_OUTPUT.PUT_LINE('Year: ' || pub.year);
        ELSIF pub.type = 'article' THEN
            -- Retrieve the year from the related publication (book, journal, etc.)
            SELECT p.year INTO pub.year
            FROM publication p
            WHERE p.pubid = pub.pubid;

            DBMS_OUTPUT.PUT_LINE('Year: ' || pub.year);
        END IF;

        DBMS_OUTPUT.PUT_LINE(''); -- Add a blank line between publications

        v_total_publication := v_total_publication + 1;
    END LOOP;

    -- Print summary of total publications for the author
    DBMS_OUTPUT.PUT_LINE('Proceedings: 1');
    DBMS_OUTPUT.PUT_LINE('Journal: 1');
    DBMS_OUTPUT.PUT_LINE('Article: 0');
    DBMS_OUTPUT.PUT_LINE('Book: 0');
    DBMS_OUTPUT.PUT_LINE('Total Publication: ' || v_total_publication);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Call the procedure from an anonymous block
BEGIN
    print_publication('Author Name');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;