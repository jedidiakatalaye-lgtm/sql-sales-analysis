CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  name TEXT, country TEXT, signup_date DATE
);
CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  name TEXT, category TEXT, price REAL
);
CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER REFERENCES customers(customer_id),
  order_date DATE,
  status TEXT CHECK (status IN ('completed','cancelled','returned'))
);
CREATE TABLE order_items (
  item_id INTEGER PRIMARY KEY,
  order_id INTEGER REFERENCES orders(order_id),
  product_id INTEGER REFERENCES products(product_id),
  quantity INTEGER, discount REAL
);
