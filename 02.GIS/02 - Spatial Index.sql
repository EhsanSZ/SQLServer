

USE tempdb;
GO

/*
CREATE SPATIAL INDEX index_name
  ON <object> ( spatial_column_name )  
    {  
       <geometry_tessellation> | <geography_tessellation>  
    }
  [ ON { filegroup_name | "default" } ]  
[;]
  
<object> ::=  
    { database_name.schema_name.table_name | schema_name.table_name | table_name }  
  
<geometry_tessellation> ::=  
{
  <geometry_automatic_grid_tessellation>
| <geometry_manual_grid_tessellation>
}  
  
<geometry_automatic_grid_tessellation> ::=  
{  
    [ USING GEOMETRY_AUTO_GRID ]  
          WITH  (  
        <bounding_box>  
            [ [,] <tessellation_cells_per_object> [ ,...n] ]  
            [ [,] <spatial_index_option> [ ,...n] ]  
                 )  
}  
  
<geometry_manual_grid_tessellation> ::=  
{  
       [ USING GEOMETRY_GRID ]  
         WITH (  
                    <bounding_box>  
                        [ [,]<tessellation_grid> [ ,...n] ]  
                        [ [,]<tessellation_cells_per_object> [ ,...n] ]  
                        [ [,]<spatial_index_option> [ ,...n] ]  
   )  
}
  
<geography_tessellation> ::=  
{  
      <geography_automatic_grid_tessellation> | <geography_manual_grid_tessellation>  
}  
  
<geography_automatic_grid_tessellation> ::=  
{  
    [ USING GEOGRAPHY_AUTO_GRID ]  
    [ WITH (  
        [ [,] <tessellation_cells_per_object> [ ,...n] ]  
        [ [,] <spatial_index_option> ]  
     ) ]  
}  
  
<geography_manual_grid_tessellation> ::=  
{  
    [ USING GEOGRAPHY_GRID ]  
    [ WITH (  
                [ <tessellation_grid> [ ,...n] ]  
                [ [,] <tessellation_cells_per_object> [ ,...n] ]  
                [ [,] <spatial_index_option> [ ,...n] ]  
                ) ]  
}  
  
<bounding_box> ::=  
{  
      BOUNDING_BOX = ( {  
       xmin, ymin, xmax, ymax
       | <named_bb_coordinate>, <named_bb_coordinate>, <named_bb_coordinate>, <named_bb_coordinate>
  } )  
}  
  
<named_bb_coordinate> ::= { XMIN = xmin | YMIN = ymin | XMAX = xmax | YMAX=ymax }  
  
<tessellation_grid> ::=  
{
    GRIDS = ( { <grid_level> [ ,...n ] | <grid_size>, <grid_size>, <grid_size>, <grid_size>  }
        )  
}  
<tessellation_cells_per_object> ::=  
{
   CELLS_PER_OBJECT = n
}  
  
<grid_level> ::=  
{  
     LEVEL_1 = <grid_size>
  |  LEVEL_2 = <grid_size>
  |  LEVEL_3 = <grid_size>
  |  LEVEL_4 = <grid_size>
}  
  
<grid_size> ::= { LOW | MEDIUM | HIGH }  
  
<spatial_index_option> ::=  
{  
    PAD_INDEX = { ON | OFF }  
  | FILLFACTOR = fillfactor  
  | SORT_IN_TEMPDB = { ON | OFF }  
  | IGNORE_DUP_KEY = OFF  
  | STATISTICS_NORECOMPUTE = { ON | OFF }  
  | DROP_EXISTING = { ON | OFF }  
  | ONLINE = OFF  
  | ALLOW_ROW_LOCKS = { ON | OFF }  
  | ALLOW_PAGE_LOCKS = { ON | OFF }  
  | MAXDOP = max_degree_of_parallelism  
    | DATA_COMPRESSION = { NONE | ROW | PAGE }  
}  
*/

/*
Creating a spatial index on a geometry column
*/

DROP TABLE IF EXISTS SpatialGeometryTable;
GO

CREATE TABLE SpatialGeometryTable
	(
		ID INT PRIMARY KEY,
		Geometry_Col GEOMETRY
	);
GO

CREATE SPATIAL INDEX SIndx_SpatialGeometryTable_Geometry_Col1
	ON SpatialGeometryTable(Geometry_Col)  
	WITH
		(
			BOUNDING_BOX = (0, 0, 500, 200)
		);
GO

CREATE SPATIAL INDEX SIndx_SpatialGeometryTable_Geometry_Col2  
	ON SpatialGeometryTable(Geometry_Col)  
	USING GEOMETRY_GRID -- Tessellation Scheme
	WITH
		(  
			BOUNDING_BOX = (xmin = 0, ymin = 0, xmax = 500, ymax = 200),  
			GRIDS = (LOW, LOW, MEDIUM, HIGH), -- Grid Density 
			CELLS_PER_OBJECT = 64 -- Cells per Object
		);
GO

CREATE SPATIAL INDEX SIndx_SpatialGeometryTable_Geometry_Col3  
	ON SpatialGeometryTable(Geometry_Col)  
	WITH
		(  
			BOUNDING_BOX = (0, 0, 500, 200),  
			GRIDS = (LEVEL_4 = HIGH, LEVEL_3 = MEDIUM)
		);
GO

SP_HELPINDEX 'SpatialGeometryTable';
GO

SELECT OBJECT_NAME(object_id), * FROM sys.spatial_indexes;
GO

SELECT * FROM sys.spatial_index_tessellations;
GO
--------------------------------------------------------------------

/*
Creating a spatial index on a geography column
*/

DROP TABLE IF EXISTS SpatialGeographyTable;
GO

CREATE TABLE SpatialGeographyTable
	(
		ID INT PRIMARY KEY,
		Geography_Col GEOGRAPHY
	); 
GO

CREATE SPATIAL INDEX SIndx_SpatialGeographyTable_Geography_Col1
	ON SpatialGeographyTable(Geography_Col);
GO

CREATE SPATIAL INDEX SIndx_SpatialGeographyTable_Geography_Col2  
	ON SpatialGeographyTable(Geography_Col)  
	USING GEOGRAPHY_GRID  -- Tessellation Scheme
	WITH
		(  
			GRIDS = (MEDIUM, LOW, MEDIUM, HIGH), -- Grid Density 
			CELLS_PER_OBJECT = 64 -- Cells per Object
		);
GO

CREATE SPATIAL INDEX SIndx_SpatialGeographyTable_Geography_Col3  
	ON SpatialGeographyTable(Geography_Col)  
	WITH
		(
			GRIDS = (LEVEL_3 = HIGH, LEVEL_2 = HIGH)
		);
GO

SP_HELPINDEX 'SpatialGeographyTable';
GO

SELECT * FROM sys.spatial_indexes;
GO

SELECT * FROM sys.spatial_index_tessellations;
GO
--------------------------------------------------------------------

USE AdventureWorks2019;
GO

DECLARE @G GEOGRAPHY = 'POINT(-121.626 47.8315)'; 
SELECT
	TOP(7) SpatialLocation, City
FROM Person.Address 
	WHERE SpatialLocation.STDistance(@G) IS NOT NULL 
ORDER BY SpatialLocation.STDistance(@G);
GO

DROP INDEX IF EXISTS IX_Address_SpatialLocation ON Person.Address;
GO

CREATE SPATIAL INDEX IX_Address_SpatialLocation
	ON Person.Address(SpatialLocation);
GO

DECLARE @G GEOGRAPHY = 'POINT(-121.626 47.8315)'; 
SELECT
	TOP(7) SpatialLocation, City
FROM Person.Address 
	WHERE SpatialLocation.STDistance(@G) IS NOT NULL 
ORDER BY SpatialLocation.STDistance(@G);
GO

DECLARE @G GEOGRAPHY = 'POINT(-121.626 47.8315)'; 
SELECT
	TOP(7) SpatialLocation, City
FROM Person.Address WITH(INDEX(0))
	WHERE SpatialLocation.STDistance(@G) IS NOT NULL 
ORDER BY SpatialLocation.STDistance(@G);
GO
--------------------------------------------------------------------

/*
Bounding Box روش مناسب برای یافتن اعداد مناسب برای
*/

USE Spatial_DB;
GO

DECLARE @BoundingBox GEOMETRY;
SELECT @BoundingBox = geometry::EnvelopeAggregate(Geom_Column) FROM Polygons;

SELECT @BoundingBox.STBuffer(.1)
UNION ALL
SELECT Geom_Column FROM Polygons;

SELECT
	FLOOR(@BoundingBox.STPointN(1).STX) AS Xmin,
	FLOOR(@BoundingBox.STPointN(1).STY) AS Ymin,
	CEILING(@BoundingBox.STPointN(3).STX) AS Xmax,
	CEILING(@BoundingBox.STPointN(3).STY) AS Ymax;
GO
--------------------------------------------------------------------

/*
Methods Supported by Spatial Indexes
https://docs.microsoft.com/en-us/sql/relational-databases/spatial/spatial-indexes-overview?view=sql-server-ver15
*/