create table customers (
    id integer primary key,
    name varchar(255),
    birth_date date
);

create table accounts(
    account_id varchar(40) primary key ,
    customer_id integer references customers(id),
    currency varchar(3),
    balance float,
    "limit" float
);

create table transactions (
    id serial primary key,
    date timestamp,
    src_account varchar(40) references accounts(account_id),
    dst_account varchar(40) references accounts(account_id),
    amount float,
    status varchar(20)
);

INSERT INTO customers VALUES (201, 'John', '2021-11-05');
INSERT INTO customers VALUES (202, 'Anny', '2021-11-02');
INSERT INTO customers VALUES (203, 'Rick', '2021-11-24');

INSERT INTO accounts VALUES ('NT10204', 201, 'KZT', 1000, null);
INSERT INTO accounts VALUES ('AB10203', 202, 'USD', 100, 0);
INSERT INTO accounts VALUES ('DK12000', 203, 'EUR', 500, 200);
INSERT INTO accounts VALUES ('NK90123', 201, 'USD', 400, 0);
INSERT INTO accounts VALUES ('RS88012', 203, 'KZT', 5000, -100);

INSERT INTO transactions VALUES (1, '2021-11-05 18:00:34.000000', 'NT10204', 'RS88012', 1000, 'commited');
INSERT INTO transactions VALUES (2, '2021-11-05 18:01:19.000000', 'NK90123', 'AB10203', 500, 'rollback');
INSERT INTO transactions VALUES (3, '2021-06-05 18:02:45.000000', 'RS88012', 'NT10204', 400, 'init');

-- 2.
CREATE ROLE accountant;
CREATE ROLE administrator;
CREATE ROLE support;

GRANT ALL ON customers TO administrator;
GRANT SELECT ON accounts TO accountant;
GRANT INSERT, UPDATE, DELETE ON transactions TO support;

CREATE USER asyl;
CREATE USER anel;
CREATE USER ayan;

GRANT administrator TO asyl;
GRANT accountant TO anel;
GRANT support TO ayan;

-- revoke some privilege from particular user
REVOKE DELETE ON transactions FROM ayan;

-- 3.
ALTER TABLE accounts
ALTER COLUMN birth_date SET NOT NULL;

-- 5. Create indexes:
-- index so that each customer can only have one account of one currency
SELECT * FROM accounts JOIN customers c ON accounts.customer_id = c.id;

CREATE UNIQUE INDEX index1
ON accounts(currency);

--index for searching transactions by currency and balance
SELECT currency, balance FROM accounts JOIN transactions ON accounts.account_id = transactions.dst_account OR accounts.account_id = transactions.src_account;
CREATE INDEX index3
ON accounts(currency,balance);

-- 6.
BEGIN;
UPDATE accounts SET balance = balance - 100.00 WHERE account_id = 'AB10203';
SAVEPOINT sav;
UPDATE accounts SET balance = balance + 100.00 WHERE account_id = 'NT10204';
-- if in source account balance becomes below limit, then make rollback
ROLLBACK TO sav;
UPDATE accounts SET balance = balance + 100.00 WHERE account_id = 'AB10203';
COMMIT;




