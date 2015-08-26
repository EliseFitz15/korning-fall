DROP TABLE employee, customer, product, frequency, sales;

CREATE TABLE employee(
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  email VARCHAR(255)
);

CREATE TABLE customer(
  id SERIAL PRIMARY KEY,
  company_name VARCHAR(255),
  act_no VARCHAR(255)
);

CREATE TABLE product(
  id SERIAL PRIMARY KEY,
  product_name VARCHAR(255)
);

CREATE TABLE frequency(
  id SERIAL PRIMARY KEY,
  invoice_frequency VARCHAR(255)
);

CREATE TABLE sales(
  id SERIAL PRIMARY KEY,
  invoice_no INT,
  units_sold INT,
  sale_date DATE,
  sale_amount MONEY,
  employee_id INT REFERENCES employee(id),
  customer_id INT REFERENCES customer(id),
  product_id INT REFERENCES product(id),
  frequency_id INT REFERENCES frequency(id)
);
