SPOOL /tmp/oracle/projectPart5_spool.txt

SELECT
    to_char(sysdate, 'DD Month YYYY Year Day HH:MI:SS AM')
FROM
    dual;

/* Question 1 : 
Run script 7Northwoods.
Using cursor to display many rows of data, create a procedure to display the all 
the rows of table term.  */
connect des03/des03

set serveroutput ON

CREATE OR REPLACE PROCEDURE L5Q1 AS
CURSOR term_curr IS
    SELECT
        TERM_ID,
        TERM_DESC,
        STATUS
    FROM
        TERM;
v_term_id TERM.TERM_ID%TYPE;
v_term_desc TERM.TERM_DESC%TYPE;
v_status TERM.STATUS%TYPE;
BEGIN
    OPEN
        term_curr;
    LOOP
        FETCH
            term_curr INTO
            v_term_id,
            v_term_desc,
            v_status;
        EXIT WHEN term_curr%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Term ' || v_term_id || '. ' || v_term_desc || ': ' || v_status);
    END LOOP;
    CLOSE
        term_curr;
END;
/

exec L5Q1


/* Question 2 : 
Run script 7Clearwater.
Using cursor to display many rows of data, create a procedure to display the 
following data from the database: Item description, price, color, and quantity on 
hand. */
connect des02/des02

set serveroutput ON

CREATE OR REPLACE PROCEDURE L5Q2 AS
CURSOR item_curr IS
    SELECT
        ITEM_DESC,
        INV_PRICE,
        COLOR,
        INV_QOH
    FROM
        ITEM iT JOIN INVENTORY inv ON it.ITEM_ID = inv.ITEM_ID;
v_item_desc ITEM.ITEM_DESC%TYPE;
v_inv_price INVENTORY.INV_PRICE%TYPE;
v_color INVENTORY.COLOR%TYPE;
v_inv_qoh INVENTORY.INV_QOH%TYPE;
BEGIN
    OPEN
        item_curr;
    LOOP
        FETCH
            item_curr INTO
            v_item_desc,
            v_inv_price,
            v_color,
            v_inv_qoh;
        EXIT WHEN item_curr%NOTFOUND;
        IF v_inv_qoh > 0 THEN
            DBMS_OUTPUT.PUT_LINE(v_item_desc || ': $' || v_inv_price || ', ' || v_color ||
                                ', ' || v_inv_qoh || ' pieces left');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_item_desc || ': $' || v_inv_price || ', ' || v_color ||
                                ', UNAVAILABLE');
        END IF;
    END LOOP;
    CLOSE
        item_curr;
END;
/

exec L5Q2


/* Question 3 : 
Run script 7Clearwater.
Using cursor to update many rows of data, create a procedure that accepts a 
number represent the percentage increase in price. The procedure will display the 
old price, new price and update the database with the new price. */
CREATE OR REPLACE PROCEDURE L5Q3(p_increase IN INVENTORY.INV_PRICE%TYPE) AS
CURSOR price_curr IS
    SELECT
        INV_PRICE,
        INV_PRICE + (INV_PRICE / 100 * p_increase)
    FROM
        INVENTORY;
    v_old_price INVENTORY.INV_PRICE%TYPE;
    v_new_price INVENTORY.INV_PRICE%TYPE;
BEGIN
    OPEN
        price_curr;
    IF p_increase > -100 THEN 
        LOOP
            FETCH
                price_curr INTO
                v_old_price,
                v_new_price;
            v_new_price := v_old_price + (v_old_price / 100 * p_increase);
            UPDATE
                INVENTORY
            SET
                INV_PRICE = v_new_price
            WHERE
                INV_PRICE = v_old_price;
            COMMIT; 
            EXIT WHEN price_curr%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Old price: $' || v_old_price || ', New price: $' || v_new_price);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Incorrect Percentage! Unless it''s a FREE GIVE AWAY!');
    END IF;
    CLOSE
        price_curr;
END;
/

exec L5Q3(-100)

exec L5Q3(5)


/* Question 4 : 
Run script EMP_DEPT(scott).
Create a procedure that accepts a number represent the number of employees 
who earns the highest salary. Display employee name and his/her salary
Ex: SQL> exec L5Q4(2) 
SQL> top 2 employees are
KING 5000
FORD 3000 */
connect scott/tiger

set serveroutput ON

CREATE OR REPLACE PROCEDURE L5Q4(p_highest_sal_emp IN NUMBER) AS
CURSOR emp_curr IS
    SELECT
        ENAME,
        SAL
    FROM
        EMP
    ORDER BY
        SAL DESC;
    v_name EMP.ENAME%TYPE;
    v_sal EMP.SAL%TYPE;
BEGIN
    OPEN
        emp_curr;
    DBMS_OUTPUT.PUT_LINE('Top ' || p_highest_sal_emp || ' employees are:');
    FOR i IN 1 .. p_highest_sal_emp LOOP
        FETCH
            emp_curr INTO
            v_name,
            v_sal;
        EXIT WHEN emp_curr%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' ' || v_sal);
    END LOOP;
    CLOSE
        emp_curr;
END;
/

exec L5Q4(2)

exec L5Q4(30)


/* Question 5:
Modify question 4 to display ALL employees who make the top salary entered 
Ex: SQL> exec L5Q5(2) 
SQL> Employee who make the top 2 salary are
KING 5000
FORD 3000
SCOTT 3000 */
CREATE OR REPLACE PROCEDURE L5Q5(p_top_sal IN NUMBER) AS
CURSOR emp_curr IS
    WITH x AS (
                SELECT
                    DISTINCT desc_order.SAL
                FROM (
                        SELECT
                            SAL
                        FROM
                            EMP
                        ORDER BY
                            SAL DESC
                        ) desc_order
                WHERE ROWNUM <= p_top_sal
                )
    SELECT
        ENAME,
        SAL
    FROM
        EMP
    WHERE SAL IN (
                    SELECT
                        SAL
                    FROM
                        x
                    )
    ORDER BY
        SAL DESC;    
    v_name EMP.ENAME%TYPE;
    v_sal EMP.SAL%TYPE;
BEGIN
    OPEN
        emp_curr;
    DBMS_OUTPUT.PUT_LINE('Employee who make the top ' || p_top_sal || ' salary are:');
    LOOP
        FETCH
            emp_curr INTO
            v_name,
            v_sal;
        EXIT WHEN emp_curr%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_name || ' ' || v_sal);
    END LOOP;
    CLOSE
        emp_curr;
END;
/

exec L5Q5(2)

exec L5Q5(3)

exec L5Q5(30)

SPOOL OFF;