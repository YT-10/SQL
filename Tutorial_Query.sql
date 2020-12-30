--SQL

/* 
Author: Yusuf Tatlier

WHAT IS SQL 

SQL (Structured Query Language) is the standard language for relational database management.
SQL is a declarative language rather than an imperative language, which means that you state what needs to happen
rather than how it needs to be performed. In SQL requests can be made, in the form of queries, within a relational
DBMS.
There are different SQL dialects, T-SQL (Transact SQL) is the dialect for Microsoft DBMS.

SQL consists of different sub-languages as also can be seen from difference in syntax of queries:
- Data Definition Language: CREATE, DROP and ALTER requests (Example: CREATE TABLE TABLE_NAME AS ...)
- Data Modification Language: INSERT, DELETE, UPDATE (Example: INSERT INTO TABLE_NAME ...)
- Data Control Language: SELECT (Example: SELECT FROM TABLE_NAME ...)


RELATIONAL DATABASES AND NORMALIZATION

The key concept for relational databases is that they are basically tables with unique identifiers, known as keys,
and possible references to other tables, known as foreign keys, in order to link tables.

Data is ideally normalized, i.e. systematically decomposed into multiple tables rather than stored in a single big table, 
in order to reduce or eliminate data redundancy. In this way the following issues, also known as anomalies, can be avoided:
	- When having recurring data objects all columns need to be re-supplied instead of only new/relevant ones
	- When deleting data rows need to be deleted rather than simply breaking links but preserving the data
	- When inserting new data, a lot of 'null' values might have to be supplied

In constructing a new database the following normalization rules (or forms) are typically used:
	- 1 Normalization Form (1NF): Each table contains a single value, no attribute is repeated and all rows are unique.
								  This condition prevents horizontal repetition.
	- 2NF: 1NF + Non-key columns are dependent on the table's primary key. This condition prevents vertical repetition.
	- ...

*/


--1. Create and fill a table

CREATE DATABASE Tutorial;

--See that database is created
SELECT * FROM Sys.Tables;

CREATE TABLE World(
	c_id INT IDENTITY(1,1) NOT NULL,
	name CHAR(20) NOT NULL,
	n_population INT,
	area INT,
	continent CHAR(20));

--See that table is created
SELECT * FROM World;

--INSERT INTO is only intended for new insert, not updates.
--The collection of fields for insertion can be specified.

INSERT INTO World
VALUES('Netherlands','15','40','Europe'),
	  ('Bulgaria','7','110','Europe'),
	  ('Germany','80','357','Europe'),
	  ('Turkey','80','800','Europe'),
	  ('Brazil','208','3200','South-America'),
	  ('Canada','36','10000','North-America'),
	  ('US','325','10000','North-America'),
	  ('China','1500','9600','Asia'),
	  ('Japan','150','127','Asia'),
	  ('Korea','77','217','Asia');

--Update one value
INSERT INTO World(name)
VALUES('Argentina');

--Print entire table
SELECT * FROM World;

--Delete
DROP TABLE World;

--Modify Table Structure: Note that ALTER operator goes together with ADD
ALTER TABLE World
ADD capital CHAR(20); 

ALTER TABLE World
DROP COLUMN capital; 

ALTER TABLE World
ADD capital CHAR(20); 

--2.Updating table (Object type is not required): NOTE UPDATE operator goes together with SET
-- We erreneously update all rows
UPDATE World
SET capital ='Amsterdam';

SELECT * FROM WORLD;

--Empty on column
UPDATE World
SET capital =''
WHERE name='Netherlands';

--DELETE all records satisfying condition
DELETE FROM WORLD
WHERE c_id = 11;

-- So remember 
-- a. ALTER ADD, ALTER DROP
-- b. UPDATE SET WHERE, DELETE FROM WHERE

--3.Creating foreign keys

ALTER TABLE WORLD
ADD CONSTRAINT PK_cid PRIMARY KEY (c_id);

ALTER TABLE WORLD
ADD CONSTRAINT Cont_check CHECK (continent IN ('Europe','North-America','Asia','South-America','Africa','Oceania'));

--INSERT adheres to constraint
INSERT INTO WORLD (name,continent)
VALUES('Vietnam','Asia');

--Constraint is violated and table is not updated
INSERT INTO WORLD (name,continent)
VALUES('Thailand','Asiaa');

SELECT * FROM WORLD;

--Important is FOREIGN KEY (att_name) REFERENCES foreign_table_name(foreign_field_name)
CREATE TABLE Cities(
	id INT IDENTITY(1,1),
	c_id INT,
	city CHAR(20),
	CONSTRAINT World_FK FOREIGN KEY (c_id) REFERENCES WORLD(c_id));

INSERT INTO Cities
Values(1,'Amsterdam'),
	  (1,'Den Haag'),
	  (1,'Rotterdam'),
	  (2,'Sofia'),
	  (4,'Ankara'),
	  (4,'Sivas'),
	  (4,'Istanbul'),
	  (3,'Berlin'),
	  (6,'Vancouver'),
	  (7,'New York'),
	  (7,'Washington'),
	  (9,'Osaka');

SELECT * FROM Cities;

--4. Joins

--Inner Join

SELECT WORLD.c_id,name,Cities.city INTO World_Cities_Join
FROM WORLD INNER JOIN Cities
ON WORLD.c_id=Cities.c_id; 

SELECT * FROM World_Cities_Join;

--Left Join
SELECT WORLD.c_id,name,Cities.city 
FROM WORLD LEFT JOIN Cities
ON WORLD.c_id=Cities.c_id; 

SELECT * FROM Sys.Tables;

--5.Saving Intermediate results

--a. SELECT column_1,...,column_n INTO New_Table_Name: Saves a query as a new table
--b. Save as a view

CREATE VIEW World_Cities_View AS
SELECT WORLD.c_id,name,Cities.city 
FROM WORLD LEFT JOIN Cities
ON WORLD.c_id=Cities.c_id; 

SELECT * FROM [dbo].[World_Cities_View];

--c. Stored Procedures
CREATE PROCEDURE World_Cities_Procedure AS
SELECT WORLD.c_id,name,Cities.city 
FROM WORLD LEFT JOIN Cities
ON WORLD.c_id=Cities.c_id; 

--d. Temporary Tables 
SELECT WORLD.c_id,name,Cities.city INTO #Temptable_World_Cities
FROM WORLD LEFT JOIN Cities
ON WORLD.c_id=Cities.c_id; 


--5. Queries

--Find all countries in Europe
SELECT name FROM WORLD
WHERE continent='Europe';

--Count present countries per continent
--Be careful that aggregations can also be used without a GROUP BY (!), in this case the total set is used (once)
SELECT continent,COUNT(name) AS country_count FROM WORLD
GROUP BY continent
ORDER BY country_count DESC;

--Show the Alphabetically last country per continent
--Note that this is a correlated query, things to look for:
--	a. Correlated sub-queries want rows per grouping, instead of aggregations
--  b. Name sub-queries and compare them
--  c. Don't use a grouping, the inner sub-query should give a identifier that is searched by outer query (!).
--     Using Max() function, or ANY/ALL operators      
SELECT continent,name
FROM WORLD AS X
WHERE name = (SELECT MAX(name) 
	   FROM WORLD AS Y
	   WHERE X.continent=Y.continent);
