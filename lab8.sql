-- 1. Create a function that:
-- a. Increments given values by 1 and returns it.
CREATE FUNCTION fun1(val integer)
    RETURNS INTEGER
AS
$$
BEGIN
    RETURN val + 1;
END;
$$
    LANGUAGE PLPGSQL;

SELECT fun1(2)

-- b. Returns sum of 2 numbers.
CREATE FUNCTION fun2(
    a integer,
    b integer
)
    RETURNS NUMERIC AS
$$
BEGIN
    RETURN a + b;
END;
$$
    LANGUAGE plpgsql;

SELECT fun2(2, 3);

-- c. Returns true or false if numbers are divisible by 2.
CREATE FUNCTION div(num integer)
    RETURNS VARCHAR AS
$$
BEGIN
    IF num % 2 = 0 THEN
        raise notice 'true';
    ELSE
        raise notice 'false';
    END IF;
END
$$
    LANGUAGE plpgsql;

SELECT div(2);
SELECT div(3);

-- d. Checks some password for validity.
-- in password should contains letter(alphabet)
CREATE FUNCTION valid_pass(password varchar(8))
    RETURNS VARCHAR AS
$$
BEGIN
    IF password ~* '[a-z]' THEN
        raise notice 'valid';
    ELSE
        raise notice 'invalid';
    END IF;
END
$$
    LANGUAGE plpgsql;

SELECT valid_pass('asd12345');
SELECT valid_pass('12345678');

-- e. Returns two outputs, but has one input.
CREATE OR REPLACE FUNCTION calculate(
    a NUMERIC,
    OUT plus NUMERIC,
    OUT minus NUMERIC)
AS
$$
BEGIN
    plus := a + 1;
    minus := a - 1;
END;
$$
    LANGUAGE plpgsql;

SELECT *
FROM calculate(1);

-- 2- method
CREATE FUNCTION table1(inp int)
    returns table
            (
                plus  int,
                minus int
            )
AS
$$
BEGIN
    plus := inp + 1; minus := inp - 1;
    return next;
END;
$$
    LANGUAGE plpgsql;

SELECT *
FROM table1(1);

-- 2. Create a trigger that:
-- a. timestamp
CREATE TABLE PERSON
(
    PERSON_NAME varchar,
    BIRTHDAY    DATE
);

CREATE OR REPLACE FUNCTION trigger_on_changes1() returns trigger AS
$$
begin
    new.logtime := current_timestamp;
    return new;
end;
$$
    language plpgsql;

CREATE TRIGGER trigger_on_changes
    BEFORE INSERT OR UPDATE
    ON PERSON
    FOR EACH ROW
execute function trigger_on_changes1();

INSERT INTO PERSON
VALUES ('Aizhan', '2000-08-12');

SELECT *
FROM PERSON;

-- b. Computes the age of a person when persons’ date of birth is inserted.
CREATE OR REPLACE FUNCTION ages() returns trigger as
$$
begin
    new.age = extract(years from age(current_date, new.BIRTHDAY));
    return new;
end;
$$
    language plpgsql;

CREATE TRIGGER compute_age
    before INSERT
    ON
        PERSON
    for each row
execute procedure ages();

INSERT INTO PERSON
VALUES ('Asyl', '2002-08-30');

SELECT *
FROM PERSON;

-- c. Adds 12% tax on the price of the inserted item.
CREATE TABLE prod
(
    price    int not null,
    with_tax double precision
);

CREATE FUNCTION tax_calc() returns trigger as
$$
begin
    new.with_tax = new.price * 1.12;
    return new;
end;
$$
    language plpgsql;

CREATE TRIGGER taxes
    before INSERT
    ON prod
    for each row
execute procedure tax_calc();

INSERT INTO prod(price)
values (500);

SELECT *
FROM prod;

-- 4.Create procedures that:
create table employee
(
    id              integer primary key,
    name            varchar,
    date_of_birth   date,
    age             integer,
    salary          integer,
    work_experience integer,
    discount        integer
);
-- a) Increases salary by 10% for every 2 years of work experience and provides
-- 10% discount and after 5 years adds 1% to the discount.

CREATE OR REPLACE PROCEDURE salary1() AS
$$
BEGIN
    UPDATE employee
    SET salary   = salary * (work_experience / 2) * 1.1,
        discount = 10
    WHERE work_experience >= 2;

    UPDATE employee
    SET discount = discount + (work_experience / 5)
    WHERE work_experience >= 5;
    COMMIT;
END;
$$
    language plpgsql;

INSERT INTO employee
VALUES (1, 'Asyl', '2002-08-30', 19, 10000, 5, 0);

CALL salary1();

SELECT *
FROM employee;

-- b) After reaching 40 years, increase salary by 15%. If work experience is more
-- than 8 years, increase salary for 15% of the already increased value for work
-- experience and provide a constant 20% discount.

CREATE OR REPLACE PROCEDURE increase_salary() AS
$$
BEGIN
    UPDATE employee
    SET salary = salary * 1.15
    WHERE age >= 40;

    UPDATE employee
    SET salary   = salary * 1.15,
        discount = 20
    WHERE age >= 40
      AND work_experience >= 8;
    COMMIT;
END;
$$
    language plpgsql;

INSERT INTO employee
VALUES (2, 'Aliya', '2001-10-24', 20, 200000, 7, 0);

call increase_salary();

SELECT *
FROM employee;

-- 5.Produce a CTE that can return the upward recommendation chain for any member.
CREATE TABLE cd.members
(
    memid         integer                NOT NULL,
    surname       character varying(200) NOT NULL,
    firstname     character varying(200) NOT NULL,
    address       character varying(300) NOT NULL,
    zipcode       integer                NOT NULL,
    telephone     character varying(20)  NOT NULL,
    recommendedby integer,
    joindate      timestamp              not null
);

CREATE TABLE cd.facilities
(
    facid              integer                NOT NULL,
    name               character varying(100) NOT NULL,
    membercost         numeric                NOT NULL,
    guestcost          numeric                NOT NULL,
    initialoutlay      numeric                NOT NULL,
    monthlymaintenance numeric                NOT NULL
);

CREATE TABLE cd.bookings
(
    bookid    integer   NOT NULL,
    facid     integer   NOT NULL,
    memid     integer   NOT NULL,
    starttime timestamp NOT NULL,
    slots     integer   NOT NULL
);
