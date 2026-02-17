-- Trade Value DataWarehouse
SELECT TOP (5) * FROM [dbo].[Fact_Trade]
SELECT top (5) * FROM [dbo].[Dim_Trade_Group]
SELECT top (5) * FROM [dbo].[Dim_Country]
SELECT top (5) * FROM [dbo].[Dim_Trade_Type]
SELECT top (5) * FROM [dbo].[Dim_Date]

-- TABLE 1 - Fact_Trade
Country_ID	Trade_Group_ID	Trade_Type_ID	Date_ID	Trade_Value
1	        1	            1	            121	    19720922399.00
1	        1	            1	            122	    24657986678.00
1	        1	            1	            123	    26317587654.00
1	        1	            1	            124	    24770317928.00
1	        1	            1	            125	    25910669239.00

-- TABLE 2 - Dim_Trade_Group
Trade_Group_Id     Trade_Group_Name	           Trade_Group_Description	                                                                                Trade_Group_Category	  IS_EU_Related_Group
1	            Intra EU 27	                  Trade activities occurring between the 27 member states of the European Union.	                        Internal EU Trade	         1
2	            Extra EU 27	                  Trade activities occurring between the European Union (27 member states) and countries outside the EU.  External EU Trade	         1
3	            All Countries of World	           Trade activities encompassing all countries globally, without specific regional focus.	                 Global Trade	         0
4	            North American Trade	           Trade activities involving countries within North America.	                                             Regional Trade	         0
5	            Asia-Pacific Trade	           Trade activities involving countries in the Asia-Pacific region.	                                      Regional Trade	         0

-- TABLE 3 - Dim_Country
Country_ID	Country_Name	        Country_ISO_Code	  Is_EU_Member	Continent
1	        Belgium	        BEL	                1	              Europe
2	        Bulgaria	        BGR	                1	              Europe
3	        Cyprus	        CYP	                1	              Europe
4	        Czechia	        CZE	                1	              Europe
5	        Germany	        DEU	                1	              Europe

-- TABLE 4 - Dim_Trade_Type
Trade_Type_ID	Trade_Type_Name	    Trade_Direction	    Trade_Activity_Role	    Domestic_Inventory_Impact
1	            IMPORT	            Inbound	           Acquisition	           Increases Stock
2	            EXPORT	            Outbound	           Provision	                  Decreases Stock

-- TABLE 5 - Dim_Date
Date_ID	Date_Month	    Date_Year	Date_Quarter	IS_Current_Year
121	    January	           2021	    1	            0
122	    January	           2022	    1	            0
123	    January	           2023	    1	            0
124	    January	           2024	    1	            0
125	    January	           2025	    1	            1


-- SQL Aliasing

-- Clause	       Table Aliases?	Column Aliases?	Why?
-- FROM / JOIN	Yes ✓	              No ✗	              This is where Table aliases are born.
-- WHERE	       Yes ✓	              No ✗	              Occurs before SELECT defines column aliases.
-- GROUP BY	       Yes ✓	              No ✗	              Occurs before SELECT defines column aliases.
-- HAVING	       Yes ✓	              No ✗	              Occurs before SELECT defines column aliases.
-- SELECT	       Yes ✓	              Yes ✓	              This is where Column aliases are born.
-- ORDER BY	       Yes ✓	              Yes ✓	              Occurs after SELECT, so it sees everything.

-- Column Aliasing
SELECT TOP (10) 
       [Country_ID] C_ID
      ,[Country_Name] C_Name
      ,[Country_ISO_Code] C_ISO_Code
      ,[Is_EU_Member] C_IS_Member
      ,[Continent] C_Continent
  FROM [dbo].[Dim_Country]
  WHERE [Is_EU_Member] = 1 -- Aliasing invalid in WHERE CLAUSE so use original column
  ORDER BY C_Name ASC -- Aliasing is Valid in ORDER BY CLAUSE so use alias name

-- Table Aliasing
-- TradeGroup is the alias name for the table dbo.Dim_Trade_Group
-- Fact is the alias name for the table dbo.Fact_Trade
SELECT TradeGroup.Trade_Group_Name , TradeGroup.Trade_Group_Category , Fact.Trade_Value 
FROM dbo.Dim_Trade_Group TradeGroup
JOIN dbo.Fact_Trade Fact
ON TradeGroup.Trade_Group_Id = Fact.Trade_Group_ID

-- Aliasing can be used on GROUP BY CLAUSE also the number of columns in select should match the number of columns in the group by clause.
SELECT TradeGroup.Trade_Group_Name , TradeGroup.Trade_Group_Category , Fact.Trade_Value 
FROM dbo.Dim_Trade_Group TradeGroup
JOIN dbo.Fact_Trade Fact
ON TradeGroup.Trade_Group_Id = Fact.Trade_Group_ID
GROUP BY TradeGroup.Trade_Group_Name , TradeGroup.Trade_Group_Category , Fact.Trade_Value 


-- ORDER OF QUERY EXECUTION

-- Step	Clause	              What happens?
-- 1	       FROM / JOIN	       The engine identifies the source tables and performs joins. Table aliases are born here.
-- 2	       WHERE	              Rows are filtered based on your conditions. (Cannot see Column Aliases).
-- 3	       GROUP BY	       The remaining rows are gathered into groups. (Cannot see Column Aliases).
-- 4	       HAVING	              Entire groups are filtered out (e.g., HAVING SUM(Value) > 100).
-- 5	       SELECT	              The engine finally looks at which columns to return. Column aliases are born here.
-- 6	       DISTINCT	       Duplicate rows are removed from the result set.
-- 7	       ORDER BY	       The final set is sorted. (Finally sees Column Aliases!)
-- 8	       TOP / OFFSET	       The engine limits how many rows are actually sent back to you.

SELECT 
    TG.Trade_Group_Category AS Category,    -- Step 5: Name it "Category"
    SUM(F.Trade_Value) AS Total             -- Step 5: Name it "Total"
FROM dbo.Dim_Trade_Group AS TG              -- Step 1: Call this table "TG"
JOIN dbo.Fact_Trade AS F                    -- Step 1: Call this table "F"
  ON TG.Trade_Group_Id = F.Trade_Group_ID
WHERE F.Date_ID > 125                       -- Step 2: Filter raw rows
GROUP BY TG.Trade_Group_Category            -- Step 3: Group the data
HAVING SUM(F.Trade_Value) > 26317587654.00  -- Step 4: Filter the groups
ORDER BY Total DESC;                        -- Step 7: Sort by the alias "Total"
