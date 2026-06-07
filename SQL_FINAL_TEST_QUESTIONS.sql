==================================================
-- Q1. List top 5 customers by total order amount.
-- Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.
==================================================

select top 5
    c.customerid,
    c.name as customername,
    sum(so.totalamount) as totalspent
from customer c
join salesorder so 
    on c.customerid = so.customerid
group by c.customerid, c.name
order by totalspent desc;

==================================================
-- Q2. Find the number of products supplied by each supplier.
-- Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.
==================================================

select 
    s.supplierid,
    s.name as suppliername,
    count(p.productid) as productcount
from supplier s
join purchaseorder p1
    on s.supplierid = p1.supplierid
join purchaseorderdetail p2
    on p1.orderid = p2.orderid
join product p 
    on p2.productid = p.productid
group by s.supplierid, s.name
having count(p.productid) > 10
order by productcount desc;

==================================================
-- Q3. Identify products that have been ordered but never returned.
-- Show ProductID, ProductName, and total order quantity.
==================================================

select
    p.productid,
    p.name as productname,
    sum(s1.quantity) as totalorderquantity
from product p
join salesorderdetail s1
    on p.productid = s1.productid
left join returndetail r1
    on p.productid = r1.productid
where r1.productid is null
group by p.productid, p.name
order by totalorderquantity desc

==================================================
-- Q4. For each category, find the most expensive product.
-- Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.
==================================================

select
    c1.categoryid, c1.name as categoryname, p.name as productname, p.price
from product p
join category c1
    on p.categoryid = c1.categoryid
where p.price = (
    select max(p2.price)
    from product p2
    where p2.categoryid = p.categoryid
)
order by c1.categoryid

==================================================
-- Q5. List all sales orders with customer name, product name, category, and supplier.
-- For each sales order, display:
-- OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.
==================================================

select
    s.orderid, c.name as customername, p.name as productname, c2.name as categoryname,
    s2.name as suppliername,
    s3.quantity
from salesorder s
join customer c
    on s.customerid = c.customerid
join salesorderdetail s3
    on s.orderid = s3.orderid
join product p
    on s3.productid = p.productid
join category c2
    on p.categoryid = c2.categoryid
join purchaseorderdetail p2
    on p.productid = p2.productid
join purchaseorder p3
    on p2.orderid = p3.orderid
join supplier s2
    on p3.supplierid = s2.supplierid
order by s.orderid

==================================================
-- Q6. Find all shipments with details of warehouse, manager, and products shipped.
-- Display:
-- ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.
==================================================

select
    s.shipmentid,
    l.name as warehousename,
    e.name as managername,
    p.name as productname,
    s2.quantity as quantityshipped,
    s.trackingnumber
from shipment s
join warehouse w
    on s.warehouseid = w.warehouseid
join employee e
    on w.managerid = e.employeeid
join location l
    on w.locationid = l.locationid
join shipmentdetail s2
    on s.shipmentid = s2.shipmentid
join product p
    on s2.productid = p.productid
order by s.shipmentid

==================================================
-- Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.
==================================================

select *
from (
    select
        c.customerid, c.name as customername, s.orderid, s.totalamount,
        rank() over (
            partition by c.customerid
            order by s.totalamount desc
        ) as orderrank
    from customer c
    join salesorder s
        on c.customerid = s.customerid
) ranked_orders
where orderrank <= 3
order by customerid, orderrank;

==================================================
-- Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.
==================================================

select
    p.productid, p.name as productname, s.orderid, s.orderdate, sd.quantity,
    lag(sd.quantity) over (
        partition by p.productid
        order by s.orderdate
    ) as prevquantity,
    lead(sd.quantity) over (
        partition by p.productid
        order by s.orderdate
    ) as nextquantity
from salesorderdetail sd
join salesorder s
    on sd.orderid = s.orderid
join product p
    on sd.productid = p.productid
order by p.productid, s.orderdate;

==================================================
-- Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
-- CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.
==================================================

create view view_Customer_Order_Summary as
select
    c.CustomerID,
    c.Name AS CustomerName,
    count(so.OrderID) as TotalOrders,
    coalesce(SUM(so.TotalAmount), 0) as TotalAmountSpent,
    max(so.OrderDate) as LastOrderDate
from customer c
left join salesorder so
    on c.CustomerID = so.CustomerID
group by c.CustomerID, c.Name

select * from view_Customer_Order_Summary

==================================================
-- Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total sales amount for all products supplied by that supplier.
==================================================
 
SELECT
    s.SupplierID,
    s.Name AS SupplierName,
    SUM(sod.Quantity * p.Price) AS TotalSales
FROM Supplier s
JOIN PurchaseOrder p
    ON s.SupplierID = p.SupplierID
JOIN PurchaseOrderDetail p2
    ON p.OrderID = p2.OrderID
JOIN Product p
    ON p2.ProductID = p.ProductID
JOIN SalesOrderDetail s2
        ON p.ProductID = s2.ProductID