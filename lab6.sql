create table dealer (
    id integer primary key ,
    name varchar(255),
    location varchar(255),
    charge float
);

INSERT INTO dealer (id, name, location, charge) VALUES (101, 'Ерлан', 'Алматы', 0.15);
INSERT INTO dealer (id, name, location, charge) VALUES (102, 'Жасмин', 'Караганда', 0.13);
INSERT INTO dealer (id, name, location, charge) VALUES (105, 'Азамат', 'Нур-Султан', 0.11);
INSERT INTO dealer (id, name, location, charge) VALUES (106, 'Канат', 'Караганда', 0.14);
INSERT INTO dealer (id, name, location, charge) VALUES (107, 'Евгений', 'Атырау', 0.13);
INSERT INTO dealer (id, name, location, charge) VALUES (103, 'Жулдыз', 'Актобе', 0.12);

create table client (
    id integer primary key ,
    name varchar(255),
    city varchar(255),
    priority integer,
    dealer_id integer references dealer(id)
);

INSERT INTO client (id, name, city, priority, dealer_id) VALUES (802, 'Айша', 'Алматы', 100, 101);
INSERT INTO client (id, name, city, priority, dealer_id) VALUES (807, 'Даулет', 'Алматы', 200, 101);
INSERT INTO client (id, name, city, priority, dealer_id) VALUES (805, 'Али', 'Кокшетау', 200, 102);
INSERT INTO client (id, name, city, priority, dealer_id) VALUES (808, 'Ильяс', 'Нур-Султан', 300, 102);
INSERT INTO client (id, name, city, priority, dealer_id) VALUES (804, 'Алия', 'Караганда', 300, 106);
INSERT INTO client (id, name, city, priority, dealer_id) VALUES (809, 'Саша', 'Шымкент', 100, 103);
INSERT INTO client (id, name, city, priority, dealer_id) VALUES (803, 'Маша', 'Семей', 200, 107);
INSERT INTO client (id, name, city, priority, dealer_id) VALUES (801, 'Максат', 'Нур-Султан', null, 105);

create table sell (
    id integer primary key,
    amount float,
    date timestamp,
    client_id integer references client(id),
    dealer_id integer references dealer(id)
);

INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (201, 150.5, '2012-10-05 00:00:00.000000', 805, 102);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (209, 270.65, '2012-09-10 00:00:00.000000', 801, 105);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (202, 65.26, '2012-10-05 00:00:00.000000', 802, 101);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (204, 110.5, '2012-08-17 00:00:00.000000', 809, 103);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (207, 948.5, '2012-09-10 00:00:00.000000', 805, 102);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (205, 2400.6, '2012-07-27 00:00:00.000000', 807, 101);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (208, 5760, '2012-09-10 00:00:00.000000', 802, 101);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (210, 1983.43, '2012-10-10 00:00:00.000000', 804, 106);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (203, 2480.4, '2012-10-10 00:00:00.000000', 809, 103);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (212, 250.45, '2012-06-27 00:00:00.000000', 808, 102);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (211, 75.29, '2012-08-17 00:00:00.000000', 803, 107);
INSERT INTO sell (id, amount, date, client_id, dealer_id) VALUES (213, 3045.6, '2012-04-25 00:00:00.000000', 802, 101);

-- 1)
-- a. combine each row of dealer table with each row of client table
 SELECT * from dealer cross join client;

-- b.find all dealers along with client name, city, grade, sell number, date, and amount
SELECT dealer.name, client.name, client.city, client.priority, sell.id, sell.date, sell.amount
FROM dealer
JOIN client
  ON dealer.id = client.dealer_id
JOIN sell
  ON dealer.id = sell.dealer_id;

-- c.find the dealer and client who belongs to same city
SELECT dealer.id, dealer.name, client.name, client.city
 FROM dealer inner join client ON dealer.id = client.dealer_id
 WHERE client.city = dealer.location;

-- d. find sell id, amount, client name, city those sells where sell amount exists between 100 and 500
SELECT
  sell.id,
  sell.amount,
  client.name,
  client.city
FROM sell
JOIN client
  ON sell.client_id = client.id
WHERE amount > 100 and amount < 500;

-- e. find dealers who works either for one or more client or not yet join under any of the clients
SELECT * FROM dealer
RIGHT OUTER JOIN client
ON dealer.id = client.dealer_id
ORDER BY client.id;

-- f. find the dealers and the clients he service, return client name, city, dealer name, commission.
SELECT client.name,
       client.city,
       dealer.name,
       dealer.charge
FROM dealer
JOIN client
  ON dealer.id = client.dealer_id;

-- g. find client name, client city, dealer, commission those dealers who received a commission from the sell more than 12%
SELECT client.name,
       client.city,
       dealer.name,
       dealer.charge
FROM dealer
JOIN client
  ON dealer.id = client.dealer_id
WHERE charge > 0.12;

-- h. make a report with client name, city, sell id, sell date, sell amount, dealer name and commission to find that either any
-- of the existing clients haven’t made a purchase(sell) or made one or more purchase(sell) by their dealer or by own.
SELECT client.name,
       client.city,
       dealer.name,
       dealer.charge
FROM client
INNER JOIN dealer
    ON dealer.id = client.dealer_id
ORDER BY client.name;

-- 2)
-- a. count the number of unique clients, compute average and total purchase amount of client orders by each date.
-- by unique client
CREATE VIEW NumCLient1(clients, quantity, dates, average_amount, total_amount)
AS SELECT sell.client_id, COUNT(sell.client_id), sell.date, AVG(sell.amount), SUM(sell.amount)
FROM sell
GROUP BY sell.client_id, sell.date;

SELECT * FROM NumCLient1;

-- by date
CREATE VIEW NumCLient2(dates, average_amount, total_amount)
AS SELECT sell.date, AVG(sell.amount), SUM(sell.amount)
FROM sell
GROUP BY sell.date;

SELECT * FROM NumCLient2;

-- b. find top 5 dates with the greatest total sell amount
CREATE VIEW purchaseamount(dates,average_amount,total_amount)
AS SELECT sell.date, AVG(sell.amount), SUM(sell.amount)
FROM sell
GROUP BY sell.date;

SELECT * FROM purchaseamount ORDER BY dates DESC LIMIT 5;

-- c. count the number of sales, compute average and total amount of all sales of each dealer
CREATE VIEW numSales(dealers,avr_sales,total_sales)
AS SELECT sell.dealer_id, AVG(sell.amount), SUM(sell.amount)
FROM sell
GROUP BY sell.dealer_id;

SELECT * FROM numSales;

-- d. compute how much all dealers earned from charge(total sell amount * charge) in each location
CREATE VIEW chargeByCity(cities, total_charge)
AS SELECT dealer.location, SUM(sell.amount * dealer.charge)
FROM dealer, sell
GROUP BY dealer.location;

SELECT * FROM chargeByCity;

-- e. compute number of sales, average and total amount of all sales dealers made in each location
CREATE VIEW salesByCity(cities, num_sales, avr_sales, total_sales)
AS SELECT dealer.location, COUNT(sell.amount), AVG(sell.amount), SUM(sell.amount)
FROM dealer, sell
GROUP BY dealer.location;

SELECT * FROM salesByCity;

-- f. compute number of sales, average and total amount of expenses in each city clients made.
CREATE VIEW expencesByCity(cities, num_exp, avr_exp, total_exp)
AS SELECT client.city, COUNT(client.priority), AVG(client.priority), SUM(client.priority)
FROM client, sell
GROUP BY client.city;

SELECT * FROM expencesByCity;

-- g. find cities where total expenses more than total amount of sales in locations
CREATE VIEW byCondition(cities, total_exp, total_amount)
AS SELECT client.city, COUNT(client.priority), SUM(sell.amount)
FROM client, sell
GROUP BY client.city;

SELECT * FROM byCondition
WHERE total_exp > total_amount;






