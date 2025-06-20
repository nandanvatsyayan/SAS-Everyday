## ?? **Conceptual Questions (Day 3)**

1. **What is the difference between `WHERE` and `IF` in SAS? When would you use one over the other?**
Ans:-	WHERE - The WHERE statement is used to filter data as it is being read from a dataset. It works only on variables that already exist in 
		the incoming dataset. It filters observation before they are bought into the program data vector.

		IF - The "IF" statement is used to filter data after it is read into the PDV(Program data vector). It can be used with newaly created
		variables or those modified in Data step.

2. **What is the function of the `BY` statement in `PROC SORT` and `DATA` steps?**
Ans:-	"PROC SORT" - In proc sort "BY" statement sorts the dataset according to the variables name that is given with "BY" statement.

		"DATA STEP" - The "BY" statement in a DATA step is used to enable group-wise processing.It activates the special automatic variables: 
		FIRST.variable and LAST.variable for each BY group. These variables help you detect the beginning and end of each group for logic like 
		subtotaling, flagging, or resetting counters.
		
3. **Explain what a `MERGE` does in SAS. How is it different from a `SET`?**
Ans:- 	"MERGE"- The MERGE statement in SAS is used to combine datasets horizontally — that is, it joins two or more datasets by matching 
		observations based on common values of one or more BY variables. To use MERGE, the datasets must be sorted by the "BY" variables. 
		Should share common a common key variable for matching observation. 

		"SET" - The SET statement stacks datasets vertically — it reads all observations from the first dataset, then from the second, and so 
		on, appending rows one after another.

4. **What are first. and last. variables in SAS? In which situations are they useful?**
Ans:- 	The first. and last. variables are temporary automatic variables that are created when you use a BY statement in a DATA step. These 
		variables help identify the first and last observation within each BY-group in a sorted dataset. They are useful for group-wise processing, 
		such as: Creating total or subtotal by group, flagging start and end of a group, performing cumulative calculations or counting records 
		within group.

5. **What does `PROC CONTENTS` do? What useful information can you get from it?**
Ans:-	PROC CONTENTS in SAS is used to display metadata about a dataset — that is, information about the structure of the dataset rather than 
		the data itself. It is a diagnostic and documentation tool that helps users understand what variables are in a dataset, their types, 
		lengths, formats, and the dataset properties like number of observations, date created, and more.
---

## ?? **Coding Practice (Day 3)**

### ?? **Problem 1: WHERE vs IF**

Create a dataset named `orders` using the following data:

| OrderID | Region | Amount |
| ------- | ------ | ------ |
| 1001    | North  | 5000   |
| 1002    | South  | 4500   |
| 1003    | North  | 7000   |
| 1004    | West   | 3500   |
| 1005    | South  | 6500   |

? **Tasks**:

* Use `IF` to create a new dataset with only North region orders.
* Use `WHERE` to create a new dataset with only South region orders.

DATA ORDERS;
INPUT OrderID	Region$	Amount;
DATALINES;
1001	North	5000
1002	South	4500
1003	North	7000
1004	West	3500
1005	South	6500
;
RUN;

DATA North_Region_Orders;
SET ORDERS;
IF Region = 'North';
RUN;

DATA North_Region;
SET ORDERS;
WHERE Region = 'North';
RUN;
---

### ?? **Problem 2: Sorting and Group Processing**

Using the `orders` dataset:

? **Tasks**:

* Sort by `Region` and `Amount` using `PROC SORT`.
* Use `BY Region` in a `DATA` step to find the **first and last order** in each region. Create a new variable indicating this.

PROC SORT DATA = ORDERS;
BY Region Amount;
RUN;
PROC PRINT DATA = ORDERS;
RUN;


DATA BY_REGION;
SET ORDERS;
BY Region;

IF FIRST.Region THEN ORDER_POSITION = 'FIRST';
ELSE IF LAST.Region THEN ORDER_POSTION = "LAST";
ELSE ORDER_POSTION = "MIDDILE";
RUN;
PROC PRINT DATA = BY_REGION;
RUN;
---

### ?? **Problem 3: Merging Datasets**

You have two datasets:

**customers**

| CustID | Name   | City   |
| ------ | ------ | ------ |
| 101    | Raj    | Mumbai |
| 102    | Anita  | Delhi  |
| 103    | Sameer | Pune   |

**transactions**

| CustID | OrderID | Amount |
| ------ | ------- | ------ |
| 101    | 1001    | 5000   |
| 103    | 1002    | 7000   |
| 104    | 1003    | 6000   |

? **Task**:

* Merge `customers` and `transactions` by `CustID`.
* Handle the missing values and check who did not place any order.

DATA Customers;
INPUT CustID	Name$	City$;
DATALINES;
101	Raj	Mumbai
102	Anita	Delhi
103	Sameer	Pune
;
RUN;
PROC SORT DATA = Customers;
BY CustID;
RUN;

DATA Transactions;
INPUT CustID	OrderID	Amount;
DATALINES;
101	1001	5000
103	1002	7000
104	1003	6000
;
RUN;
PROC SORT DATA = Transactions;
BY CustID;
RUN;

DATA Merged;
MERGE Customers(IN=InCust)
Transactions(IN=InTrans);
BY CustID;
IF InCust AND NOT InTrans THEN ORDERSTATUS = "NO ORDER";
ELSE IF InCust AND InTrans THEN ORDERSTATUS = "ORDERED";
ELSE IF NOT InCust AND InTrans THEN ORDERSTATUS="UNKOWN CUSTOMER";
RUN;
PROC PRINT DATA = Merged;
RUN;

---

### ?? **Problem 4: PROC CONTENTS & Variable Metadata**

Create a dataset of your choice (or use any from above) and:

? **Tasks**:

* Use `PROC CONTENTS` to view variable details like **type**, **length**, and **label**.
* Add labels to at least 2 variables and re-run `PROC CONTENTS` to verify.

DATA Customers;
INPUT CustID Name $ City $;
DATALINES;
101 Raj Mumbai
102 Anita Delhi
103 Sameer Pune
;
RUN;
PROC CONTENTS DATA = Customers;
RUN;
DATA Customers_Labeled;
SET Customers;
LABEL 
     CustID = "Customer ID"
     City   = "Customer City";
RUN;
PROC CONTENTS DATA=Customers_Labeled;
RUN;




---

### ?? **Problem 5: Creating Summary Statistics**

Using the `transactions` dataset from Problem 3:

? **Tasks**:

* Use `PROC MEANS` to find total and average `Amount`.
* Group the results by `CustID`.
* Use `MAXDEC=1` option to limit decimal places in output.

PROC MEANS DATA= Transactions SUM MEAN MAXDEC=1;
CLASS CustID;
VAR Amount;
RUN;
---


