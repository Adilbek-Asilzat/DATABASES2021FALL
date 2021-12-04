# DATABASES2021FALL
# Microcenter Electronics Database
I created a database of electronic sales companies "Microcenter Electronics".

This project provides detailed data on the company's products, sales stores, warehouses, customers, express delivery, etc. As expected, they have logical relationships with each other(from 1-line to 125-line). For example, each order is linked to its corresponding customer and courier information:

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

<img width="935" alt="Screen Shot 2021-12-04 at 22 10 46" src="https://user-images.githubusercontent.com/78736705/144716474-bd13a378-276b-41aa-9909-1f47ad313007.png">

Through a few simple equations, we can even obtain the required information according to the conditions, for example, query the consumption information of the past month through the customer’s ID:

select Order_ID, Payment, OrderedDate
from Order_info
where CustomerID = 'a00005'
  and (OrderedDate - CURRENT_DATE) < 31;
  
 <img width="613" alt="Screen Shot 2021-12-04 at 22 12 07" src="https://user-images.githubusercontent.com/78736705/144716523-24856354-45ef-4f3a-8249-9ecdc04b4f22.png">
 

