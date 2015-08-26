# Use this file to import the sales information into the the database.
require "pry"
require "csv"
require "pg"

def db_connection
  begin
    connection = PG.connect(dbname: "korning-fall")
    yield(connection)
  ensure
    connection.close
  end
end

sales_data = CSV.readlines('sales.csv', headers: true)

sales_data.each do |row|
  db_connection do |conn|

    product_match = conn.exec_params("SELECT * FROM product WHERE product_name = $1", [row["product_name"]] )
    if product_match.count < 1
     conn.exec_params("INSERT INTO product (product_name) VALUES ($1)", [row["product_name"]])
    end

    frequency_match = conn.exec_params("SELECT * FROM frequency WHERE invoice_frequency = $1", [row["invoice_frequency"]] )
    if frequency_match.count < 1
     conn.exec_params("INSERT INTO frequency (invoice_frequency) VALUES ($1)", [row["invoice_frequency"]])
    end

    employee_data = row["employee"].delete("()").split(" ")
    email_match = conn.exec_params("SELECT * FROM employee WHERE email = $1", [employee_data[2]])
    if email_match.count < 1
     conn.exec_params("INSERT INTO employee (first_name, last_name, email) VALUES ($1, $2, $3)", employee_data)
    end

    customer_data = row["customer_and_account_no"].delete("()").split(" ")
    act_no_match = conn.exec_params("SELECT * FROM customer WHERE act_no = $1", [customer_data[1]])
    if act_no_match.count < 1
     conn.exec_params("INSERT INTO customer (company_name, act_no) VALUES ($1, $2)", customer_data)
    end

    frequency_id = conn.exec_params("SELECT id FROM frequency WHERE invoice_frequency = $1", [row["invoice_frequency"]])
    frequency_id = frequency_id[0]["id"]

    product_id = conn.exec_params("SELECT id FROM product WHERE product_name = $1", [row["product_name"]])
    product_id = product_id[0]["id"]

    customer_id = conn.exec_params("SELECT id FROM customer WHERE company_name = $1", [customer_data[0]])
    customer_id = customer_id[0]["id"]

    employee_id = conn.exec_params("SELECT id FROM employee WHERE first_name = $1", [employee_data[0]])
    employee_id = employee_id[0]["id"]

    conn.exec_params("INSERT INTO sales (
      invoice_no,
      sale_date,
      sale_amount,
      units_sold,
      frequency_id,
      product_id,
      employee_id,
      customer_id
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
    [
      row["invoice_no"],
      row["sale_date"],
      row["sale_amount"],
      row["units_sold"],
      frequency_id,
      product_id,
      employee_id,
      customer_id
    ]
    )
  end
end
