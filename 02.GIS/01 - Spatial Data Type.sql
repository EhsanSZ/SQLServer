

DROP DATABASE IF EXISTS Spatial_DB;
GO

CREATE DATABASE Spatial_DB;
GO

USE Spatial_DB;
GO

DROP TABLE IF EXISTS Spatial_Geometry;
GO

CREATE TABLE Spatial_Geometry
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		Obj_Name VARCHAR(64),
		Geom_Column GEOMETRY
	);
GO

-- Non-OGC درج رکورد در جدول به روش
INSERT INTO Spatial_Geometry
	VALUES ('Point1', geometry::Parse('Point(3 4)'));
GO

-- Non-OGC درج رکورد در جدول به روش
INSERT INTO Spatial_Geometry
	VALUES ('Point2', geometry::Point(5,3,0));
GO

SELECT
	ID, Obj_Name, Geom_Column
FROM Spatial_Geometry;
GO

-- OGC درج رکورد در جدول به روش
INSERT INTO Spatial_Geometry
	VALUES	('Point3', geometry::STGeomFromText('POINT(7 2)',0)),
			('Point4', geometry::STPointFromText('POINT (6 1)',0));
GO

INSERT INTO Spatial_Geometry
	VALUES	('Line1', geometry::STLineFromText('LINESTRING(2 2, 5 5)',0)),
			('Line2', geometry::STGeomFromText('LINESTRING(5 1, 6 1, 6 2, 7 2, 7 3)',0)),
			('Area1', geometry::STPolyFromText('POLYGON ((1 1, 4 1, 4 5, 1 5, 1 1))',0));
GO

SELECT
	ID, Obj_Name, Geom_Column
FROM Spatial_Geometry;
GO
--------------------------------------------------------------------

/*
STAsText()
یک نمونه جغرافیایی WKT در فرمت OGC ارائه مقدار
*/
SELECT
	ID, Obj_Name, Geom_Column.STAsText() AS GeoTxt
FROM Spatial_Geometry;
GO
--------------------------------------------------------------------

-- مختلف در جدول SIRD درج رکورد با
INSERT INTO Spatial_Geometry
	VALUES	('Area2', geometry::STGeomFromText('POLYGON ((5 4, 5 7, 8 7, 8 4, 5 4))',1));
GO

SELECT
	ID, Obj_Name, Geom_Column
FROM Spatial_Geometry;
GO

-- STSrid با استفاده از SIRD تغیر
UPDATE Spatial_Geometry
	SET Geom_Column.STSrid = 0
	WHERE Obj_Name = 'Area2';
GO

SELECT
	ID, Obj_Name, Geom_Column
FROM Spatial_Geometry;
GO

SELECT
	ID, Obj_Name, Geom_Column, Geom_Column.STSrid AS SRID_Value
FROM Spatial_Geometry;
GO
-------------------------------------------------------------------- 

-- Points عدم نمایش مناسب نقاط یا
SELECT
	ID, Obj_Name, Geom_Column
FROM Spatial_Geometry;
GO

SELECT
	ID, Obj_Name, Geom_Column.STBuffer(.1)
FROM Spatial_Geometry;
GO

/*
InstanceOf (geometry_type)
Spatial تشابه نوع هندسی موردنظر با یک آبجکت
*/
SELECT
	ID, Obj_Name, Geom_Column.STBuffer(.1)
FROM Spatial_Geometry
	WHERE Geom_Column.InstanceOf('Point') = 1;
GO

SELECT
	ID, Obj_Name, Geom_Column, Geom_Column.InstanceOf('Point') AS Is_Point
FROM Spatial_Geometry;
GO
--------------------------------------------------------------------

/*
بررسی تاثیر متقابل میان نمونه‌های هندسی
*/
DROP TABLE IF EXISTS Points,Lines,Polygons;
GO

CREATE TABLE Points
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		Obj_Name VARCHAR(50),
		Geom_Column GEOMETRY
	);
GO

CREATE TABLE Lines
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		Obj_Name VARCHAR(50),
		Geom_Column GEOMETRY
	);
GO

CREATE TABLE Polygons
	(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		Obj_Name VARCHAR(50),
		Geom_Column GEOMETRY
	);
GO

INSERT INTO Points
	VALUES	('Point1', geometry::STGeomFromText('POINT(3 4)',0)),
			('Point2', geometry::STGeomFromText('POINT(5 3)',0)),
			('Point3', geometry::STGeomFromText('POINT(5 2)',0)),
			('Point4', geometry::STGeomFromText('POINT(2 4.7)',0)),
			('Point5', geometry::STGeomFromText('POINT(4.1 2)',0));
GO

INSERT INTO Lines
	VALUES	('Line1', geometry::STGeomFromText('LINESTRING(2 2, 5 5)',0)),
			('Line2', geometry::STGeomFromText('LINESTRING(5 1, 6 1, 6 2, 7 2, 7 3)',0)),
			('Line3', geometry::STGeomFromText('LINESTRING(4 7, 5 1.5)',0));
GO

INSERT INTO Polygons
	VALUES	('Area1', geometry::STGeomFromText('POLYGON ((1 1, 4 1, 4 5, 1 5, 1 1))',0)),
			('Area2', geometry::STGeomFromText('POLYGON ((5 4, 5 7, 8 7, 8 4, 5 4))',0)),
			('Area3', geometry::STGeomFromText('POLYGON ((2 3, 6 3, 6 6, 2 6, 2 3))',0));
GO

SELECT
	Geom_Column.STBuffer(.1), Obj_Name
FROM Points
UNION ALL
SELECT
	Geom_Column.STBuffer(.02), Obj_Name
FROM Lines
UNION ALL
SELECT
	Geom_Column.STBuffer(.02), Obj_Name
FROM Polygons;
GO

/*
STIntersects (other_geometry) 
.در صورتی‌که یک نمونه هندسی با نمونه دیگر تقاطع داشته باشد مقدار 1 و در غیر این صورت مقدار 0 بر می‌گرداند
*/
-- ?را قطع می‌کنند Area1 کدام نقاط، چندضلعی
DECLARE @Polygon GEOMETRY;
SET @Polygon = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SELECT
	Obj_Name
FROM Points
	WHERE @Polygon.STIntersects(Geom_Column) = 1;
GO

DECLARE @Polygon GEOMETRY;
SET @Polygon = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SELECT
	Geom_Column.STBuffer(.1)
FROM Points
	WHERE @Polygon.STIntersects(Geom_Column) = 1
UNION ALL
SELECT @Polygon;
GO

-- ?را قطع می‌کنند Line1 کدام چندضلعی‌ها، خط
DECLARE @Line GEOMETRY;
SET @Line = (SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line1');
SELECT
	Obj_Name
FROM Polygons
	WHERE @Line.STIntersects(Geom_Column) = 1;
GO

/*
STDisjoint (other_geometry) 
.در صورتی‌که یک نمونه هندسی با نمونه دیگر تقاطعی نداشته باشد مقدار 1 و در غیر این صورت مقدار 0 بر می‌گرداند
*/
DECLARE @Line GEOMETRY;
SET @Line = (SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line1');
DECLARE @Area GEOMETRY;
SET @Area = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area2');
SELECT @Line.STDisjoint(@Area) AS Disjoint;
GO

DECLARE @Line GEOMETRY;
DECLARE @Area GEOMETRY;
SET @Line = (SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line2');
SET @Area = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area2');
SELECT @Line.STDisjoint(@Area) AS Disjoint;
GO
--------------------------------------------------------------------

/*
STIntersection (other_geometry)
.بیانگر مختصات میان دو نمونه هندسی که با یکدیگر تلاقی دارند
*/

-- ایجاد نمونه هندسی جدید  ‌
DECLARE @Area1 GEOMETRY;
DECLARE @Area3 GEOMETRY;
SET @Area1 = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SET @Area3 = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area3');
SELECT @Area1.STIntersection(@Area3).STAsText() AS Well_Known_Text;

SELECT @Area1.STIntersection(@Area3).STBuffer(.1) AS Well_Known_Text
UNION ALL
SELECT Geom_Column.STBuffer(.02) FROM Polygons
	WHERE Obj_Name IN ('Area1', 'Area3');
GO

DECLARE @Area1 GEOMETRY;
DECLARE @Area2 GEOMETRY;
SET @Area1 = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SET @Area2 = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area2');
SELECT @Area1.STIntersection(@Area2).STAsText() AS Well_Known_Text;

SELECT @Area1.STIntersection(@Area2) AS Well_Known_Text
UNION ALL
SELECT Geom_Column.STBuffer(.02) FROM Polygons
	WHERE Obj_Name IN ('Area1', 'Area2');
GO

DECLARE @Area1 GEOMETRY;
DECLARE @Point1 GEOMETRY;
SET @Area1 = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SET @Point1 = (SELECT Geom_Column FROM Points WHERE Obj_Name = 'Point1');
SELECT @Area1.STIntersection(@Point1).STAsText() AS Well_Known_Text;
GO

DECLARE @Area1 GEOMETRY;
DECLARE @Line1 GEOMETRY;
SET @Area1 = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SET @Line1 = (SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line1');
SELECT @Area1.STIntersection(@Line1).STAsText() AS Well_Known_Text;
GO
--------------------------------------------------------------------

/*
STUnion (other_geometry)
پیوند میان دو نمونه هندسی
*/

DECLARE @Point1 GEOMETRY;
DECLARE @Point2 GEOMETRY;
SET @Point1 = (SELECT Geom_Column FROM Points WHERE Obj_Name = 'Point1');
SET @Point2 = (SELECT Geom_Column FROM Points WHERE Obj_Name = 'Point2');
SELECT @Point1.STUnion(@Point2).STAsText() AS Well_Known_Text;

SELECT
	Geom_Column.STBuffer(.1)
FROM Points
	WHERE Obj_Name = 'Point1'
UNION ALL
SELECT
	Geom_Column.STBuffer(.1)
FROM Points
	WHERE Obj_Name = 'Point2';
GO

DECLARE @Line1 GEOMETRY;
DECLARE @Area1 GEOMETRY;
SET @Line1 = (SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line1');
SET @Area1 = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SELECT @Line1.STUnion(@Area1).STAsText() AS Well_Known_Text;

SELECT Geom_Column.STBuffer(.1) FROM Lines WHERE Obj_Name = 'Line1'
UNION ALL
SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1';
GO

DECLARE @Point1 GEOMETRY;
DECLARE @Area1 GEOMETRY;
SET @Point1 = (SELECT Geom_Column FROM Points WHERE Obj_Name = 'Point1');
SET @Area1 = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SELECT @Point1.STUnion(@Area1).STAsText() AS Well_Known_Text;

SELECT Geom_Column.STBuffer(.1) FROM Points WHERE Obj_Name = 'Point1'
UNION ALL
SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1';
GO

DECLARE @Point3 GEOMETRY;
DECLARE @Area1 GEOMETRY;
DECLARE @union1 GEOMETRY;
SET @Point3 = (SELECT Geom_Column FROM Points WHERE Obj_Name = 'Point3');
SET @Area1 = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SET @union1 = @Area1.STUnion(@Point3);
SELECT @union1.STAsText() AS Well_Known_Text;

SELECT Geom_Column.STBuffer(.1) FROM Points WHERE Obj_Name = 'Point3'
UNION ALL
SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1';
GO
--------------------------------------------------------------------

/*
STDistance (other_geometry)
کوتاهترین فاصله میان دو نمونه هندسی
*/

-- ?هستند Line3 کدام نقاط به فاصله یک واحدی از
DECLARE @Line GEOMETRY;
SET @Line = (SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line3');
SELECT
	Obj_Name
FROM Points
	WHERE @Line.STDistance(Geom_Column) <= 1;
GO

-- ?هستند Line3 کدام نقاط به فاصله .2 واحدی از
DECLARE @Line GEOMETRY
SET @Line = (SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line3');
SELECT
	Obj_Name
FROM Polygons
	WHERE @Line.STDistance(Geom_Column) <= .2;
GO

-- Point2 با Line3 محاسبه فاصله میان
DECLARE @Line3 GEOMETRY = (SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line3');
DECLARE @Point2 GEOMETRY = (SELECT Geom_Column FROM Points WHERE Obj_Name = 'Point2');
SELECT @Point2.STDistance(@Line3) AS Distance;
GO

-- Area2 با Line3 محاسبه فاصله میان
DECLARE @Line3 GEOMETRY = (SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line3');
DECLARE @Area2 GEOMETRY = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area2');
SELECT @Area2.STDistance(@Line3) AS Distance;
GO

-- !اگر دو جسم با یکدیگر تقاطع داشته باشند کوتاهترین فاصله صفر خواهد بود
DECLARE @Line3 GEOMETRY = (SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line3');
DECLARE @Line1 GEOMETRY =
(SELECT Geom_Column FROM Lines WHERE Obj_Name = 'Line1');
SELECT @Line1.STDistance(@Line3) AS Distance;
GO
--------------------------------------------------------------------

/*
?چه نقاطی وجود دارد Area1 در محدوده 0.4 واحدی از ناحیه
*/

-- روش اول
DECLARE @Area GEOMETRY;
DECLARE @Buffer GEOMETRY;
SET @Area = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SET @Buffer = @Area.STBuffer(.4);
SELECT
	Obj_Name
FROM Points
	WHERE Geom_Column.STIntersects(@Buffer) = 1;

SELECT @Buffer
UNION ALL
SELECT Geom_Column.STBuffer(.1) FROM Points
UNION ALL
SELECT
	Geom_Column
FROM Polygons
	WHERE Obj_Name = 'Area1';
GO

-- روش دوم
DECLARE @Polygon GEOMETRY;
SET @Polygon = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SELECT
	Obj_Name
FROM Points
	WHERE @Polygon.STDistance(Geom_Column) <= .4;
GO


/*
Area1 بررسی نقاط مجاور در محدوده .4 واحدی (درونی و بیرونی) از نمونه هندسی
*/

-- روش اول
DECLARE @Area GEOMETRY;
DECLARE @Region GEOMETRY;
DECLARE @Distance FLOAT;
SET @Distance = .4;
SET @Area = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
SET @Region = @Area.STBuffer(@Distance).STDifference(@Area.STBuffer(@Distance * -1));

SELECT
	Obj_Name
FROM Points
	WHERE Geom_Column.STIntersects(@Region) = 1;
GO

-- روش دوم
DECLARE @Area GEOMETRY;
SET @Area = (SELECT Geom_Column FROM Polygons WHERE Obj_Name = 'Area1');
DECLARE @Distance FLOAT = .4;
SELECT
	Obj_Name
FROM Points
	WHERE Geom_Column.STDistance(@Area.STBoundary()) <= @Distance;
GO
--------------------------------------------------------------------

USE WideWorldImporters;
GO

DECLARE @StateBorder GEOGRAPHY = (SELECT Border FROM Application.StateProvinces
									WHERE StateProvinceName = 'Alabama');
SELECT
	Customer.CustomerName AS CustomerName,
	City.CityName AS City,
	Customer.DeliveryLocation.ToString() AS DeliveryLocation
FROM Sales.Customers AS Customer
INNER JOIN Application.Cities AS City
	ON City.CityID = Customer.DeliveryCityID
	WHERE Customer.DeliveryLocation.STWithin(@StateBorder) = 1 ;
GO

DECLARE @StateBorder GEOGRAPHY = (SELECT Border FROM Application.StateProvinces
									WHERE StateProvinceName = 'Alabama');
DECLARE @Office GEOGRAPHY = (SELECT DeliveryLocation FROM Application.SystemParameters);
SELECT
	Customer.CustomerName AS CustomerName,
	City.CityName AS City,
	Customer.DeliveryLocation.ToString() AS DeliveryLocation,
	Customer.DeliveryLocation.STDistance(@Office) AS DeliveryDistanceMiles
FROM Sales.Customers Customer
INNER JOIN Application.Cities City
	ON City.CityID = Customer.DeliveryCityID
	WHERE Customer.DeliveryLocation.STWithin(@StateBorder) = 1
ORDER BY DeliveryDistanceMiles;
GO
--------------------------------------------------------------------

/*
GEOGRAPHY
*/

-- پیش‌فرض برابر است با 4326 SRID
SELECT * FROM sys.spatial_reference_systems
ORDER BY unit_of_measure;
GO

DROP TABLE IF EXISTS Spatial_Geography;
GO

CREATE TABLE Spatial_Geography
	(
		Obj_Name VARCHAR(100),
		Geog_Column GEOGRAPHY
	);
GO

INSERT INTO Spatial_Geography
	VALUES	('Point1', geography::Parse('POINT(3 4)'));
GO

SELECT
	Geog_Column.STSrid AS SRID
FROM Spatial_Geography;
GO

INSERT INTO Spatial_Geography
	VALUES	('Point2', geography::Point(3,5,4326)),
			('Line1', geography::STLineFromText('LINESTRING(2 2, 5 5)',4326)),
			('Line2', geography::STGeomFromText('LINESTRING(5 1, 6 1, 6 2, 7 2, 7 3)',4326));
GO

SELECT * FROM Spatial_Geography;
GO

INSERT INTO Spatial_Geography
	VALUES	('Area1', geography::STPolyFromText('POLYGON ((1 1, 4 1, 4 5, 1 5, 1 1))',4326)),
			('Area2', geography::STGeomFromText('POLYGON ((5 4, 8 4, 8 7, 5 7, 5 4))',4326));
GO

SELECT * FROM Spatial_Geography;
GO
