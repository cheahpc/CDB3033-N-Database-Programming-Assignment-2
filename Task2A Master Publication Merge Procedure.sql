CREATE OR REPLACE PROCEDURE merge_publication AS
 --  cursor 1 publication
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
    total_records  NUMBER := 0;
    record_existed BOOLEAN := false;
BEGIN
    FOR v_publications IN c_publications LOOP
 -- loop 1: book
        FOR v_book IN c_book(v_publications.pubid) LOOP
            record_existed := false;
            FOR v_publication_master IN c_publication_master(v_publications.pubid) LOOP
                record_existed := true;
            END LOOP;
 -- update if record existed
            IF record_existed THEN
                UPDATE publication_master
                SET
                    type = 'book',
                    detail1 = v_publications.title,
                    detail2 = v_book.publisher,
                    detail3 = v_book.year,
                    detail4 = NULL
                WHERE
                    pubid = v_publications.pubid;
 -- else insert into master record
            ELSE
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
            END IF;
        END LOOP;
 -- loop 2: journal
        FOR v_journal IN journal(v_publications.pubid) LOOP
            record_existed := false;
            FOR v_publication_master IN c_publication_master(v_publications.pubid) LOOP
                record_existed := true;
            END LOOP;
 -- update if record existed
            IF record_existed THEN
                UPDATE publication_master
                SET
                    type = 'journal',
                    detail1 = v_publications.title,
                    detail2 = v_journal.volume,
                    detail3 = v_journal.num,
                    detail4 = v_journal.year
                WHERE
                    pubid = v_publications.pubid;
 -- else insert into master record
            ELSE
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
            END IF;
        END LOOP;
 -- loop 3: proceedings
        FOR v_proceedings IN proceedings(v_publications.pubid) LOOP
            record_existed := false;
            FOR v_publication_master IN c_publication_master(v_publications.pubid) LOOP
                record_existed := true;
            END LOOP;
 -- update if record existed
            IF record_existed THEN
                UPDATE publication_master
                SET
                    type = 'proceedings',
                    detail1 = v_publications.title,
                    detail2 = V_PROCEEDINGS.YEAR,
                    detail3 = NULL,
                    detail4 = NULL
                WHERE
                    pubid = v_publications.pubid;
 -- else insert into master record
            ELSE
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
            END IF;
        END LOOP;
 -- loop 4: article
        FOR v_article IN article(v_publications.pubid) LOOP
            record_existed := false;
            FOR v_publication_master IN c_publication_master(v_publications.pubid) LOOP
                record_existed := true;
            END LOOP;
 -- update if record existed
            IF record_existed THEN
                UPDATE publication_master
                SET
                    type = 'article',
                    detail1 = v_publications.title,
                    detail2 = v_article.appearsin,
                    detail3 = v_article.startpage,
                    detail4 = v_article.endpage
                WHERE
                    pubid = v_publications.pubid;
 -- else insert into master record
            ELSE
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
            END IF;
        END LOOP;
    END LOOP;
 -- last if publication id not exist in {book, journal, proceedings, article} then count error
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('no publication details found in proceedings, journal, article, and book tables.');
END;
/