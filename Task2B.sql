CREATE OR REPLACE PROCEDURE print_article(p_pubid IN NUMBER) IS
BEGIN
    FOR rec IN (
        SELECT a.articleid, a.title, p.pubtype, p.pubtitle, p.startpage
        FROM articles a
        JOIN merge_publication mp ON a.articleid = mp.articleid
        JOIN publication p ON mp.pubid = p.pubid
        WHERE p.pubid = p_pubid
        ORDER BY p.startpage ASC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Article ID: ' || rec.articleid);
        DBMS_OUTPUT.PUT_LINE('Title: ' || rec.title);
        DBMS_OUTPUT.PUT_LINE('Publication Type: ' || rec.pubtype);
        DBMS_OUTPUT.PUT_LINE('Publication Title: ' || rec.pubtitle);
        DBMS_OUTPUT.PUT_LINE('Start Page: ' || rec.startpage);
        DBMS_OUTPUT.PUT_LINE('-------------------------');
    END LOOP;
END;
/