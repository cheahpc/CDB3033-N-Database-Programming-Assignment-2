CREATE OR REPLACE PROCEDURE display_master_publication AS
    CURSOR c_master_publication IS
    SELECT
        pubid,
        type,
        detail1,
        detail2,
        detail3,
        detail4
    FROM
        publication_master;
 -- variable
    v_counter NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(' - - - retrieving information from publication master - - - ' );
    FOR v_c_master_publication IN c_master_publication LOOP
        v_counter := v_counter + 1;
        dbms_output.put_line('==================== publication: ' || v_counter || ' ====================');
        dbms_output.put_line('+ pubid: ' || v_c_master_publication.pubid);
        CASE v_c_master_publication.type
            WHEN 'book' THEN
                dbms_output.put_line('+ type: book' );
                dbms_output.put_line('+ title: ' || v_c_master_publication.detail1);
                dbms_output.put_line('+ publisher: ' || v_c_master_publication.detail2);
                dbms_output.put_line('+ year: ' || v_c_master_publication.detail3);
            WHEN 'journal' THEN
                dbms_output.put_line('+ type: journal' );
                dbms_output.put_line('+ title: ' || v_c_master_publication.detail1);
                dbms_output.put_line('+ volume: ' || v_c_master_publication.detail2);
                dbms_output.put_line('+ number: ' || v_c_master_publication.detail3);
                dbms_output.put_line('+ year: ' || v_c_master_publication.detail4);
            WHEN 'proceedings' THEN
                dbms_output.put_line('+ type: proceedings' );
                dbms_output.put_line('+ title: ' || v_c_master_publication.detail1);
                dbms_output.put_line('+ year: ' || v_c_master_publication.detail2);
            WHEN 'article' THEN
                dbms_output.put_line('+ type: article' );
                dbms_output.put_line('+ title: ' || v_c_master_publication.detail1);
                dbms_output.put_line('+ appears in: ' || v_c_master_publication.detail2);
                dbms_output.put_line('+ start page: ' || v_c_master_publication.detail3);
                dbms_output.put_line('+ end page: ' || v_c_master_publication.detail4);
        END CASE;

        dbms_output.put_line(' ');
        dbms_output.put_line(' ');
    END LOOP;

    IF v_counter = 0 THEN
        dbms_output.put_line('no publication found. 0 rows selected.');
    ELSE
        dbms_output.put_line('total ' || v_counter || ' publication(s) found.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Unknown error occured. Please contact admin.');
        dbms_output.put_line('Error code: ' || SQLCODE);
        dbms_output.put_line('Error message: ' || SQLERRM);
END;