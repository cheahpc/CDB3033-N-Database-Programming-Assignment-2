CREATE OR REPLACE PROCEDURE print_article(
    p_input_pubid CHAR
) IS
 -- cursor 1 merge pub pubid
    CURSOR c_merge_publication (
        p_pubid CHAR
    ) IS
    SELECT
        pubid,
        type,
        detail1
    FROM
        publication_master
    WHERE
        pubid = p_pubid;
 -- cursor 2 targeting article
    CURSOR c_article(
        p_pubid CHAR
    ) IS
    SELECT
        *
    FROM
        publication_master
    WHERE
        detail2 = p_pubid;
 -- cursor 3 targeting article base on start page
    CURSOR c_article_start_page(
        p_appearsin CHAR,
        p_start_page NUMBER
    ) IS
    SELECT
        *
    FROM
        publication_master
    WHERE
        detail2 = p_appearsin AND
        detail3 = p_start_page;
 -- array for sorting
    TYPE start_page_type IS
        TABLE OF INTEGER;
 -- variable
    v_start_page_array  start_page_type:=start_page_type();
    v_pub_type          CHAR(10);
    v_pub_tittle        CHAR(100);
    v_temp_start_page   NUMBER := 0;
    v_article_count     NUMBER := 0;
    v_pubid_is_valid    BOOLEAN := false;
 -- exception
    ex_invalid_pubid exception;
    ex_record_not_found exception;
    ex_type_error exception;
    ex_no_article exception;
BEGIN
 -- step 0: check if the pubid is valid
    IF p_input_pubid IS NULL THEN
        RAISE ex_invalid_pubid;
    END IF;
 -- step 1: check if the pubid is not article
    FOR v_cursor IN c_merge_publication(p_input_pubid) LOOP
        IF v_cursor.type = 'article' THEN
            RAISE ex_type_error;
        END IF;

        v_pub_type := v_cursor.type;
        v_pub_tittle := v_cursor.detail1;
        v_pubid_is_valid := true;
    END LOOP;
 -- step 2: check if record is found
    IF v_pubid_is_valid = false THEN
        RAISE ex_record_not_found;
    END IF;
 -- step 3: get the article into array
    FOR v_c_article IN c_article(p_input_pubid) LOOP
        v_article_count := v_article_count + 1;
        v_start_page_array.extend(1);
        v_start_page_array(v_article_count) := v_c_article.detail3;
    END LOOP;
 -- step 3.1: check if article is found
    IF v_article_count = 0 THEN
        RAISE ex_no_article;
    END IF;
 -- step 4: sort the array (bubble sort)
    FOR i IN 1..v_article_count LOOP
        FOR j IN i+1..v_article_count LOOP
            IF v_start_page_array(i) > v_start_page_array(j) THEN
                v_temp_start_page := v_start_page_array(i);
                v_start_page_array(i) := v_start_page_array(j);
                v_start_page_array(j) := v_temp_start_page;
            END IF;
        END LOOP;
    END LOOP;
 -- step 5: print the article
    dbms_output.put_line('==================== query result ====================');
    dbms_output.put_line('+ publication id: ' || p_input_pubid);
    dbms_output.put_line('+ publication tittle: ' || v_pub_tittle);
    dbms_output.put_line('+ publication type: ' || v_pub_type);
    dbms_output.put_line('+ article count: ' || v_article_count);
    dbms_output.put_line('------------------------------------------------------ article list');
    FOR v_i IN 1..v_article_count LOOP
        FOR v_c_article_start_page IN c_article_start_page(p_input_pubid, v_start_page_array(v_i)) LOOP
            dbms_output.put_line('article: ' || v_i || ' - ' || v_c_article_start_page.detail1);
        END LOOP;
    END LOOP;
EXCEPTION
    WHEN ex_invalid_pubid THEN
        dbms_output.put_line('error: invalid "pubid" provided. "pubid" cannot be null.');
    WHEN ex_record_not_found THEN
        dbms_output.put_line('error: no record found for the provided "pubid": ' || p_input_pubid);
    WHEN ex_type_error THEN
        dbms_output.put_line('error: provided "pubid": ' || p_input_pubid || ' is an article type.');
        dbms_output.put_line('please enter a "pubid" of a book, journal, or proceeding type.');
    WHEN ex_no_article THEN
        dbms_output.put_line('error: no article found for the provided "pubid": ' || p_input_pubid);
    WHEN OTHERS THEN
        dbms_output.put_line('error: an unexpected error occurred.');
        dbms_output.put_line('please contact the system administrator.');
        dbms_output.put_line('error code: ' || sqlcode);
        dbms_output.put_line('error message: ' || sqlerrm);
END;
/