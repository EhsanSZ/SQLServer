

USE WideWorldImporters;
GO

/*
exist (XQuery)
*/

DROP TABLE IF EXISTS Sales.CustomerOrderSummary;
GO

CREATE TABLE Sales.CustomerOrderSummary
	(
		ID INT NOT NULL IDENTITY,
		CustomerID INT NOT NULL,
		OrderSummary XML
	);
GO

INSERT INTO Sales.CustomerOrderSummary (CustomerID,OrderSummary)
SELECT 
	CustomerID,
	(SELECT
		CustomerName 'OrderHeader/CustomerName',
		OrderDate 'OrderHeader/OrderDate',
		OrderID 'OrderHeader/OrderID',
		(SELECT
			LineItems2.StockItemID '@ProductID',
			StockItems.StockItemName '@ProductName',
			LineItems2.UnitPrice '@Price',
			Quantity '@Qty'
		 FROM Sales.OrderLines AS LineItems2
		 INNER JOIN Warehouse.StockItems AS StockItems
			ON LineItems2.StockItemID = StockItems.StockItemID
			WHERE LineItems2.OrderID = Base.OrderID
		 FOR XML PATH('Product'), TYPE) 'OrderDetails'
	 FROM(SELECT
			DISTINCT Customers.CustomerName, SalesOrder.OrderDate, SalesOrder.OrderID
			FROM Sales.Orders AS SalesOrder
			INNER JOIN Sales.OrderLines AS LineItem
				ON SalesOrder.OrderID = LineItem.OrderID
			INNER JOIN Sales.Customers AS Customers
				ON Customers.CustomerID = SalesOrder.CustomerID
			WHERE customers.CustomerID = OuterCust.CustomerID) AS Base
	 FOR XML PATH('Order'), ROOT ('SalesOrders'), TYPE) AS OrderSummary
FROM Sales.Customers AS OuterCust;
GO

SELECT * FROM Sales.CustomerOrderSummary;
GO

-- XML Fragment از یک متغیر Attribute جستجوی مقدار یک
DECLARE @SalesOrders XML;
SET @SalesOrders = '<SalesOrder OrderDate="2016-05-27" OrderID="73356">
						<Customers CustomerName="Agrita Abele">
						<Product StockItemName="Chocolate sharks 250g">
							<LineItem Quantity="192" UnitPrice="8.55" />
						</Product>
						</Customers>
					</SalesOrder>';
SELECT @SalesOrders.exist('SalesOrder/Customers/Product[(@StockItemName) eq "Chocolate sharks 250g"]');
GO

-- XML Fragment از یک متغیر Element جستجوی مقدار یک
DECLARE @SalesOrders XML;
SET @SalesOrders = '<SalesOrder OrderDate="2016-05-27" OrderID="73356">
						<Customers>Agrita Abele</Customers>
						<Product StockItemName="Chocolate sharks 250g">
							<LineItem Quantity="192" UnitPrice="8.55" />
						</Product>
					</SalesOrder>';
SELECT @SalesOrders.exist('SalesOrder/Customers[(text()[1]) eq "Agrita Abele"]');
GO

SELECT 
	CustomerID, OrderSummary
FROM Sales.CustomerOrderSummary
	WHERE OrderSummary.exist('SalesOrders/Order/OrderHeader/CustomerName[(text()[1]) eq "Tailspin Toys (Absecon, NJ)"]') = 0;
GO

SELECT 
	CustomerID, OrderSummary
FROM Sales.CustomerOrderSummary
	WHERE OrderSummary.exist('SalesOrders/Order/OrderHeader/CustomerName[(text()[1]) eq "Tailspin Toys (Absecon, NJ)"]') = 1;
GO

SELECT 
	CustomerID,
	OrderSummary.exist('SalesOrders/Order/OrderHeader/CustomerName[(text()[1]) = "Tailspin Toys (Absecon, NJ)"]') AS Tailspin_Customer
FROM Sales.CustomerOrderSummary;
GO
--------------------------------------------------------------------

/*
value (XQuery, SQLType)
*/

-- XML Fragment از یک متغیر Attribute بازیابی مقدار یک
DECLARE @SalesOrders XML;
SET @SalesOrders = '<SalesOrder OrderDate="2016-05-27" OrderID="73356">
						<Customers CustomerName="Agrita Abele">
						<Product StockItemName="Chocolate sharks 250g">
							<LineItem Quantity="192" UnitPrice="8.55" />
						</Product>
						</Customers>
					</SalesOrder>';
SELECT @SalesOrders.value('(/SalesOrder/Customers/@CustomerName)[1]', 'NVARCHAR(100)') AS CustomerName;
GO

-- XML Fragment از یک متغیر Element بازیابی مقدار یک
DECLARE @SalesOrders XML;
SET @SalesOrders = '<SalesOrder OrderDate="2016-05-27" OrderID="73356">
						<Customers>Agrita Abele</Customers>
						<Product StockItemName="Chocolate sharks 250g">
							<LineItem Quantity="192" UnitPrice="8.55" />
						</Product>
					</SalesOrder>';
SELECT @SalesOrders.value('(/SalesOrder/Customers)[1]', 'NVARCHAR(100)') AS CustomerName;
GO

SELECT
      CustomerID,
	  OrderSummary,
	  OrderSummary.value('(/SalesOrders/Order/OrderHeader/CustomerName)[1]', 'NVARCHAR(100)') AS CustomerName
FROM Sales.CustomerOrderSummary;
GO

SELECT
	CustomerID, OrderSummary,
	OrderSummary.value('(/SalesOrders/Order/OrderDetails/Product/@ProductID)[1]', 'INT') AS ProductID
FROM Sales.CustomerOrderSummary;
GO

-- WHERE در بخش value استفاده از متد
SELECT
      CustomerID,
	  OrderSummary
FROM Sales.CustomerOrderSummary
	WHERE OrderSummary.value('(/SalesOrders/Order/OrderHeader/CustomerName)[1]', 'NVARCHAR(100)') = 'Tailspin Toys (Absecon, NJ)';
GO
--------------------------------------------------------------------

/*
query ('XQuery') 
*/

DECLARE @SalesOrders XML;
SET @SalesOrders = '<SalesOrder OrderDate="2016-05-27" OrderID="73356">
						<Customers CustomerName="Agrita Abele">
						<Product StockItemName="Chocolate sharks 250g">
							<LineItem Quantity="192" UnitPrice="8.55" />
						</Product>
						</Customers>
					</SalesOrder>';
SELECT @SalesOrders.query('/SalesOrder/Customers/Product') AS ProductDetails;
GO

-- XML برگرداندن کل مجموعه
DECLARE @SalesOrders XML;
SET @SalesOrders = '<SalesOrder OrderDate="2016-05-27" OrderID="73356">
						<Customers CustomerName="Agrita Abele">
						<Product StockItemName="Chocolate sharks 250g">
							<LineItem Quantity="192" UnitPrice="8.55" />
						</Product>
						</Customers>
					</SalesOrder>';
SELECT @SalesOrders.query('.') AS ProductDetails;
GO

SELECT
	OrderSummary,
	OrderSummary.value('(/SalesOrders/Order/OrderHeader/CustomerName)[1]', 'NVARCHAR(100)') AS CustomerName,
	OrderSummary.value('(/SalesOrders/Order/OrderHeader/OrderID)[1]', 'INT') AS OrderID, -- !به سایر مقادیر داخل [] اشاره شود
	OrderSummary.query('/SalesOrders/Order/OrderDetails/Product') AS ProductsOrdered
FROM Sales.CustomerOrderSummary 
	WHERE OrderSummary.exist('SalesOrders/Order/OrderHeader/CustomerName[(text()[1]) eq "Tailspin Toys (Absecon, NJ)"]') = 1;
GO
--------------------------------------------------------------------

/*
Relational Values in XQuery
*/

DECLARE @CustomerName NVARCHAR(100) = 'Tailspin Toys (Absecon, NJ)';
SELECT
	OrderSummary,
	OrderSummary.value('(/SalesOrders/Order/OrderHeader/CustomerName)[1]','NVARCHAR(100)') AS CustomerName,
	OrderSummary.value('(/SalesOrders/Order/OrderHeader/OrderID)[1]', 'INT') AS OrderID,
	OrderSummary.query('/SalesOrders/Order/OrderDetails/Product') AS ProductsOrdered
FROM Sales.CustomerOrderSummary 
	WHERE OrderSummary.exist('SalesOrders/Order/OrderHeader/CustomerName[(text()[1]) eq sql:variable("@CustomerName")]') = 1;
GO

DECLARE @Gold NVARCHAR(3) = 'Yes';
DECLARE @CustomerName NVARCHAR(100) = 'Tailspin Toys (Absecon, NJ)';
SELECT
	OrderSummary,
	OrderSummary.value('(/SalesOrders/Order/OrderHeader/CustomerName)[1]', 'nvarchar(100)') AS CustomerName,
	OrderSummary.value('(/SalesOrders/Order/OrderHeader/OrderID)[1]', 'int') AS OrderID,
	OrderSummary.query('/SalesOrders/Order/OrderDetails/Product') AS ProductsOrdered,
	OrderSummary.query('<CustomerDetails>GoldCustomer = "{ sql:variable("@Gold") }"  </CustomerDetails>') AS CustomerDetails
FROM Sales.CustomerOrderSummary 
	WHERE OrderSummary.exist('SalesOrders/Order/OrderHeader/CustomerName[(text()[1]) eq sql:variable("@CustomerName")]') = 1;
GO

DECLARE @Gold NVARCHAR(3) = 'Yes';
DECLARE @CustomerName NVARCHAR(100) = 'Tailspin Toys (Absecon, NJ)';
SELECT
	OrderSummary,
	OrderSummary.value('(/SalesOrders/Order/OrderHeader/CustomerName)[1]', 'nvarchar(100)') AS CustomerName,
	OrderSummary.value('(/SalesOrders/Order/OrderHeader/OrderID)[1]', 'int') AS OrderID,
	OrderSummary.query('/SalesOrders/Order/OrderDetails/Product') AS ProductsOrdered,
	OrderSummary.query('<CustomerDetails> CustomerID = "{ sql:column("CustomerID") }" GoldCustomer = "{ sql:variable("@Gold") }" </CustomerDetails>') As CustomerDetails
FROM Sales.CustomerOrderSummary 
	WHERE OrderSummary.exist('SalesOrders/Order/OrderHeader/CustomerName[(text()[1]) eq sql:variable("@CustomerName") ]') = 1;
GO
--------------------------------------------------------------------

/* 
modify (XML_DML)

insert Expression1 (  
{as first | as last} into | after | before  
Expression2  
)
*/

-- Element Node درج
DECLARE @SalesOrder XML;         
SET @SalesOrder = '	<Order>         
						<OrderHeader>
							<CustomerName>Camille Authier</CustomerName>
							<OrderDate>2013-01-02</OrderDate>
							<OrderID>121</OrderID>
						</OrderHeader>
						<OrderDetails>         
						</OrderDetails>         
					</Order>';            
SET @SalesOrder.modify('insert <Product ProductID="22" ProductName="DBA joke mug - it depends (White)" Price="13" Qty="6" />   
						into (/Order/OrderDetails)[1]');
SELECT @SalesOrder;
GO

-- و تعیین موقعیت آن Element Node درج
DECLARE @SalesOrder XML;         
SET @SalesOrder = '	<Order>
						<OrderHeader>
							<CustomerName>Camille Authier</CustomerName>
							<OrderDate>2013-01-02</OrderDate>
							<OrderID>121</OrderID>
						</OrderHeader>
						<OrderDetails>
							<Product ProductID="22" ProductName="DBA joke mug - it depends (White)" Price="13" Qty="6" />
						</OrderDetails>
					</Order>';             
SET @SalesOrder.modify('insert <Product ProductID="2" ProductName="USB rocket launcher (Gray)" Price="25" Qty="9" />
						as first into (/Order/OrderDetails)[1]');  
SELECT @SalesOrder;
GO

-- Sibling Node درج
DECLARE @SalesOrder XML;         
SET @SalesOrder = '	<Order>
						<OrderHeader>
							<CustomerName>Camille Authier</CustomerName>
							<OrderDate>2013-01-02</OrderDate>
							<OrderID>121</OrderID>
						</OrderHeader>
						<OrderDetails>
							<Product ProductID="22" ProductName="DBA joke mug - it depends (White)" Price="13" Qty="6" />
						</OrderDetails>
					</Order>';             
SET @SalesOrder.modify('insert <CompanyName>Strong long lasting </CompanyName>
						after (/Order/OrderHeader/CustomerName)[1]');  
SELECT @SalesOrder;
GO

-- به صورت همزمان Element Nodes درج چندین
DECLARE @SalesOrder XML; 
DECLARE @NewFeatures XML = '<OrderDate>2013-01-02</OrderDate>
							<OrderID>121</OrderID>';
SET @SalesOrder = '	<Order>
						<OrderHeader>
							<CustomerName>Camille Authier</CustomerName>
						</OrderHeader>
						<OrderDetails>
							<Product ProductID="22" ProductName="DBA joke mug - it depends (White)" Price="13" Qty="6" />
						</OrderDetails>
					</Order>';             
SET @SalesOrder.modify('insert sql:variable("@NewFeatures")
						into (/Order/OrderHeader)[1]');  
SELECT @SalesOrder;
GO

-- Attribute درج
DECLARE @SalesOrder XML;         
SET @SalesOrder = '	<Order>
						<OrderHeader>
							<CustomerName>Camille Authier</CustomerName>
							<OrderDate>2013-01-02</OrderDate>
							<OrderID>121</OrderID>
						</OrderHeader>
						<OrderDetails>
							<Product ProductID="22" ProductName="DBA joke mug - it depends (White)" Price="13" />
						</OrderDetails>
					</Order>'
SET @SalesOrder.modify('insert attribute Qty {"6"}             
						into (/Order/OrderDetails/Product[@ProductID=22])[1]');
SELECT @SalesOrder;
GO
--------------------------------------------------------------------

/*
modify (XML_DML)

delete Expression
*/

DECLARE @SalesOrder XML;
SET @SalesOrder = ' <Order>
						<OrderHeader>
							<CustomerName>Camille Authier</CustomerName>
							<OrderDate>2013-01-02</OrderDate>
							<OrderID>121</OrderID>
						</OrderHeader>
						<OrderDetails>
							<Product ProductID="2" ProductName="USB rocket launcher (Gray)" Price="25" Qty="9" />
							<Product ProductID="111" ProductName="Superhero action jacket (Blue) M" Price="30" Qty="10" />
							<Product ProductID="22" ProductName="DBA joke mug - it depends (White)" Price="13" Qty="6" />
						</OrderDetails>
					</Order>';
DECLARE @ProductName NVARCHAR(200) = 'Superhero action jacket (Blue) M';
SET @SalesOrder.modify('delete (/Order/OrderDetails/Product[@ProductName = sql:variable("@ProductName")])[1]');  
SELECT @SalesOrder;
GO
--------------------------------------------------------------------

/*
replace (XML_DML)

replace value of Expression1   
with Expression2  
*/

DECLARE @SalesOrder XML;       
SET @SalesOrder = ' <Order>
						<OrderHeader>
							<CustomerName>Camille Authier</CustomerName>
							<OrderDate>2013-01-02</OrderDate>
							<OrderID>121</OrderID>
						</OrderHeader>
						<OrderDetails>
							<Product ProductID="2" ProductName="USB rocket launcher (Gray)" Price="25" Qty="9" />
							<Product ProductID="22" ProductName="DBA joke mug - it depends (White)" Price="13" Qty="6" />
						</OrderDetails>
					</Order>';
DECLARE @ProductName NVARCHAR(200) = 'DBA joke mug - it depends (White)';
DECLARE @Quantity INT = 10;
SET @SalesOrder.modify('replace value of (/Order/OrderDetails/Product[@ProductName = sql:variable("@ProductName")]/@Qty)[1]
						with "10"');
SELECT @SalesOrder;   
GO
--------------------------------------------------------------------

/*
FLWOR

for: انجام عملیات تکراری بر روی مجموعه‌ای از نودها
let: به یک متغیر XQuery کردن یک عبارت Assign
where: اعمال فیلتر بر روی نتایج
order by: مرتب‌سازی نتایج
return: تعیین آنچه که می‌بایست در خروجی بیاید
*/

DECLARE @XML XML = 
	'<SalesOrders>
		<Order>
			<OrderHeader>
				<CustomerName>Tailspin Toys (Absecon, NJ)</CustomerName>
				<OrderDate>2013-01-17</OrderDate>
				<OrderID>950</OrderID>
			</OrderHeader>
			<OrderDetails>
				<Product ProductID="119" ProductName="Dinosaur battery-powered slippers (Green) M" Price="32.00" Qty="2" />
				<Product ProductID="61" ProductName="RC toy sedan car with remote control (Green) 1/50 scale" Price="25.00" Qty="2" />
				<Product ProductID="194" ProductName="Black and orange glass with care despatch tape 48mmx100m" Price="4.10" Qty="216" />
				<Product ProductID="104" ProductName="Alien officer hoodie (Black) 3XL" Price="35.00" Qty="2" />
			</OrderDetails>
		</Order>
		<Order>
			<OrderHeader>
				<CustomerName>Tailspin Toys (Absecon, NJ)</CustomerName>
				<OrderDate>2013-01-29</OrderDate>
				<OrderID>1452</OrderID>
			</OrderHeader>
			<OrderDetails>
				<Product ProductID="33" ProductName="Developer joke mug -that s a hardware problem (Black)" Price="13.00" Qty="9" />
				<Product ProductID="121" ProductName="Dinosaur battery-powered slippers (Green) XL" Price="32.00" Qty="1" />
			</OrderDetails>
		</Order>
	</SalesOrders>';

--SELECT @XML.query(' for $product in /SalesOrders/Order[2]/OrderDetails/Product/@ProductName
--					return string($product)');

--SELECT @XML.query(' let $product := /SalesOrders/Order[1]/OrderDetails/Product/@ProductName
--					return string($product[1])');

SELECT @XML.query(' for $product in /SalesOrders/Order/OrderDetails/Product/@ProductName
					let $customer := /SalesOrders/Order/OrderHeader/CustomerName
					return 
						<Customer> {$customer[1]}
						<OrderDetails> {$product} </OrderDetails>
						</Customer>');

SELECT @XML.query(' for $product in /SalesOrders/Order/OrderDetails/Product/@ProductName
					let $customer := /SalesOrders/Order/OrderHeader/CustomerName
						where $product = "Dinosaur battery-powered slippers (Green) M"
						or $product = "Dinosaur battery-powered slippers (Green) XL"
					order by $product
					return
						<Customer> {$customer[1]}
						<OrderDetails> {$product} </OrderDetails>
						</Customer>');
GO