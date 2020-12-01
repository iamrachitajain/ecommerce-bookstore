CREATE DATABASE Project;

CREATE TABLE IF NOT EXISTS Customer ( 
    ID INT NOT NULL, #AUTO_INCREMENT, 
    name VARCHAR(30), 
    email VARCHAR(100), 
    street_address VARCHAR(30), 
    state VARCHAR(2), 
    zip VARCHAR(5), 
    customer_type ENUM('personal', 'business'), 
    bus_cat SET('retail', 'nonprofit', 'education', 'other'), 
    bus_income INT, 
    bus_size INT, 
    gender SET('female', 'male', 'nonbinary', 'other'), 
    age INT, 
    personal_income INT, 
    PRIMARY KEY (ID), 
    CONSTRAINT check_business_info CHECK (((customer_type = 'business') 
       AND ((bus_cat IS NOT NULL) 
	   AND (bus_income IS NOT NULL) 
       AND (bus_size IS NOT NULL) 
       AND (gender IS NULL) 
       AND (age IS NULL) 
       AND (personal_income IS NULL))) 
       OR ((customer_type = 'personal') 
       AND ((bus_cat IS NULL) 
	   AND (bus_income IS NULL) 
	   AND customer (bus_size IS NULL)))), #KEEPS BUSINESS/PERSONAL SEPARATE
       CONSTRAINT unique_email UNIQUE(email));

CREATE TABLE IF NOT EXISTS Book ( 
    ISBN VARCHAR(13) NOT NULL, 
    title VARCHAR(100), 
    author VARCHAR(30), 
    pages INT, 
    category VARCHAR(30), 
         stock_amt INT, 
    price FLOAT4, 
    PRIMARY KEY (ISBN), 
    CONSTRAINT unique_ISBN UNIQUE(ISBN) 
); 

ALTER TABLE Book ADD img VARCHAR(50);
ALTER TABLE Book DROP img;
ALTER TABLE Book ADD img VARCHAR(120);
  
CREATE TABLE IF NOT EXISTS Employee ( 
    ID INT NOT NULL AUTO_INCREMENT, 
    name VARCHAR(30), 
    street_address VARCHAR(30), 
    state VARCHAR(2), 
    zip VARCHAR(5), 
    email VARCHAR(20), 
    title ENUM('salesperson', 'senior salesperson', 'manager', 'regional manager'), 
    salary INTEGER, 
    PRIMARY KEY (ID),
    CONSTRAINT unique_ID UNIQUE(ID),   
    CONSTRAINT unique_email UNIQUE(email) 
); 
  
CREATE TABLE IF NOT EXISTS Region ( 
    ID INT NOT NULL AUTO_INCREMENT, 
    region_name VARCHAR(20), 
    PRIMARY KEY (ID), 
    manager INT, 
    FOREIGN KEY (manager) 
        REFERENCES Employee (ID) 
); 
CREATE TABLE IF NOT EXISTS Store ( 
    ID INT NOT NULL AUTO_INCREMENT, 
    street_address VARCHAR(30), 
    state VARCHAR(2), 
    zip VARCHAR(5), 
    number_employees INT, 
    PRIMARY KEY (ID), 
    manager INT, 
    region INT, 
    FOREIGN KEY (manager) 
        REFERENCES Employee (ID), 
    FOREIGN KEY (region) 
        REFERENCES Region (ID) 
); 
  
CREATE TABLE IF NOT EXISTS Cart ( 
    customer_ID INT, 
    FOREIGN KEY (customer_ID) 
        REFERENCES Customer (ID) 
);   
CREATE TABLE IF NOT EXISTS Cart_item ( 
    cart_ID INT, 
    product_ID VARCHAR(13), 
   quantity INT, #CHECK (quantity <= (SELECT stock_amt FROM Book where product_ID = Book.ISBN) ) #needs fixed
    FOREIGN KEY (cart_ID) 
        REFERENCES Cart (customer_ID), 
    FOREIGN KEY (product_ID) 
        REFERENCES Book (ISBN) 
); 
  
# Cart_item keeps track of the items added to a customer's cart. Setup is 
# | CART BOOK BELONGS IN | ID OF BOOK | NUMBER OF BOOKS IN CART 
  
CREATE TABLE IF NOT EXISTS Customer_order ( 
    order_number INT NOT NULL AUTO_INCREMENT, 
    order_date DATE, 
    PRIMARY KEY (order_number, order_date), 
    customer_ID INT, 
    FOREIGN KEY (customer_ID) 
        REFERENCES Customer (ID) 
); 
  
CREATE TABLE IF NOT EXISTS Sale ( 
    order_date DATE, 
    price FLOAT4, 
    order_ID INT, 
    customer_ID INT, 
    product_ID VARCHAR(13), 
    quantity INT, 
    FOREIGN KEY (product_ID) 
        REFERENCES Cart_item (product_ID), 
    FOREIGN KEY (order_ID) 
        REFERENCES Customer_order (order_number), 
    FOREIGN KEY (customer_ID) 
        REFERENCES Customer (ID) 
); 
  
# A Sale tuple is created for each tuple in Cart_item per cart. Cart_items in the same cart are assigned to the same order_ID.  
  
CREATE TABLE IF NOT EXISTS Order_item ( 
    order_ID INT, 
    product_ID VARCHAR(13), 
    quantity INT,  
    FOREIGN KEY (order_ID) 
        REFERENCES Customer_order (order_number), 
    FOREIGN KEY (product_ID) 
        REFERENCES Cart_item (product_ID) 
); 
  
create trigger create_cart
after INSERT on Customer 
for each row 
insert into Cart values (ID);  
 
create trigger create_order 
after INSERT on Sale 
for each row 
insert into Customer_order values (order_ID, order_date, customer_ID);  
  
create trigger create_order_item 
after INSERT on Sale 
for each row 
insert into order_item values (order_ID, product_ID, quantity); 
 
create trigger delete_cart_item
after INSERT on Sale
for each row
    DELETE FROM Cart_item
    WHERE Sale.customer_ID = Cart_item.cart_ID;
  
create trigger book_stock_decrease 
after INSERT on Order_item 
for each row  
update Book set stock_amt = stock_amt - Order_item.quantity where ISBN = Order_item.pregionroduct_ID; 
