CREATE OR REPLACE PROCEDURE print_publication(
    p_author_name IN VARCHAR2
) AS
 -- declare custom exceptions
    ex_invalid_author exception;
    ex_author_not_exist exception;
    ex_no_publications exception;
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
        pub_id VARCHAR2(50),
        pub_tittle VARCHAR2(500),
        pub_year INTEGER
    );
 -- declare a 2d array of table type
    TYPE pub_array_type IS
        TABLE OF item_type;
 -- initialize the array
    v_pub_array            pub_array_type:=pub_array_type();
    v_proceedings_count    INTEGER := 0;
    v_journal_count        INTEGER := 0;
    v_article_count        INTEGER := 0;
    v_book_count           INTEGER := 0;
    v_total_count          INTEGER := 0;
    v_author_count         INTEGER := 0;
    v_article_author_count INTEGER := 0;
    v_article_author_name  VARCHAR2(500); -- assume 50 char for 1 author, accomodate up to 10 authors
    v_author_name          VARCHAR2(500); -- assume 50 char for 1 author, accomodate up to 10 authors
    v_temp_id              VARCHAR2(50);
    v_temp_pub_title       VARCHAR2(500);
    v_temp_year            INTEGER;
    v_publication_count    INTEGER;
BEGIN
 -- step 0: check if author name is null
    IF p_author_name IS NULL THEN
        RAISE ex_invalid_author;
    END IF;
 -- step 0.1: check if author name exists
    FOR v_c_author IN c_author LOOP
        v_author_count := v_author_count + 1;
    END LOOP;

    IF v_author_count = 0 THEN
        RAISE ex_author_not_exist;
    END IF;
 -- reset the author count
    v_author_count := 0;
 -- step 0.2: check if author has any publications
    FOR v_c_author IN c_author LOOP
        v_publication_count:=0;
        FOR v_pubcount IN c_wrote(v_c_author.aid) LOOP
            v_publication_count := v_publication_count + 1;
        END LOOP;

        IF v_publication_count = 0 THEN
            RAISE ex_no_publications;
        END IF;
    END LOOP;
 -- #If author exist and has publications, then proceed to find the publication details#
 -- step 1: get author's id given author name
    FOR v_c_author IN c_author LOOP
 -- step 2: using author id, get pubid, from wrote (aid,pubid,aorder)
        FOR v_c_wrote IN c_wrote(v_c_author.aid) LOOP
            FOR v_c_publications IN c_publications(v_c_wrote.pubid) LOOP
 -- step 2.1: using pubid, get publication year, tittle  from {book, journal, proceedings}
                FOR v_book IN c_book(v_c_wrote.pubid) LOOP
                    v_pub_array.extend(1);
                    v_pub_array(v_pub_array.last).pub_id := v_c_wrote.pubid;
                    v_pub_array(v_pub_array.last).pub_tittle := v_c_publications.title;
                    v_pub_array(v_pub_array.last).pub_year := v_book.year;
                    v_book_count := v_book_count + 1;
                END LOOP;

                FOR v_journal IN c_journal(v_c_wrote.pubid) LOOP
                    v_pub_array.extend(1);
                    v_pub_array(v_pub_array.last).pub_tittle := v_c_publications.title;
                    v_pub_array(v_pub_array.last).pub_id := v_c_wrote.pubid;
                    v_pub_array(v_pub_array.last).pub_year := v_journal.year;
                    v_journal_count := v_journal_count + 1;
                END LOOP;

                FOR v_proceedings IN c_proceedings(v_c_wrote.pubid) LOOP
                    v_pub_array.extend(1);
                    v_pub_array(v_pub_array.last).pub_tittle := v_c_publications.title;
                    v_pub_array(v_pub_array.last).pub_id := v_c_wrote.pubid;
                    v_pub_array(v_pub_array.last).pub_year := v_proceedings.year;
                    v_proceedings_count := v_proceedings_count + 1;
                END LOOP;
            END LOOP;
        END LOOP;
 -- step 2.2: sort the array base on year (bubble sort)
        FOR i IN 1..v_pub_array.count-1 LOOP
            FOR j IN 1..v_pub_array.count-i LOOP
                IF v_pub_array(j).pub_year > v_pub_array(j+1).pub_year THEN
                    v_temp_id := v_pub_array(j).pub_id;
                    v_temp_pub_title := v_pub_array(j).pub_tittle;
                    v_temp_year := v_pub_array(j).pub_year;
                    v_pub_array(j).pub_id := v_pub_array(j+1).pub_id;
                    v_pub_array(j).pub_tittle := v_pub_array(j+1).pub_tittle;
                    v_pub_array(j).pub_year := v_pub_array(j+1).pub_year;
                    v_pub_array(j+1).pub_id := v_temp_id;
                    v_pub_array(j+1).pub_tittle := v_temp_pub_title;
                    v_pub_array(j+1).pub_year := v_temp_year;
                END IF;
            END LOOP;
        END LOOP;
 -- step 2.3: add articles pubid to the array
        FOR v_c_wrote IN c_wrote(v_c_author.aid) LOOP
            FOR v_c_publications IN c_publications(v_c_wrote.pubid) LOOP
                FOR v_article IN c_article(v_c_wrote.pubid) LOOP
                    v_pub_array.extend(1);
                    v_pub_array(v_pub_array.last).pub_id := v_c_wrote.pubid;
                    v_pub_array(v_pub_array.last).pub_tittle := v_c_publications.title;
                    v_pub_array(v_pub_array.last).pub_year := 0;
                    v_article_count := v_article_count + 1;
                END LOOP;
            END LOOP;
        END LOOP;
 -- step 2.4: update total publication count
        v_total_count := v_pub_array.count;
 -- step 3: using pubid from the sorted array, get author's name for each publication according to aorder
        FOR v_pub_array_i IN 1..v_pub_array.count LOOP
 -- step 3.1: get author count for each publication
            FOR v_each IN c_wrote_pubid(v_pub_array(v_pub_array_i).pub_id) LOOP
                v_author_count := v_author_count + 1;
            END LOOP;
 -- step 3.2: get author's aid using v_author_no as aorder
            FOR v_author_no IN 1..v_author_count LOOP
                FOR v_c_wrote_aoder IN c_wrote_aoder(v_pub_array(v_pub_array_i).pub_id, v_author_no) LOOP
 -- step 3.4: using aid from aorder, get author's name
                    FOR v_c_author_aid IN c_author_aid(v_c_wrote_aoder.aid) LOOP
                        IF v_author_name IS NULL THEN
                            v_author_name := v_c_author_aid.name;
                        ELSE
                            v_author_name := v_author_name || ', ' || v_c_author_aid.name;
                        END IF;
                    END LOOP;
                END LOOP;
            END LOOP;
 -- step 4: using pubid from the sorted array, get publication details from {book, journal, proceedings, article}
            dbms_output.put_line('==================== publication no: '|| v_pub_array_i || ' ====================');
            dbms_output.put_line('+ pubid: ' || v_pub_array(v_pub_array_i).pub_id);
            FOR v_c_book IN c_book(v_pub_array(v_pub_array_i).pub_id) LOOP
                dbms_output.put_line('+ type: ' || 'book');
                dbms_output.put_line('+ author: ' || v_author_name);
                dbms_output.put_line('+ title: ' || v_pub_array(v_pub_array_i).pub_tittle);
                dbms_output.put_line('==================== details');
                dbms_output.put_line('++  publisher: ' || v_c_book.publisher);
                dbms_output.put_line('++  year: ' || v_c_book.year);
            END LOOP;

            FOR v_c_journal IN c_journal(v_pub_array(v_pub_array_i).pub_id) LOOP
                dbms_output.put_line('+ type: ' || 'journal');
                dbms_output.put_line('+ author: ' || v_author_name);
                dbms_output.put_line('+ title: ' || v_pub_array(v_pub_array_i).pub_tittle);
                dbms_output.put_line('==================== details');
                dbms_output.put_line('++  volume: ' || v_c_journal.volume);
                dbms_output.put_line('++  number: ' || v_c_journal.num);
                dbms_output.put_line('++  year: ' || v_c_journal.year);
            END LOOP;

            FOR v_c_proceedings IN c_proceedings(v_pub_array(v_pub_array_i).pub_id) LOOP
                dbms_output.put_line('+ type: ' || 'proceedings');
                dbms_output.put_line('+ author: ' || v_author_name);
                dbms_output.put_line('+ title: ' || v_pub_array(v_pub_array_i).pub_tittle);
                dbms_output.put_line('==================== details');
                dbms_output.put_line('++  year: ' || v_c_proceedings.year);
            END LOOP;

            FOR v_c_article IN c_article(v_pub_array(v_pub_array_i).pub_id) LOOP
                dbms_output.put_line('+ type: ' || 'article');
                dbms_output.put_line('+ author: ' || v_author_name);
                dbms_output.put_line('+ title: ' || v_pub_array(v_pub_array_i).pub_tittle);
                dbms_output.put_line('==================== details');
                dbms_output.put_line('++  appearsin: ' || v_c_article.appearsin);
                dbms_output.put_line('++  startpage: ' || v_c_article.startpage);
                dbms_output.put_line('++  endpage: ' || v_c_article.endpage);
                dbms_output.put_line('+++++++++++++++ appears in - details');
 -- step 5: get relevant details for article
 --  step 5.1: get author count for each article
                FOR v_each IN c_wrote_pubid(v_c_article.appearsin) LOOP
                    v_article_author_count := v_article_author_count + 1;
                END LOOP;
 -- step 5.2: get author's aid using v_author_no as aorder
                FOR v_author_no IN 1..v_article_author_count LOOP
                    FOR v_c_wrote_aoder IN c_wrote_aoder(v_c_article.appearsin, v_author_no) LOOP
 -- step 5.4: using aid from aorder, get author's name
                        FOR v_c_author_aid IN c_author_aid(v_c_wrote_aoder.aid) LOOP
                            IF v_article_author_name IS NULL THEN
                                v_article_author_name := v_c_author_aid.name;
                            ELSE
                                v_article_author_name := v_article_author_name || ', ' || v_c_author_aid.name;
                            END IF;
                        END LOOP;
                    END LOOP;
                END LOOP;
 -- step 5.5: print relevant details for the article's appearsin {book, journal, proceedings}
                dbms_output.put_line('pubid a.k.a.(appearsin): ' || v_c_article.appearsin);
                FOR v_article_publications IN c_publications(v_c_article.appearsin) LOOP
                    FOR v_book IN c_book(v_c_article.appearsin) LOOP
                        dbms_output.put_line('+++   type: ' || 'book');
                        dbms_output.put_line('+++   author: ' || v_article_author_name);
                        dbms_output.put_line('+++   title: ' || v_article_publications.title);
                        dbms_output.put_line('++++++++++');
                        dbms_output.put_line('++++    publisher: ' || v_book.publisher);
                        dbms_output.put_line('++++    year: ' || v_book.year);
                    END LOOP;

                    FOR v_journal IN c_journal(v_c_article.appearsin) LOOP
                        dbms_output.put_line('+++   type: ' || 'journal');
                        dbms_output.put_line('+++   author: ' || v_article_author_name);
                        dbms_output.put_line('+++   title: ' || v_article_publications.title);
                        dbms_output.put_line('++++++++++');
                        dbms_output.put_line('++++    volume: ' || v_journal.volume);
                        dbms_output.put_line('++++    number: ' || v_journal.num);
                        dbms_output.put_line('++++    year: ' || v_journal.year);
                    END LOOP;

                    FOR v_proceedings IN c_proceedings(v_c_article.appearsin) LOOP
                        dbms_output.put_line('+++   type: ' || 'proceedings');
                        dbms_output.put_line('+++   author: ' || v_article_author_name);
                        dbms_output.put_line('+++   title: ' || v_article_publications.title);
                        dbms_output.put_line('++++++++++');
                        dbms_output.put_line('++++    year: ' || v_proceedings.year);
                    END LOOP;
                END LOOP;
 -- reset the article author count and article author name variable after each publication
                dbms_output.put_line(' ');
                v_article_author_count := 0;
                v_article_author_name := NULL;
            END LOOP;
 -- reset the author count and author name variable after each publication
            dbms_output.put_line(' ');
            dbms_output.put_line(' ');
            v_author_count := 0;
            v_author_name := NULL;
        END LOOP;
    END LOOP;
 -- print the summary page
    dbms_output.put_line('-------------------- summary --------------------');
    dbms_output.put_line('proceedings: ' || v_proceedings_count);
    dbms_output.put_line('journal: ' || v_journal_count);
    dbms_output.put_line('article: ' || v_article_count);
    dbms_output.put_line('book: ' || v_book_count);
    dbms_output.put_line('total publication: ' || v_total_count);
 -- exception handling
EXCEPTION
    WHEN ex_invalid_author THEN
        dbms_output.put_line('error: invalid author name.');
    WHEN ex_author_not_exist THEN
        dbms_output.put_line('error: author name does not exist.');
    WHEN ex_no_publications THEN
        dbms_output.put_line('error: no publications found for this author.');
    WHEN OTHERS THEN
        dbms_output.put_line('unexpected error: ' || sqlerrm);
END;
/