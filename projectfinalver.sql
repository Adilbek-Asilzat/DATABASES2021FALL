create table Products
(
    ID              varchar(5) Not Null unique,
    Manufacturer    varchar(100),
    ProdType        varchar(100),
    Description     varchar(100),
    Production_Date date,
    Price           integer,
    quantity        integer,
    foreign key (ID) references Order_info (prod_ID)
);

create table Employees
(
    EmpID        varchar(5) primary key not null,
    Workplace    varchar(100),
    Salary       int,
    phone_number varchar(11)
);

create table Shipping
(
    ShippingID      varchar(5) primary key not null,
    ShippingCompany varchar(100),
    OrderID         varchar(6),
    CostumerID      varchar(6),
    Shipping_price  int,
    Storeadd        varchar(100),
    date_arrived    date,
    foreign key (ShippingID) references Order_info (Shipping_ID)
);

create table Warehouses
(
    WareAddress    varchar(100),
    StocksQuantity int,
    Rents          int,
    foreign key (WareAddress) references stores (WarehAddress)
);

create table stores
(
    stAdress     varchar(100),
    CallNumber   varchar(11),
    WarehAddress varchar(100),
    foreign key (stAdress) references Shipping (Storeadd),
    foreign key (stAdress) references Employees (Workplace)
);

create table Customer
(
    CostumerID     varchar(6) primary key,
    Cons_type      varchar(100),
    Name           varchar(100),
    Payment_method varchar(100),
    Orders         varchar(6),
    Cust_contact   varchar(11),
    foreign key (CostumerID) references Order_info (CustomerID)
);

create table Order_info
(
    Order_ID    varchar(6) unique,
    prod_ID     varchar(5),
    Payment     int,
    CustomerID  varchar(6),
    Shipping_ID varchar(5),
    OrderedDate date,
    foreign key (Order_ID) references Shipping (OrderID)
);

create table Sales_data
(
    total_income int,
    total_exp    int,
    Date         date
);

insert into Products
values ('a1234', 'asd', 'smartphone', '64GB 4G', '2020-01-01', 1000, 100000),
       ('b1234', 'bsd', 'notebook', '128GB 2,4GHz', '2021-01-01', 5000, 100000),
       ('c1234', 'csd', 'headphone', 'quick charge', ' 2020-07-01', 800, 100000);

insert into Warehouses
values ('abai56', 3000, 50000),
       ('Tolebi45b', 5000, 80000);

insert into Employees
values ('aa111', 'Jeltoksan90', 20000, 10001),
       ('aa112', 'Jeltoksan90', 20000, 10002),
       ('aa113', 'Panfilov122b', 30000, 10003),
       ('aa114', 'Panfilov122b', 30000, 10004);

insert into stores
values ('Jeltoksan90', '87778899101', 'abai56'),
       ('Panfilov122b', '87778899100', 'Tolebi45b');

insert into Shipping
values ('12345', 'USPS', '000001', 'a00001', 100, 'Jeltoksan90', '2021-10-17'),
       ('12346', 'USPS', '000002', 'a00002', 500, 'Jeltoksan90', '2021-10-15'),
       ('12347', 'fine', '000003', 'a00003', 90, 'Panfilov122b', '2021-10-20');

insert into Shipping
values ('12348', 'USPS', '000004', 'a00004', 90, 'Panfilov122b', '2021-10-22'),
       ('12349', 'fine', '000005', 'a00005', 290, 'Panfilov122b', '2021-10-11');

insert into Customer
values ('a00001', 'VIP', 'Aiaulym', 'card', '000001', '87078374672'),
       ('a00002', 'Reg', 'Zere', 'card', '000002', '87078374673'),
       ('a00003', 'Reg', 'Bota', 'cash', '000003', '87078374674'),
       ('a00004', 'Reg', 'Aman', 'cash', '000004', '87078374675'),
       ('a00005', 'VIP', 'Marmar', 'card', '000005', '87078374676');

insert into Order_info
values ('000001', 'a1234', 1000, 'a00001', '12345', '2021-10-11'),
       ('000002', 'b1234', 5000, 'a00002', '12346', '2021-10-10'),
       ('000003', 'b1234', 5000, 'a00003', '12347', '2021-10-10'),
       ('000004', 'c1234', 800, 'a00004', '12348', '2021-10-18'),
       ('000005', 'c1234', 800, 'a00005', '12349', '2021-10-01');

insert into Sales_data
values (4000, 3000, '2021-10-10'),
       (10000, 1000, '2021-10-11'),
       (2000, 800, '2021-10-12'),
       (12000, 7000, '2021-10-13');

-- Assume the package shipped by USPS with tracking number 12345 is reported to have been destroyed in an accident.
-- Find the contact information for the customer. Also, find the contents of that shipment and create a new shipment
-- of replacement items.
select Cust_contact
from Customer
         inner join Order_info on Customer.CostumerID = Order_info.CustomerID
where Shipping_ID = '12345'
order by Customer.Cust_contact;

update Shipping
set ShippingID     = '12350',
    Shipping_price = 0,
    date_arrived   = current_date + 7
where ShippingID = '12345';

-- Find the customer who has bought the most (by price)
create view second(id, total_price)
as
select Order_info.CustomerID, sum(Order_info.Payment)
from Order_info
         inner join Customer on Customer.CostumerID = Order_info.CustomerID
group by Order_info.CustomerID;

select id
from second
order by total_price DESC
LIMIT 1;

-- Find the top 2 products by dollar-amount sold
create view price(id, total_price)
as
select Order_info.prod_ID, COUNT(*) * Order_info.Payment
from Order_info
group by Order_info.prod_ID, Order_info.Payment;

select *
from price
order by total_price DESC
LIMIT 1;

-- Find the top 2 products by unit sales in the past year.
select prod_ID, COUNT(*)
from Order_info
group by prod_ID
HAVING COUNT(*) > 0
order by count DESC
LIMIT 1;

-- Find those packages that were not delivered within the promised time.
-- promised time: a week
create view deliverDay(orderID, deliverDays, ShippingCompany)
as
select Shipping.OrderID, (Shipping.date_arrived - Order_info.OrderedDate), Shipping.ShippingCompany
from Shipping
         inner join Order_info on Shipping.OrderID = Order_info.Order_ID
group by Shipping.OrderID, Order_info.OrderedDate, Shipping.date_arrived, Shipping.ShippingCompany;

select *
from deliverDay
where deliverDays > 7
order by deliverDays desc;

-- Generate the bill for each customer for the past month.
select Order_ID, Payment, OrderedDate
from Order_info
where CustomerID = 'a00001'
  and (OrderedDate - CURRENT_DATE) < 31;

select Order_ID, Payment, OrderedDate
from Order_info
where CustomerID = 'a00002'
  and (OrderedDate - CURRENT_DATE) < 31;

select Order_ID, Payment, OrderedDate
from Order_info
where CustomerID = 'a00003'
  and (OrderedDate - CURRENT_DATE) < 31;

select Order_ID, Payment, OrderedDate
from Order_info
where CustomerID = 'a00004'
  and (OrderedDate - CURRENT_DATE) < 31;

select Order_ID, Payment, OrderedDate
from Order_info
where CustomerID = 'a00005'
  and (OrderedDate - CURRENT_DATE) < 31;
