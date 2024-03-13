CREATE OR REPLACE PROCEDURE merge_publication AS
 -- cursor 1 publication
    CURSOR c_publications IS
    SELECT
        pubid,
        title
    FROM
        publication;
 -- cursor 2 book
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
 -- cursor 3 journal
    CURSOR journal(
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
 -- cursor 4 proceedings
    CURSOR proceedings(
        p_pubid CHAR
    ) IS
    SELECT
        pubid,
        year
    FROM
        proceedings
    WHERE
        pubid = p_pubid;
 -- cursor 5 article
    CURSOR article(
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
 -- cursor 6 publication master
    CURSOR c_publication_master(
        p_pubid CHAR
    ) IS
    SELECT
        pubid
    FROM
        publication_master
    WHERE
        pubid = p_pubid;
 -- varialbe
    total_book                NUMBER:=0;
    total_book_success        NUMBER := 0;
    total_book_failed         NUMBER := 0;
    total_journal             NUMBER:=0;
    total_journal_success     NUMBER:=0;
    total_journal_failed      NUMBER:=0;
    total_proceedings         NUMBER:=0;
    total_proceedings_success NUMBER:=0;
    total_proceedings_failed  NUMBER:=0;
    total_article             NUMBER:=0;
    total_article_success     NUMBER:=0;
    total_article_failed      NUMBER:=0;
    total_succssful_operation NUMBER := 0;
    total_failed_operation    NUMBER := 0;
    total_detail_not_found    NUMBER :=0;
    total_operation           NUMBER :=0;
    record_existed            BOOLEAN := false;
    detail_found              BOOLEAN:=false;
BEGIN
    FOR v_publications IN c_publications LOOP
        detail_found := false;
 -- loop 1: book
        FOR v_book IN c_book(v_publications.pubid) LOOP
            detail_found:= true;
            record_existed := false;
            FOR v_publication_master IN c_publication_master(v_publications.pubid) LOOP
                record_existed := true; -- check if record exis.
            END LOOP;

            IF record_existed THEN
 -- loop 1.1 update, if record existed
                BEGIN
                    UPDATE publication_master
                    SET
                        type = 'book',
                        detail1 = v_publications.title,
                        detail2 = v_book.publisher,
                        detail3 = v_book.year,
                        detail4 = NULL
                    WHERE
                        pubid = v_publications.pubid;
                    dbms_output.put_line('operation "update" successful. pubid: ' || v_publications.pubid || ' type: book' || ' title: ' || v_publications.title );
                    total_book_success := total_book_success + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        dbms_output.put_line('operation "update" failed. pubid: ' || v_publications.pubid || ' type: book' || ' title: ' || v_publications.title);
                        dbms_output.put_line('error code: ' || sqlcode);
                        dbms_output.put_line('error message: ' || sqlerrm);
                        dbms_output.put_line('');
                        total_book_failed := total_book_failed + 1;
                        ROLLBACK;
                END;
            ELSE
 -- loop 1.2 insert, if record is new
                BEGIN
                    INSERT INTO publication_master(
                        pubid,
                        type,
                        detail1,
                        detail2,
                        detail3,
                        detail4
                    ) VALUES (
                        v_publications.pubid,
                        'book',
                        v_publications.title,
                        v_book.publisher,
                        v_book.year,
                        NULL
                    );
                    dbms_output.put_line('operation "insert" successful. pubid: ' || v_publications.pubid || ' type: book' || ' title: ' || v_publications.title );
                    total_book_success := total_book_success + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        dbms_output.put_line('operation "insert" failed. pubid: ' || v_publications.pubid || ' type: book' || ' title: ' || v_publications.title );
                        dbms_output.put_line('error code: ' || sqlcode);
                        dbms_output.put_line('error message: ' || sqlerrm);
                        total_book_failed := total_book_failed + 1;
                        ROLLBACK;
                END;
            END IF;
        END LOOP;
 -- loop 2: journal
        FOR v_journal IN journal(v_publications.pubid) LOOP
            detail_found:= true;
            record_existed := false;
            FOR v_publication_master IN c_publication_master(v_publications.pubid) LOOP
                record_existed := true;
            END LOOP;

            IF record_existed THEN
 -- loop 2.1: update, if record existed
                BEGIN
                    UPDATE publication_master
                    SET
                        type = 'journal',
                        detail1 = v_publications.title,
                        detail2 = v_journal.volume,
                        detail3 = v_journal.num,
                        detail4 = v_journal.year
                    WHERE
                        pubid = v_publications.pubid;
                    dbms_output.put_line('operation "update" successful. pubid: ' || v_publications.pubid || ' type: journal' || ' title: ' || v_publications.title);
                    total_journal_success := total_journal_success + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        dbms_output.put_line('operation "update" failed. pubid: ' || v_publications.pubid || ' type: journal' || ' title: ' || v_publications.title);
                        dbms_output.put_line('error code: ' || sqlcode);
                        dbms_output.put_line('error message: ' || sqlerrm);
                        total_journal_failed := total_journal_failed + 1;
                        ROLLBACK;
                END;
            ELSE
 -- loop 2.2: insert, if record is new
                BEGIN
                    INSERT INTO publication_master(
                        pubid,
                        type,
                        detail1,
                        detail2,
                        detail3,
                        detail4
                    ) VALUES (
                        v_publications.pubid,
                        'journal',
                        v_publications.title,
                        v_journal.volume,
                        v_journal.num,
                        v_journal.year
                    );
                    total_journal_success := total_journal_success + 1;
                    dbms_output.put_line('operation "insert" successful. pubid: ' || v_publications.pubid || ' type: journal' || ' title: ' || v_publications.title);
                    total_journal_success := total_journal_success + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        dbms_output.put_line('operation "insert" failed. pubid: ' || v_publications.pubid || ' type: journal' || ' title: ' || v_publications.title);
                        dbms_output.put_line('error code: ' || sqlcode);
                        dbms_output.put_line('error message: ' || sqlerrm);
                        total_journal_failed := total_journal_failed + 1;
                        ROLLBACK;
                END;
            END IF;
        END LOOP;
 -- loop 3: proceedings
        FOR v_proceedings IN proceedings(v_publications.pubid) LOOP
            detail_found:= true;
            record_existed := false;
            FOR v_publication_master IN c_publication_master(v_publications.pubid) LOOP
                record_existed := true;
            END LOOP;

            IF record_existed THEN
 -- loop 3.1: update, if record existed
                BEGIN
                    UPDATE publication_master
                    SET
                        type = 'proceedings',
                        detail1 = v_publications.title,
                        detail2 = v_proceedings.year,
                        detail3 = NULL,
                        detail4 = NULL
                    WHERE
                        pubid = v_publications.pubid;
                    dbms_output.put_line('operation "update" successful. pubid: ' || v_publications.pubid || ' type: proceedings' || ' title: ' || v_publications.title );
                    total_proceedings_success := total_proceedings_success + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        dbms_output.put_line('operation "update" failed. pubid: ' || v_publications.pubid || ' type: proceedings' || ' title: ' || v_publications.title);
                        dbms_output.put_line('error code: ' || sqlcode);
                        dbms_output.put_line('error message: ' || sqlerrm);
                        total_proceedings_failed := total_proceedings_failed + 1;
                        ROLLBACK;
                END;
            ELSE
 -- loop 3.2: insert, if record is new
                BEGIN
                    INSERT INTO publication_master(
                        pubid,
                        type,
                        detail1,
                        detail2,
                        detail3,
                        detail4
                    ) VALUES (
                        v_publications.pubid,
                        'proceedings',
                        v_publications.title,
                        v_proceedings.year,
                        NULL,
                        NULL
                    );
                    dbms_output.put_line('operation "insert" successful. pubid: ' || v_publications.pubid || ' type: proceedings' || ' title: ' || v_publications.title );
                    total_proceedings_success := total_proceedings_success + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        dbms_output.put_line('operation "insert" failed. pubid: ' || v_publications.pubid || ' type: proceedings' || ' title: ' || v_publications.title );
                        dbms_output.put_line('error code: ' || sqlcode);
                        dbms_output.put_line('error message: ' || sqlerrm);
                        total_proceedings_failed := total_proceedings_failed + 1;
                        ROLLBACK;
                END;
            END IF;
        END LOOP;
 -- loop 4: article
        FOR v_article IN article(v_publications.pubid) LOOP
            detail_found:= true;
            record_existed := false;
            FOR v_publication_master IN c_publication_master(v_publications.pubid) LOOP
                record_existed := true;
            END LOOP;

            IF record_existed THEN
 -- loop 4.1: update, if record existed
                BEGIN
                    UPDATE publication_master
                    SET
                        type = 'article',
                        detail1 = v_publications.title,
                        detail2 = v_article.appearsin,
                        detail3 = v_article.startpage,
                        detail4 = v_article.endpage
                    WHERE
                        pubid = v_publications.pubid;
                    dbms_output.put_line('operation "update" successful. pubid: ' || v_publications.pubid || ' type: article' || ' title: ' || v_publications.title );
                    total_article_success := total_article_success + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        dbms_output.put_line('operation "update" failed. pubid: ' || v_publications.pubid || ' type: article' || ' title: ' || v_publications.title);
                        dbms_output.put_line('error code: ' || sqlcode);
                        dbms_output.put_line('error message: ' || sqlerrm);
                        total_article_failed := total_article_failed + 1;
                        ROLLBACK;
                END;
            ELSE
 -- loop 4.2: insert, if record is new
                BEGIN
                    INSERT INTO publication_master(
                        pubid,
                        type,
                        detail1,
                        detail2,
                        detail3,
                        detail4
                    ) VALUES (
                        v_publications.pubid,
                        'article',
                        v_publications.title,
                        v_article.appearsin,
                        v_article.startpage,
                        v_article.endpage
                    );
                    dbms_output.put_line('operation "insert" successful. pubid: ' || v_publications.pubid || ' type: article' || ' title: ' || v_publications.title );
                    total_article_success := total_article_success + 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        dbms_output.put_line('operation "insert" failed. pubid: ' || v_publications.pubid || ' type: article' || ' title: ' || v_publications.title );
                        dbms_output.put_line('error code: ' || sqlcode);
                        dbms_output.put_line('error message: ' || sqlerrm);
                        total_article_failed := total_article_failed + 1;
                        ROLLBACK;
                END;
            END IF;
        END LOOP;
 -- last if publication id not exist in {book, journal, proceedings, article} then count error
        IF NOT detail_found THEN
            dbms_output.put_line('error. unable to find any records in {book, journal, proceeding, article}. pubid: '|| v_publications.pubid || ' title: ' || v_publications.title);
            total_detail_not_found:= total_detail_not_found + 1;
        END IF;
    END LOOP;
 -- print summary
    total_operation := total_book_success + total_book_failed + total_journal_success + total_journal_failed + total_proceedings_success + total_proceedings_failed + total_article_success + total_article_failed;
    total_book := total_book_success + total_book_failed;
    total_journal := total_journal_success + total_journal_failed;
    total_proceedings := total_proceedings_success + total_proceedings_failed;
    total_article := total_article_success + total_article_failed;
    dbms_output.put_line('-------------------- merge operation summary --------------------');
    dbms_output.put_line('- total operation: ' || total_operation);
    dbms_output.put_line('- total missing detail: ' || total_detail_not_found);
    dbms_output.put_line('++ total opreation on book: ' || total_book || '  |  successful: ' || total_book_success || '  |  failed: ' || total_book_failed);
    dbms_output.put_line('++ total opreation on journal: ' || total_journal || '  |  successful: ' || total_journal_success || '  |  failed: ' || total_journal_failed);
    dbms_output.put_line('++ total opreation on proceeding: ' || total_proceedings || '  |  successful: ' || total_proceedings_success || '  |  failed: ' || total_proceedings_failed);
    dbms_output.put_line('++ total opreation on article: ' || total_article || '  |  successful: ' || total_article_success || '  |  failed: ' || total_article_failed);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('merge opreation failed. contact admin for assistant.');
        dbms_output.put_line('error code: ' || sqlcode);
        dbms_output.put_line('error message: ' || sqlerrm);
        ROLLBACK;
END;
/