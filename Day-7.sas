________________________________________
?? Mini Project #1: Sales Data Exploration & Reporting
?? Scenario:
You’ve been hired as a data analyst by a retail company to help them understand sales performance across different regions, months, and product 
categories.
________________________________________
?? Dataset: retail_sales
Here’s a sample structure (you can create it with DATALINES):
Order_ID	Region	Category	Product	Sales	Quantity	Order_Date
1001	North	Electronics	Mobile	15000	2	10JAN2023
1002	South	Clothing	Jeans	3000	3	15JAN2023
1003	East	Grocery	Rice	800	5	20JAN2023
1004	North	Electronics	Laptop	50000	1	25JAN2023
1005	West	Grocery	Flour	1000	4	05FEB2023
1006	East	Clothing	Shirt	2000	2	10FEB2023
________________________________________
? Tasks:
?? 1. Data Preparation
•	Import or manually create the dataset using DATALINES.
•	Use appropriate informats for Order_Date.

DATA Retail_Sales;
INFILE "D:\Practice\SAS\Chat-GPT Daily\Retail Sales.csv" DSD DLM="," FIRSTOBS=2;
INPUT Order_ID Region$ Category : $12. Product : $10. Sales Quantity Order_Date : Date9.;
INFORMAT Order_Date DDMMYY10.;
FORMAT Order_Date DDMMYY10.;
RUN;
________________________________________
?? 2. Data Cleaning
•	Ensure Sales and Quantity are numeric.
•	Add a new column: Unit_Price = Sales / Quantity
•	Add a Month variable from Order_Date.

DATA Retail_Sales_Cleaning;
SET Retail_Sales;
IF MISSING(Sales) OR MISSING(Quantity) THEN PUT "Missing Numeric Value For Order_ID=" Order_ID;
IF Quantity > 0 THEN Unit_Price = Sales / Quantity;
ELSE Unit_Price = .;
Month=Put(Order_Date, MONNAME3.);
RUN;
PROC PRINT DATA = Retail_Sales_cleaning;
TITLE "Cleaned Retail Sales With Unit Price And Month";
RUN;

________________________________________
?? 3. Summary Statistics
•	Use PROC MEANS to get:
o	Average Sales by Region
o	Total Quantity by Category

PROC MEANS DATA = Retail_Sales_Cleaning MEAN MAXDOC=2;
CLASS Region;
VAR Sales;
RUN;
PROC MEANS DATA = Retail_Sales_Cleaning MEAN MAXDOC=2;
CLASS Category;
VAR Quantity;
RUN;
________________________________________
?? 4. Transpose and Compare
•	Use PROC TRANSPOSE to reshape:
o	Categories as columns with total sales as values.
o	One row per Region.

PROC SQL;
CREATE TABLE Region_Category_Sales AS
SELECT Region, Category, SUM(Sales) AS Total_Sales
FROM Retail_Sales_Cleaning
GROUP BY Region, Category;
QUIT;
PROC TRANSPOSE DATA = Region_Category_Sales OUT= Transpose_Sale (DROP=_NAME_);
BY Region;
ID Category;
VAR Total_Sales;
RUN;
PROC PRINT DATA = Transpose_Sale;
TITLE "Total Sales by Region and Category (Transposed)";
RUN;
________________________________________
?? 5. Advanced Reporting
•	Use PROC REPORT or PROC TABULATE to show:
o	Total Sales by Region and Category
o	Include row totals and column totals
o	Format the sales in currency (dollar10.2)

PROC REPORT DATA = Retail_Sales_Cleaning;
COLUMN Region Sale Category;
DEFINE Region / Group;
DEFINE Sales / ANALYSIS SUM FORMAT = DOLLAR10.2 "Total Sale";
RBREAK AFTER / SUMMARIZE DOL;
TITLE "Total Sale By REgion";
RUN;

PROC TABULATE DATA = Retail_Sales_Cleaning FORMAT = DOLLAR10.2;
CLASS Region Category;
VAR Sales;
TABLE Region ALL,
Category ALL * Sales * SUM = "Total Sales";
TITLE "Total Sales By Region And Category (With Totals";
RUN;
________________________________________
?? 6. Optional Enhancements
•	Highlight orders where Unit_Price > 10000
•	Identify the best-selling product in each Region using FIRST. or SORT

DATA Flagged_Sales;
SET Retail_Sales_Cleaning;
IF Unit_Price > 10000 THEN High_Price_Flag = "Yes";
ELSE High_Price_Flag= "No";
RUN;

PROC PRINT DATA = Flagged_Sales;
WHERE High_Price_Flag= "Yes";
TITLE "Orders with Unit Price > 10000";
RUN;
