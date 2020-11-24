CREATE TABLE IF NOT EXISTS Customer ( 
    ID INT NOT NULL AUTO_INCREMENT, 
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
        OR ((bus_cat IS NOT NULL) 
        AND (bus_income IS NOT NULL) 
        AND (bus_size IS NOT NULL) 
        AND (gender IS NULL) 
        AND (age IS NULL) 
        AND (personal_income IS NULL))) 
        AND ((customer_type = 'personal') 
        OR ((bus_cat IS NULL) 
        AND (bus_income IS NULL) 
        AND (bus_size IS NULL)))), #makes sure business info is supplied & individual info is not supplied if customer_type is business; makes sure business info is NOT supplied if customer_type is personal but does not require persoanl info 
       CONSTRAINT unique_email UNIQUE(email) 
); 
  
CREATE TABLE IF NOT EXISTS Book ( 
    ISBN VARCHAR(13) NOT NULL, 
    title VARCHAR(30), 
    author VARCHAR(30), 
    pages INT, 
    category VARCHAR(30), 
         stock_amt INT, 
    price FLOAT4, 
    PRIMARY KEY (ISBN), 
    CONSTRAINT unique_ISBN UNIQUE(ISBN) 
); 
  
CREATE TABLE IF NOT EXISTS Employee ( 
    emp_ID INT NOT NULL AUTO_INCREMENT, 
    name VARCHAR(30), 
    street_address VARCHAR(30), 
    state VARCHAR(2), 
    zip VARCHAR(5), 
    email VARCHAR(20), 
    title ENUM('salesperson', 'senior salesperson', 'manager', 'regional manager'), 
    salary INTEGER, 
    PRIMARY KEY (emp_ID) 
    CONSTRAINT unique_ID UNIQUE(ID),   
    CONSTRAINT unique_email UNIQUE(email) 
 
); 
  
CREATE TABLE IF NOT EXISTS Region ( 
    ID INT NOT NULL AUTO_INCREMENT, 
    region_name VARCHAR(20), 
    PRIMARY KEY (ID), 
    manager VARCHAR(10), 
    FOREIGN KEY (manager) 
        REFERENCES Employee (emp_ID) 
); 
CREATE TABLE IF NOT EXISTS Store ( 
    ID INT NOT NULL AUTO_INCREMENT, 
    street_address VARCHAR(30), 
    state VARCHAR(2), 
    zip VARCHAR(5), 
    number_employees INT, 
    PRIMARY KEY (ID), 
    manager VARCHAR(10), 
    region VARCHAR(10), 
    FOREIGN KEY (manager) 
        REFERENCES Employee (emp_ID), 
    FOREIGN KEY (region) 
        REFERENCES Region (ID) 
); 
  
CREATE TABLE IF NOT EXISTS Cart ( 
    customer_ID VARCHAR(10), 
    FOREIGN KEY (customer_ID) 
        REFERENCES Customer (ID) 
); 
  
CREATE TABLE IF NOT EXISTS Cart_item ( 
    cart_ID VARCHAR(10), 
    product_ID VARCHAR(13), 
   quantity INT CHECK (quantity <= (SELECT stock_amt FROM Book where product_ID = Book.ISBN) ),
    FOREIGN KEY (cart_ID) 
        REFERENCES Cart (ID), 
    FOREIGN KEY (product_ID) 
        REFERENCES Book (ISBN) 
); 
  
# Cart_item keeps track of the items added to a customer's cart. Setup is 
# | CART BOOK BELONGS IN | ID OF BOOK | NUMBER OF BOOKS IN CART 
  
CREATE TABLE IF NOT EXISTS Customer_order ( 
    order_number INT NOT NULL AUTO_INCREMENT, 
    order_date DATE, 
    PRIMARY KEY (order_number, order_date), 
    customer_ID VARCHAR(10), 
    FOREIGN KEY (customer_ID) 
        REFERENCES Customer (ID) 
); 
  
CREATE TABLE IF NOT EXISTS Sale ( 
    order_date DATE, 
    price FLOAT4, 
    order_ID VARCHAR(10), 
    customer_ID VARCHAR(10), 
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
    order_ID VARCHAR(10), 
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
insert into Order_item values (order_ID, product_ID, quantity); 
 
create trigger delete_cart_item
after INSERT on Sale
AS
    DELETE FROM Cart_item
    WHERE Sale.customer_ID = Cart_item.cart_ID;
  
create trigger book_stock_decrease 
after INSERT on Order_item 
for each row  
update Book set stock_amt = stock_amt - Order_item.quantity where ISBN = Order_item.product_ID; 
