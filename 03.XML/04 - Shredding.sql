

USE WideWorldImporters;
GO

/*
OPENXML

OPENXML( idoc int [ in] , rowpattern nvarchar [ in ] , [ flags byte [ in ] ] )   
[ WITH ( SchemaDeclaration | TableName ) ]  
*/

DECLARE @SalesOrder XML;
DECLARE @idoc INT;

SET @SalesOrder =
'<SalesOrders>
	<Order>
		<OrderDate>2013-01-02</OrderDate>
		<OrderHeader>
			<CustomerName>Camille Authier</CustomerName>
		</OrderHeader>
		<OrderDetails>
			<Product ProductID="45" ProductName="Developer joke mug - there are 10 types of people in the world (Black)" Price="13" Qty="7" />
			<Product ProductID="58" ProductName="RC toy sedan car with remote control (Black) 1/50 scale" Price="25" Qty="4" />
		</OrderDetails>
	</Order>
	<Order>
		<OrderDate>2013-01-02</OrderDate>
		<OrderHeader>
			<CustomerName>Camille Authier</CustomerName>
		</OrderHeader>
		<OrderDetails OrderID = "122">
			<Product ProductID="22" ProductName="DBA joke mug - it depends (White)" Price="13" Qty="6" />
			<Product ProductID="2" ProductName="USB rocket launcher (Gray)" Price="25" Qty="9" />
			<Product ProductID="111" ProductName="Superhero action jacket (Blue) M" Price="30" Qty="10" />
			<Product ProductID="116" ProductName="Superhero action jacket (Blue) 4XL" Price="34" Qty="4" />
		</OrderDetails>
	</Order>
</SalesOrders>';

-- XML کردن دیتای Parse در OPENXML محدودیت
EXEC sp_xml_preparedocument @idoc OUTPUT, @SalesOrder;

SELECT * FROM OPENXML(@idoc,'/SalesOrders/Order/OrderDetails/Product')
WITH (
		ProductID INT '@ProductID', -- پایین‌ترین سطح
		ProductName NVARCHAR(200) '@ProductName', -- پایین‌ترین سطح
		Quantity INT '@Qty', -- پایین‌ترین سطح
		OrderID INT '../@OrderID', -- Product یک سطح بالاتر از
		OrderDate DATE '../../OrderDate', -- Product دو سطح بالاتر از
		CustomerName NVARCHAR(200) '../../OrderHeader/CustomerName' -- Product دو سطح بالاتر از
	);
EXEC sp_xml_removedocument @idoc; 
GO
--------------------------------------------------------------------

/*
nodes (XQuery) as Table(Column)  
*/

DECLARE @SalesOrder XML;

SET @SalesOrder =
'<SalesOrders>
	<Order>
		<OrderDate>2013-01-02</OrderDate>
		<OrderHeader>
			<CustomerName>Camille Authier</CustomerName>
		</OrderHeader>
		<OrderDetails>
			<Product ProductID="45" ProductName="Developer joke mug - there are 10 types of people in the world (Black)" Price="13" Qty="7" />
			<Product ProductID="58" ProductName="RC toy sedan car with remote control (Black) 1/50 scale" Price="25" Qty="4" />
		</OrderDetails>
	</Order>
	<Order>
		<OrderDate>2013-01-02</OrderDate>
		<OrderHeader>
			<CustomerName>Camille Authier</CustomerName>
		</OrderHeader>
		<OrderDetails OrderID = "122">
			<Product ProductID="22" ProductName="DBA joke mug - it depends (White)" Price="13" Qty="6" />
			<Product ProductID="2" ProductName="USB rocket launcher (Gray)" Price="25" Qty="9" />
			<Product ProductID="111" ProductName="Superhero action jacket (Blue) M" Price="30" Qty="10" />
			<Product ProductID="116" ProductName="Superhero action jacket (Blue) 4XL" Price="34" Qty="4" />
		</OrderDetails>
	</Order>
</SalesOrders>';

SELECT 
	TmpCol.value('@ProductID','INT') AS ProductID,
	TmpCol.value('@ProductName','NVARCHAR(70)') AS ProductName,
	TmpCol.value('@Qty','INT') AS Quantity,
	TmpCol.value('../@OrderID','INT') AS OrderID,
	TmpCol.value('../../OrderDate[1]','NVARCHAR(10)') AS OrderDate,
	TmpCol.value('../../OrderHeader[1]/CustomerName[1]','NVARCHAR(15)') AS CustomerName
FROM @SalesOrder.nodes('SalesOrders/Order/OrderDetails/Product') AS TmpTable(TmpCol);
GO

SELECT
	CustomerID,
	TmpCol.value('@Qty','INT') AS Quantity,
	TmpCol.value('@ProductName','NVARCHAR(70)') AS ProductName,
	TmpCol.query('.') AS Product
FROM Sales.CustomerOrderSummary
CROSS APPLY OrderSummary.nodes('SalesOrders/Order/OrderDetails/Product') TmpTable(TmpCol) 
	WHERE CustomerID = 841 
ORDER BY Quantity DESC;
GO