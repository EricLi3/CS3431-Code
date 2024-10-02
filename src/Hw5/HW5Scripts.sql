-- Eric Li - CS3431 HW5

-- Problem 1. Constraints Specification in SQL [25 pts]/////////////////////////////////////////////////////////////////////////////////////////////////////////////

------ 1.------------------
ALTER TABLE PRODUCT
    ADD CONSTRAINT check_type CHECK (type IN ('PC', 'Laptop'));
-- CHECK TO SEE IF CONSTRAINT WORKS. IT does.
-- INSERT INTO Product
-- VALUES('1012', 'P','Test');

------ 2.------------------
ALTER TABLE LAPTOP
    ADD CONSTRAINT check_laptop_price check ( PRICE >= 500 );
-- CHECK TO SEE IF CONSTRAINT WORKS. IT does.
INSERT INTO LAPTOP
VALUES('1000', 5000, 32, 1080, 15, 20);

------ 3.------------------
/*This constraint cannot be enforces using purely using DDL statements. This is because DDL constants are typically
  done on individual rows and cannot reference multiple rows*/

------ 4.------------------
ALTER TABLE PC
    ADD CONSTRAINT fk_pc_model FOREIGN KEY (MODEL) REFERENCES PRODUCT(MODEL);

ALTER TABLE LAPTOP
    ADD CONSTRAINT fk_laptop_model FOREIGN KEY (MODEL) REFERENCES  PRODUCT(MODEL);

-- we can test these constraints by inserting tuples that have model not present in product

-- THESE SHOULD FAIL

INSERT INTO PC
    VALUES ('Impossible', 12,2, 39, 45, 1);

INSERT INTO LAPTOP(MODEL, SPEED, RAM, HD, SCREEN, PRICE)
    VALUES ('IMpossible', 12,2,39,45, 720);

------ 5.------------------

-- We can't enforce this constraint in ORACLE becuase subqueries aren't allowed within chekc constraints.

    -- My illegal attempt
-- ALTER TABLE Product
--     ADD CONSTRAINT check_max_manufacturers
--         CHECK (
--             (SELECT COUNT(DISTINCT manufacturer) FROM Product) <= 5
--         );


-- Problem 2/////////////////////////////////////////////////////////////////////////////////////////////////////////////

    DROP TABLE PRODUCT CASCADE CONSTRAINTS;
    DROP TABLE PC CASCADE CONSTRAINTS;
    DROP TABLE LAPTOP CASCADE CONSTRAINTS;

CREATE TABLE Product(
                        model CHAR(10) PRIMARY KEY,
                        manufacturer CHAR(10),
                        type CHAR(10)
);
CREATE TABLE PC(
                   model CHAR(10) PRIMARY KEY,
                   speed INT,
                   ram INT,
                   hd INT,
                   rd CHAR(10),
                   price INT);


CREATE TABLE Laptop(
                       model CHAR(10) PRIMARY KEY,
                       speed INT,
                       ram INT,
                       hd INT,
                       screen number(4,2),
                       price INT
                   );
------1.---------------------------------------------------------------------------------
/*Write one or more triggers to enforce overlap constraints, namely, to specify that when inserting a new laptop,
  the model number should not also appear in the PC table, and vice versa.*/

Create or replace TRIGGER insertLaptop
    Before INSERT on LAPTOP
    FOR EACH ROW
Declare
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM PC WHERE PC.MODEL = :NEW.MODEL;
    IF (v_count > 0) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Model of Laptop is not mutually exclusive with PC model');
    END IF;
    END;
/

Create or replace TRIGGER insertPC
    Before INSERT on PC
    FOR EACH ROW
Declare
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM LAPTOP WHERE LAPTOP.MODEL = :NEW.MODEL;
    IF (v_count > 0) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Model of PC is not mutually exclusive with Laptop model');
    END IF;
END;
/
-- Test on Inserting into LAPTOP
INSERT INTO LAPTOP VALUES (1000, 12,2,1,1,1);

-- Test on Inserting into PC
INSERT INTO PC VALUES (2002, 1,1,1,1,1);

-----------2. -------------------------------------------------------
-- Write one or more triggers to specify that for any tuple in the PC table the hard disk of
-- the PC is at least 100 times greater than its RAM. (Note that the hard disk is in GB, while
-- RAM is in MB).
Create or replace TRIGGER pc_disk_ram_rel
BEFORE INSERT OR UPDATE on PC
FOR EACH ROW
    BEGIN
            IF((:NEW.HD * 1000 / :NEW.RAM) < 100) then
                RAISE_APPLICATION_ERROR(-20004, 'Hard disk size (GB) must be at least 100 times RAM size (MB)');
            end if;
    end;

-- Testing These should fail if you run them.
INSERT INTO PRODUCT VALUES ('1005', 'goog', 'PC');
INSERT INTO PC VALUES (1005, 24, 1000, 50, '48xCD', 9000);
UPDATE PC SET RAM = 100000 WHERE MODEL = '1000';

-----------3. -------------------------------------------------------
--whenever the prices of a Product model are being modified, that then there is a “log tuple” inserted
CREATE TABLE Product_Monitoring(
    Model CHAR(10),
    Type CHAR(10),
    OldPrice NUMBER,
    NewPrice NUMBER,
    time_mod VARCHAR2(30)
);


CREATE TRIGGER pc_price_update_trigger
    BEFORE UPDATE OF price ON PC
    FOR EACH ROW
BEGIN
    INSERT INTO Product_Monitoring
    VALUES (:old.MODEL, 'PC', :old.price, :new.price, to_char(SYSDATE, 'dd-mm-yyyy:hh24:mi'));
END;
/

CREATE TRIGGER laptop_price_update_trigger
    BEFORE UPDATE OF price ON LAPTOP
    FOR EACH ROW
BEGIN
    INSERT INTO Product_Monitoring
    VALUES (:old.MODEL, 'Laptop', :old.price, :new.price, to_char(SYSDATE, 'dd-mm-yyyy:hh24:mi'));
END;
/

-- When I run these, the result gets logged in the PRODUCT_MONITORING
UPDATE PC SET PRICE = 900 WHERE MODEL = '1003';
UPDATE LAPTOP SET PRICE = 900 WHERE MODEL = '2002';

-----------4. -------------------------------------------------------
-- Write one or more triggers to enforce the constraint that at all times the Product table is
-- consistent with the other two tables. This is an extension of the foreign key constraint
-- semantics. So now assume here that you did not have access in your DBMS to any direct
-- support for foreign keys.
--
-- That is, if in the Product table, a product row is specified as
-- being of PC type then its model number also appears in the corresponding PC table.
-- Similarly, if a product is of type laptop, then its model number must also appear in the
-- laptop table. If the type VALUE is “NULL”, then it should appear in none of the other
-- tables.
--
-- Or, vice-versa, check that any tuple that is being inserted into the Laptop or the
-- PC table, either already exists in the Product table, or if not then you also will add it into
-- the Product table as part of the current update.

--Trigger to Enforce Consistency on Updates Product:
CREATE OR REPLACE TRIGGER product_update_trigger
    BEFORE UPDATE OF model, type ON PRODUCT
    FOR EACH ROW
    BEGIN
        IF (:old.type != :new.type) then
            -- type change
            CASE :new.type
                WHEN 'PC' THEN
                    INSERT INTO PC (MODEL) VALUES(:new.model);
                WHEN 'Laptop' THEN

                    INSERT INTO LAPTOP (MODEL) VALUES(:new.model);
                WHEN 'NULL' THEN
                    DELETE FROM PC WHERE PC.MODEL = :new.model;
                    DELETE FROM LAPTOP WHERE LAPTOP.MODEL = :new.model;
            END CASE;
        end if;

        -- If the model number changes
        IF(:old.model != :new.model) THEN
            UPDATE PC SET model = :new.model WHERE model = :old.model;
            UPDATE Laptop SET model = :new.model WHERE model = :old.model;
        end if;
    end;
/

DROP TRIGGER product_update_trigger;
--Trigger to Enforce Consistency on Inserts Product:

CREATE OR REPLACE TRIGGER product_insert_trigger
    BEFORE INSERT ON Product
    FOR EACH ROW
DECLARE
    pc_count INTEGER;
    laptop_count INTEGER;

BEGIN

    -- Check if the model is for PC
    IF :NEW.type = 'PC' THEN
        -- Check if the model exists in the PC table
        SELECT COUNT(*)
        INTO pc_count
        FROM PC
        WHERE model = :NEW.model;

        -- If the model does not exist in PC table, raise an error
        IF pc_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Model does not exist in the PC table.');
        END IF;

        -- Check if the model is for Laptop
    ELSIF :NEW.type = 'Laptop' THEN
        -- Check if the model exists in the Laptop table
        SELECT COUNT(*)
        INTO laptop_count
        FROM LAPTOP
        WHERE model = :NEW.model;

        -- If the model does not exist in Laptop table, raise an error
        IF laptop_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Model does not exist in the Laptop table.');
        END IF;

        -- Handle case where type is NULL
    ELSIF :NEW.type IS NULL THEN
        -- Check if the model exists in either PC or Laptop tables
        SELECT COUNT(*)
        INTO pc_count
        FROM PC
        WHERE model = :NEW.model;

        SELECT COUNT(*)
        INTO laptop_count
        FROM LAPTOP
        WHERE model = :NEW.model;

        -- If the model exists in either table, raise an error
        IF pc_count > 0 OR laptop_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Model exists in PC or Laptop table but Product type is NULL.');
        END IF;

    ELSE
        RAISE_APPLICATION_ERROR(-20004, 'Invalid type. Type must be PC, Laptop, or NULL.');
    END IF;
END;
/

DROP TRIGGER product_insert_trigger;

CREATE VIEW laptop_view AS
SELECT * FROM Laptop;

-- ON INSERT to Laptop table, if Model not add it
CREATE OR REPLACE TRIGGER laptopView_insert_trigger
    INSTEAD OF INSERT ON laptop_view
    FOR EACH ROW
DECLARE
    m_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO m_count FROM PRODUCT WHERE MODEL = :NEW.MODEL;

    INSERT INTO Laptop (MODEL) VALUES (:NEW.MODEL);

    IF m_count = 0 THEN
        INSERT INTO PRODUCT (MODEL, TYPE) VALUES (:NEW.MODEL, 'Laptop');
    END IF;

END;
/
DROP TRIGGER laptopView_insert_trigger;

CREATE VIEW pc_view AS
SELECT * FROM PC;

-- ON INSERT to PC table, if Model not add it
CREATE OR REPLACE TRIGGER pcView_insert_trigger
    INSTEAD OF INSERT ON pc_view
    FOR EACH ROW
DECLARE
    m_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO m_count FROM PRODUCT WHERE MODEL = :NEW.MODEL;

    INSERT INTO PC (MODEL) VALUES (:NEW.MODEL);

    IF m_count = 0 THEN
        INSERT INTO PRODUCT (MODEL, TYPE) VALUES (:NEW.MODEL, 'PC');
    END IF;

END;
/

DROP TRIGGER pcView_insert_trigger;

INSERT INTO laptop_view VALUES ('203', 12, 12,100, 12.4, 4000);
INSERT INTO PC_VIEW VALUES ('205', 12, 12,100, 12.4, 4000);

INSERT INTO PRODUCT (Model, TYPE) VALUES ('20066', 'Laptop');

INSERT INTO PRODUCT (Model, TYPE) VALUES ('20026', 'PC');

INSERT INTO LAPTOP_VIEW VALUES ('2001', 12, 12,100, 12.4, 4000);

UPDATE PRODUCT SET TYPE = NULL WHERE MODEL = '5000';


-----Problem 3: View Specification in SQL [25 pts]------------------------------
CREATE VIEW PCPriceList AS Select model, price from PC;
---- 1.---------------------------------
SELECT model
FROM PCPRICELIST
WHERE price = ( SELECT MIN(PRICE) FROM PCPRICELIST);

/*
We can delete from this view directly because the view has a primary key model which makes it updatable.
*/
DELETE FROM PCPRICELIST WHERE model = '1004';
---- 2.---------------------------------
/*Can you perform an insert such as: INSERT INTO PCPriceList(model) VALUES (2005)?
  When yes and when no? Discuss.*/
INSERT INTO PCPRICELIST(model) VALUES(2005);

-- It allows you to add 2005 to the PCPriceList But this should't be valid
-- since we are essentially cnaging the PC table, which with only the 2005 being the model, all the other fields will be null
-- This might not be desirable.

---- 3.---------------------------------
-- What about an insert such as: INSERT INTO PCPriceList (price) VALUES (1700)? Discuss. Show what happens.

INSERT INTO PCPriceList (price) VALUES (1700)

-- This statemnt does't work and returns the error message:

-- This is likely becuase the underlying table we are inserting into is the PC table
-- The PC table defines Model as the Primary Key, and in our insert, we don't have a Model, so it's null
-- It's impossible to insert a tuple into PC with a null PK. So we see the error.

---- 4.---------------------------------
-- Now using SQL DDL, define a second view extendedPC(manufacturer, model, speed,
-- ram, hd, rd, price, type). This view will give every PC made by each manufacturer. Can
-- you delete from this extendedPC view? Discuss. Show what happens.

CREATE VIEW extendedPC AS SELECT MANUFACTURER, model, speed, ram, hd, rd, price, type
                          from PC NATURAL JOIN EKLI.PRODUCT P;


/*Deleting from this view will be quite ambiguous given there being more than one relation involved*/
DELETE FROM EXTENDEDPC WHERE MODEL = 205;