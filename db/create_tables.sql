CREATE TABLE address (
  id int(11) NOT NULL AUTO_INCREMENT,
  country enum('india') DEFAULT NULL,
  state enum('Andhra Pradesh','Arunachal Pradesh','Assam','Bihar','Chhattisgarh','Goa','Gujarat','Haryana','Himachal Pradesh','Jharkhand','Karnataka
','Kerala','Madhya Pradesh','Maharashtra','Manipur','Meghalaya','Mizoram','Nagaland','Odisha','Punjab','Rajasthan','Sikkim','Tamil Nadu','Tripura','Ut
tarakhand','Uttar Pradesh','West Bengal') DEFAULT NULL,
  city varchar(100) DEFAULT NULL,
  zipcode int(6) NOT NULL,
  street varchar(100) NOT NULL,
  building varchar(12) DEFAULT NULL,
  room_no int(11) DEFAULT NULL,
  UNIQUE KEY id (id)
);

CREATE TABLE category (
  cat_id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(100) NOT NULL,
  parent int(11) DEFAULT NULL,
  PRIMARY KEY (cat_id)
);

CREATE TABLE books (
  ISBN varchar(20) NOT NULL,
  Title varchar(100) DEFAULT NULL,
  Authors varchar(100) DEFAULT NULL,
  Publisher varchar(100) DEFAULT NULL,
  YOP date DEFAULT NULL,
  Category_id int(11) DEFAULT NULL,
  Available_copies int(11) DEFAULT NULL,
  Price double DEFAULT NULL,
  Format enum('softcover','hardcover','paperback') DEFAULT NULL,
  Keywords varchar(100) DEFAULT NULL,
  Subject varchar(50) DEFAULT NULL,
  image_loc varchar(300) DEFAULT NULL,
  description varchar(3000) DEFAULT NULL,
  PRIMARY KEY (ISBN),
  KEY Category_id (Category_id),
  FULLTEXT KEY Title (Title,Subject,description),
  FULLTEXT KEY Title_2 (Title,Subject,description),
  FULLTEXT KEY Title_3 (Title),
  FULLTEXT KEY Title_4 (Title,Subject),
  FULLTEXT KEY Title_5 (Title),
  CONSTRAINT books_ibfk_1 FOREIGN KEY (Category_id) REFERENCES category (cat_id)
);

CREATE TABLE book_item (
  ISBN char(14) DEFAULT NULL,
  quantity int(11) DEFAULT '0',
  item_id char(20) NOT NULL,
  price double(4,2) DEFAULT NULL,
  total double(5,2) DEFAULT NULL,
  PRIMARY KEY (item_id),
  KEY ISBN (ISBN),
  CONSTRAINT book_item_ibfk_1 FOREIGN KEY (ISBN) REFERENCES books (ISBN) ON DELETE CASCADE
);

CREATE TABLE customer (
  Login_id char(20) NOT NULL,
  Name varchar(50) DEFAULT NULL,
  Password varchar(16) DEFAULT NULL,
  cc_no char(16) DEFAULT NULL,
  Phone_num text,
  address int(11) DEFAULT NULL,
  PRIMARY KEY (Login_id)
);


CREATE TABLE order_book (
  ISBN char(14) DEFAULT NULL,
  Copies_ordered int(11) DEFAULT NULL,
  Order_id int(11) NOT NULL,
  KEY ISBN (ISBN),
  KEY Order_id (Order_id),
  CONSTRAINT order_book_ibfk_1 FOREIGN KEY (ISBN) REFERENCES books (ISBN) ON DELETE CASCADE,
  CONSTRAINT order_book_ibfk_2 FOREIGN KEY (Order_id) REFERENCES orders (Order_id) ON DELETE CASCADE
);

CREATE TABLE shipment (
  id int(11) NOT NULL AUTO_INCREMENT,
  address_id int(11) NOT NULL,
  type enum('Home Delivery','Office Delivery','Pick up at location') DEFAULT NULL,
  promised_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  delivery_date timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  user_id varchar(20) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY address_id (address_id),
  CONSTRAINT shipment_ibfk_1 FOREIGN KEY (address_id) REFERENCES address (id)
);

CREATE TABLE order_detail (
  ISBN char(20) DEFAULT NULL,
  item_id varchar(10) NOT NULL,
  Order_id int(11) NOT NULL,
  total double(5,2) DEFAULT NULL,
  discount int(11) DEFAULT '0',
  shipment_id int(11) NOT NULL,
  KEY item_id (item_id),
  KEY ISBN (ISBN),
  KEY Order_id (Order_id),
  KEY shipment_id (shipment_id),
  CONSTRAINT order_detail_ibfk_1 FOREIGN KEY (item_id) REFERENCES book_item (item_id),
  CONSTRAINT order_detail_ibfk_2 FOREIGN KEY (ISBN) REFERENCES books (ISBN) ON DELETE CASCADE,
  CONSTRAINT order_detail_ibfk_3 FOREIGN KEY (Order_id) REFERENCES orders (Order_id) ON DELETE CASCADE,
  CONSTRAINT order_detail_ibfk_4 FOREIGN KEY (shipment_id) REFERENCES shipment (id)
);

CREATE TABLE orders (
  Order_id int(11) NOT NULL AUTO_INCREMENT,
  timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  login_id char(20) DEFAULT NULL,
  Status enum('In transit to Customer','Processing Payment','Delivered to Customer','In Warehouse') DEFAULT NULL,
  PRIMARY KEY (Order_id),
  KEY login_id (login_id),
  CONSTRAINT orders_ibfk_1 FOREIGN KEY (login_id) REFERENCES customer (Login_id) ON DELETE CASCADE
);


CREATE TABLE uuid_table (
  id char(36) DEFAULT NULL,
  UNIQUE KEY index1 (id)
);


CREATE TABLE cart (
  cart_id varchar(10) NOT NULL,
  user_id char(20) NOT NULL,
  total double DEFAULT '0',
  count int(11) NOT NULL DEFAULT '0',
  item_id char(20) DEFAULT NULL,
  KEY user_id (user_id),
  CONSTRAINT cart_ibfk_2 FOREIGN KEY (user_id) REFERENCES customer (Login_id)
);

CREATE TABLE feedback (
  Login_id char(20) NOT NULL,
  ISBN char(14) NOT NULL,
  Score int(11) DEFAULT NULL,
  Date date DEFAULT NULL,
  Short_text varchar(140) DEFAULT NULL,
  PRIMARY KEY (Login_id,ISBN),
  KEY ISBN (ISBN),
  CONSTRAINT feedback_ibfk_1 FOREIGN KEY (Login_id) REFERENCES customer (Login_id),
  CONSTRAINT feedback_ibfk_2 FOREIGN KEY (ISBN) REFERENCES books (ISBN)
);


CREATE TABLE rating (
  Score int(11) DEFAULT NULL,
  Rater_id char(10) NOT NULL,
  Ratee_id char(10) NOT NULL,
  ISBN char(14) NOT NULL,
  comments varchar(200) DEFAULT NULL,
  PRIMARY KEY (ISBN,Rater_id,Ratee_id),
  KEY Rater_id (Rater_id),
  KEY Ratee_id (Ratee_id),
  CONSTRAINT rating_ibfk_1 FOREIGN KEY (Rater_id) REFERENCES customer (Login_id),
  CONSTRAINT rating_ibfk_2 FOREIGN KEY (Ratee_id) REFERENCES feedback (Login_id)
);


CREATE TABLE wishlist (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(20) DEFAULT NULL,
  isbn varchar(20) DEFAULT NULL,
  user_id char(20) DEFAULT NULL,
  wishlist_id varchar(255) NOT NULL,
  PRIMARY KEY (id),
  KEY fk_isbn (isbn),
  CONSTRAINT wishlist_ibfk_1 FOREIGN KEY (isbn) REFERENCES books (ISBN)
);

