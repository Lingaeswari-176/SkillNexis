-- WEEK 2: SQL FOR DATA ANALYSIS
-- Project: Customer Orders Analysis

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE OrderItems (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Insert sample customers
INSERT INTO Customers VALUES
(1, 'Aarav Sharma', 'Chennai', 'India'),
(2, 'Maya Patel', 'Mumbai', 'India'),
(3, 'Daniel Smith', 'London', 'UK'),
(4, 'Sofia Garcia', 'Madrid', 'Spain'),
(5, 'Noah Wilson', 'New York', 'USA');

-- Insert sample orders
INSERT INTO Orders VALUES
(101, 1, '2025-01-10', 'Delivered'),
(102, 2, '2025-01-15', 'Delivered'),
(103, 1, '2025-02-02', 'Delivered'),
(104, 3, '2025-02-18', 'Cancelled'),
(105, 4, '2025-03-04', 'Delivered'),
(106, 5, '2025-03-12', 'Processing');

-- Insert order items
INSERT INTO OrderItems VALUES
(1, 101, 'Laptop', 'Electronics', 1, 650.00),
(2, 101, 'Mouse', 'Accessories', 2, 20.00),
(3, 102, 'Chair', 'Furniture', 1, 180.00),
(4, 103, 'Headphones', 'Electronics', 2, 75.00),
(5, 104, 'Monitor', 'Electronics', 1, 220.00),
(6, 105, 'Desk', 'Furniture', 1, 300.00),
(7, 106, 'Laptop', 'Electronics', 2, 650.00);

-- 1. SELECT: Display all customers
SELECT * FROM Customers;

-- 2. WHERE: Customers from India
SELECT customer_name, city
FROM Customers
WHERE country = 'India';

-- 3. ORDER BY: Sort customers alphabetically
SELECT *
FROM Customers
ORDER BY customer_name ASC;

-- 4. COUNT: Total number of orders
SELECT COUNT(*) AS total_orders
FROM Orders;

-- 5. GROUP BY: Count orders by status
SELECT status, COUNT(*) AS order_count
FROM Orders
GROUP BY status
ORDER BY order_count DESC;

-- 6. Calculate the value of each order
SELECT order_id,
       SUM(quantity * unit_price) AS order_value
FROM OrderItems
GROUP BY order_id
ORDER BY order_value DESC;

-- 7. Find the top customers by spending
SELECT c.customer_name,
       SUM(oi.quantity * oi.unit_price) AS total_spending
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC
LIMIT 5;

-- 8. Calculate average order value for delivered orders
SELECT ROUND(AVG(order_value), 2) AS average_order_value
FROM (
    SELECT o.order_id,
           SUM(oi.quantity * oi.unit_price) AS order_value
    FROM Orders o
    JOIN OrderItems oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY o.order_id
) AS order_totals;

-- 9. INNER JOIN: Customer order details
SELECT c.customer_name, o.order_id,
       o.order_date, o.status
FROM Customers c
INNER JOIN Orders o
ON c.customer_id = o.customer_id;

-- 10. LEFT JOIN: Count orders for every customer
SELECT c.customer_name,
       COUNT(o.order_id) AS number_of_orders
FROM Customers c
LEFT JOIN Orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 11. Subquery: Find orders above average order value
SELECT order_id, order_value
FROM (
    SELECT order_id,
           SUM(quantity * unit_price) AS order_value
    FROM OrderItems
    GROUP BY order_id
) AS totals
WHERE order_value > (
    SELECT AVG(order_value)
    FROM (
        SELECT SUM(quantity * unit_price) AS order_value
        FROM OrderItems
        GROUP BY order_id
    ) AS averages
);

-- 12. CASE: Classify orders by value
SELECT order_id, order_value,
       CASE
           WHEN order_value >= 500 THEN 'High Value'
           WHEN order_value >= 200 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS order_category
FROM (
    SELECT order_id,
           SUM(quantity * unit_price) AS order_value
    FROM OrderItems
    GROUP BY order_id
) AS totals;

-- 13. SUM: Revenue by category
SELECT oi.category,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM OrderItems oi
JOIN Orders o ON oi.order_id = o.order_id
WHERE o.status = 'Delivered'
GROUP BY oi.category
ORDER BY revenue DESC;

-- 14. WHERE: Orders from March 2025 onward
SELECT *
FROM Orders
WHERE order_date >= '2025-03-01'
ORDER BY order_date;

-- 15. AVG: Average product price by category
SELECT category,
       ROUND(AVG(unit_price), 2) AS average_price
FROM OrderItems
GROUP BY category
ORDER BY average_price DESC;
