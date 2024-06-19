

-- Attribute-Centric  
DECLARE @Xml_Var XML = '<Person FirstName = "Ali" LastName = "Ahmadian" />';
SELECT @Xml_Var;
GO
--------------------------------------------------------------------

-- Element-Centric 
DECLARE @Xml_Var XML = '<Person>
							<FirstName>Ali</FirstName>
							<LastName>Ahmadian</LastName>
						</Person>';
SELECT @Xml_Var;
GO
--------------------------------------------------------------------

USE tempdb;
GO

DROP TABLE IF EXISTS Xml_Table;
GO

CREATE TABLE Xml_Table
	(
		ID INT,
		XML_Field XML
	);
GO

-- و حتی مقادیر عادی Element-Centric ،Attribute-Centric به شکل XML درج مقادیر در ستون
INSERT INTO Xml_Table(ID,XML_Field)
	VALUES	(1, '<PersonInfo>
					<Person FirstName = "Ali" LastName = "Ahmadian" />
					<Person FirstName = "Parisa" LastName = "Motamedi" />
				 </PersonInfo>'),
			(2,	'<PersonInfo>
					<Person FirstName = "Hamid" LastName = "Rezazade" />
					<Person FirstName = "Sahar" LastName = "Taghavi" />
					<Person FirstName = "Fateme" LastName = "Najafi" />
				 </PersonInfo>'),
			(3, '<Person FirstName = "Majid" LastName = "Ashtari" />'),
			(4,	NULL),
			(5, 'Normal Data')
GO

SELECT * FROM Xml_Table;
GO
--------------------------------------------------------------------

/*
XML Data Type محدودیت‌های
*/

-- COLLATION عدم تنظیم
CREATE TABLE Xml_Tbl
	(
		ID INT PRIMARY KEY,
		Family NVARCHAR(100) COLLATE PERSIAN_100_CI_AI,
		XML_Data XML COLLATE PERSIAN_100_CI_AI
	);
GO

-- عدم انجام مقایسه
SELECT * FROM Xml_Table
	WHERE XML_Field = '<Person FirstName="Majid" LastName="Ashtari" />';
GO

-- عدم انجام مقایسه
SELECT * FROM Xml_Table
	WHERE CAST(XML_Field AS VARCHAR(MAX)) = '<Person FirstName="Majid" LastName="Ashtari" />';
GO

-- .ایرادی ندارد LIKE جستجو با استفاده از
SELECT * FROM Xml_Table
	WHERE CAST(XML_Field AS NVARCHAR(MAX)) LIKE '%Majid%';
GO

-- .ایرادی ندارد NULL مقایسه مقادیر
SELECT * FROM Xml_Table
	WHERE XML_Field IS NULL;
GO

-- GROUP BY عدم انجام
SELECT XML_Field FROM Xml_Table
GROUP BY XML_Field;
GO

-- عدم انجام مرتب‌سازی
SELECT * FROM Xml_Table
ORDER BY XML_Field;
GO

-- NONCLUSTERED و CLUSTERED عدم استفاده به شکل ایندکس‌های
CREATE CLUSTERED INDEX CIX_XML ON Xml_Table(XML_Field);
GO

CREATE UNIQUE CLUSTERED INDEX UCIX_XML ON Xml_Table(XML_Field);
GO

CREATE INDEX NCIX_XML ON Xml_Table(XML_Field)
GO

CREATE UNIQUE INDEX UIX_XML ON Xml_Table(XML_Field);
GO
--------------------------------------------------------------------

/*
XSD : XML Schema Definion
XML تعیین کننده ساختار، نوع داده و المان‌های یک سند
*/

DROP TABLE IF EXISTS Xml_Table;
GO

CREATE TABLE Xml_Table
	(
		ID INT,
		XML_Field XML
	);
GO

-- نحوه تعریف اسکیما
CREATE XML SCHEMA COLLECTION Employee_Schema AS
'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="Employee">
   <xsd:complexType>
     <xsd:sequence> 
        <xsd:element name="FirstName" type="xsd:string" /> 
        <xsd:element name="LastName" type="xsd:string" />
     </xsd:sequence>
        <xsd:attribute name="EmployeeID" type="xsd:integer" />
    </xsd:complexType>
  </xsd:element>
</xsd:schema>'
GO

-- مشاهده اطلاعاتی درباره اسکیما
SELECT * FROM sys.xml_schema_collections;
SELECT * FROM sys.xml_schema_namespaces;
SELECT * FROM sys.xml_schema_elements;
SELECT * FROM sys.xml_schema_attributes;
SELECT * FROM sys.xml_schema_types;
SELECT * FROM sys.column_xml_schema_collection_usages;
SELECT * FROM sys.parameter_xml_schema_collection_usages;
GO

-- XML نحوه استفاده از اسکیما بر روی فیلدی از دیتا تایپ
DROP TABLE IF EXISTS Employees_XmlTable;
GO

CREATE TABLE Employees_XmlTable
	(
		ID INT PRIMARY KEY,
		XML_Field XML (DOCUMENT Employee_Schema)
	);
GO

INSERT Employees_XmlTable(ID,XML_Field)
	VALUES	(1, '<Employee EmployeeID = "1">
					<FirstName>Ali</FirstName>
					<LastName>Ahmadian</LastName>
				 </Employee>');
GO

INSERT Employees_XmlTable(ID,XML_Field)
	VALUES	(2,	'<Employee EmployeeID = "2">
					<FirstName>Parisa</FirstName>
					<LastName>Motamedi</LastName>
				 </Employee>');
GO

-- درج ناموفق به دلیل مغایرت با اسکیما
INSERT Employees_XmlTable(ID,XML_Field)
	VALUES	(3, '<Employee EmployeeID = "Three">
					<FirstName>Hamid</FirstName>
					<LastName>Rezazade</LastName>
				 </Employee>');
GO

-- درج ناموفق به دلیل مغایرت با اسکیما
INSERT Employees_XmlTable(ID,XML_Field)
	VALUES	(3, '<Employee EmployeeID = "3">
					<FirstName>Hamid</FirstName>
				 </Employee>');
GO

INSERT Employees_XmlTable(ID,XML_Field)
	VALUES	(3, '<Employee>
					<EmployeeID>"3"</EmployeeID>
					<FirstName>Hamid</FirstName>
					<LastName>Rezazade</LastName>
				 </Employee>');
GO

SELECT * FROM Employees_XmlTable;
GO

-- !توضیح داده شود Management Studio و Visual Studio نحوه ساخت اسکیما در

-- نحوه استفاده از اسکیما در متغییرها
DECLARE @Xml_Var XML (DOCUMENT Employee_Schema)
SET @Xml_Var =	'<Employee EmployeeID = "1">
					<FirstName>Ali</FirstName>
				 </Employee>'
GO

DECLARE @Xml_Var XML (Document Employee_Schema)
SET @Xml_Var =	'<Employee EmployeeID = "1">
					<FirstName>Ali</FirstName>
					<LastName>Ahmadian</LastName>
				 </Employee>';
SELECT @Xml_Var;
GO

-- حذف اسکیما
IF EXISTS(SELECT TOP 1 * FROM sys.xml_schema_collections
			WHERE name = 'Employee_Schema')
BEGIN
	DROP TABLE Employees_XmlTable;
	DROP XML SCHEMA COLLECTION Employee_Schema;
END
GO
--------------------------------------------------------------------

-- XML بارگذاری دیتاها از فایل 
SELECT * FROM OPENROWSET 
	(BULK N'C:\Dump\BulkLoad.xml', SINGLE_CLOB) AS X 
GO

DECLARE @Xml_Var XML;
SELECT @Xml_Var = BulkColumn FROM OPENROWSET 
	(BULK N'C:\Dump\BulkLoad.xml', SINGLE_CLOB) AS X 
SELECT @Xml_Var;
GO

--در یک جدولXML درج داده های 
DROP TABLE IF EXISTS Employees_XmlTable;
GO

CREATE TABLE Employees_XmlTable
	(
		ID INT IDENTITY PRIMARY KEY,
		XML_Field XML 
	);
GO

INSERT INTO Employees_XmlTable(XML_Field)
	SELECT BulkColumn FROM OPENROWSET 
		(BULK N'C:\Dump\BulkLoad.xml', SINGLE_CLOB) AS X 
GO

SELECT * FROM Employees_XmlTable;
GO