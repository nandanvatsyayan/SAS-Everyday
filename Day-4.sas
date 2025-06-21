## ?? **Conceptual Questions (Day 4)**

1. **How do `MERGE` and `PROC SQL JOIN` differ in SAS? When should one be preferred over the other?**
Ans:- 	"MERGE" - Merge Combines the dataset Horizontally in SAS by Matching variable. . Data need to be sorted by using "BY" statement  before
		merge. Observations are matched by the position of the Key Value Variable. 

		"PROC SQL JOINS" - Uses SQL syntax to join datasets based common key.Do not require sorting beforehand. Supports all type of joines. 
		INNER JOIN, LEFT JOIN, RIGHT JOIN, OUTER JOIN, FULL JOIN, CORSS JOIN.

2. **What is the difference between `IN=` and `FIRST.`/`LAST.` in merge operations?**
Ans:-	IN= is a temporary variable created during a MERGE operation to identify which dataset(s) contributed to each merged observation.
	
		FIRST.variable and LAST.variable are automatic variables created when using a BY statement in a sorted DATA step.

3. **What are automatic variables in SAS? Name at least 3 with their functions.**
Ans:- 	Automatic variables in SAS are special system-created variables that are not part of the original dataset and not written to the output 
		dataset. They are created and maintained by SAS during the execution of a DATA step to help control the data processing flow. You don’t 
		need to define them — SAS creates them automatically — and you can use them in your code to control logic or monitor processing.

		3 Common Automatic Variables and Their Functions are 

		a)	N - Counts the number of iterations of the DATA step. It starts at 1 and increments by 1 each time the DATA step loops. It is useful for 
				debugging, sampling, or controlling loops.

		b)	ERROR - A flag (0 or 1) that indicates whether an error occurred during the DATA step processing. If an error occurs (e.g., data 
				conversion error), _ERROR_ becomes 1 for that observation. Helpful in debugging complex data transformations.

		c)	FIRST.variable and LAST.variable - Used with BY groups to identify the first and last record for each group. Created automatically 
				when you use a BY statement in a sorted DATA step. Their values are either 1 (true) or 0 (false).
 
4. **Explain the difference between `PROC TABULATE` and `PROC MEANS`.**
Ans:- 	"PROC MEANS" is primarily designed for quick numeric analysis. It computes basic statistics such as mean, sum, minimum, maximum, and 
		standard deviation for numeric variables. It’s simple to use, supports grouping with the CLASS statement, and produces list-style output. 
		However, it is limited to numeric variables and does not offer much control over the layout or formatting of the results.

		PROC TABULATE is a more advanced and flexible reporting tool that allows you to create multi-dimensional summary tables. It can summarize 
		both numeric and categorical variables, display values in a row-and-column format, and present more readable, structured reports. While 
		PROC TABULATE provides better formatting and is suitable for presentation-ready tables, it requires more complex syntax and a stronger 
		understanding of its table-building structure.

5. **What is a `RETAIN` statement? Why is it useful in data transformation?**
Ans:-	The RETAIN statement in SAS is used to hold the value of a variable across multiple iterations of the DATA step. By default, SAS sets all 
		variables to missing at the beginning of each iteration. However, when you use RETAIN, the variable keeps its value from the previous 
		iteration unless it is explicitly changed. This is especially useful in data transformation tasks where you want to carry forward values, 
		accumulate totals, or track a condition over time.
---

## ?? **Coding Practice (Day 4)**

### ?? **Problem 1: Conditional Accumulation with RETAIN**

You have the following dataset `sales`:

| Month | Sales |
| ----- | ----- |
| Jan   | 2000  |
| Feb   | 2500  |
| Mar   | 1800  |
| Apr   | 3000  |

? **Tasks**:

* Add a column `Cumulative_Sales` that accumulates sales across months.
* Use the `RETAIN` statement.
DATA SALES;
INPUT Month$ Sales;
DATALINES;
Jan 2000
Feb 2500
Mar 1800
Apr 3000
;
RUN;
DATA SALE_CUMULATIVE;
SET SALES;
RETAIN CUMULATIVE_SALES 0;
CUMULATIVE_SALE + SALES;
RUN;

---

### ?? **Problem 2: PROC SQL JOIN**

Use the same datasets from Day 3: `customers` and `transactions`.

? **Tasks**:

* Join both datasets using `PROC SQL`.
* Display Customer Name, City, OrderID, and Amount.
* Include customers with and without transactions (LEFT JOIN).

DATA Customers;
INPUT CustID	Name$	City$;
DATALINES;
101	Raj	Mumbai
102	Anita	Delhi
103	Sameer	Pune
;
RUN;

DATA Transactions;
INPUT CustID	OrderID	Amount;
DATALINES;
101	1001	5000
103	1002	7000
104	1003	6000
;
RUN;

PROC SQL;
CREATE TABLE CUSTOMER_ORDERS AS 
SELECT C.Name, C.City, T.OrderID, T.Amount
FROM Customers AS C
LEFT JOIN Transactions AS t
ON C.CustID = T.CustID;
QUIT;

---

### ?? **Problem 3: Frequency Distribution with PROC FREQ**

You have this dataset `students`:

| ID | Gender | Grade |
| -- | ------ | ----- |
| 1  | M      | A     |
| 2  | F      | B     |
| 3  | F      | A     |
| 4  | M      | C     |
| 5  | F      | B     |
| 6  | M      | B     |

? **Tasks**:

* Create the dataset using `DATALINES`.
* Use `PROC FREQ` to generate a 2-way frequency table of `Gender*Grade`.
* Include row and column percentages.

DATA STUDENTS;
INPUT ID Gender$	Grade$;
DATALINES;
1	M	A
2	F	B
3	F	A
4	M	C
5	F	B
6	M	B
;
RUN;
PROC FREQ DATA = STUDENTS;
TABLES Gender*Grade / NOROW NOCOL NOPERCENT;
RUN;
PROC FREQ DATA = STUDENTS;
TABLES Gender*Grade / NOCOL NOPERCENT;
RUN;
PROC FREQ DATA = STUDENTS;
TABLES Gender*Grade / NOROW NOPERCENT;
RUN;
PROC FREQ DATA = STUDENTS;
TABLES Gender*Grade / NOPERCENT;
RUN;
---

### ?? **Problem 4: Group Summary using PROC TABULATE**

Using the same `students` dataset:

? **Tasks**:

* Use `PROC TABULATE` to show:

  * Number of students by `Gender`
  * Distribution of Grades by Gender
* Format the output neatly with titles and labels.

PROC TABULATE DATA = STUDENTS;
CLASS Gender Grade;
TITLE "SUMMARY OF THE STUDENTS BY GENDER AND GRADE";
TABLE Gender 
ALL = "TOTAL STUDENTS", 
N = "COUNT" Grade = "GRADE DISTRIBUTION" * N = "" / BOX = "Gender";
RUN;
---

### ?? **Problem 5: Subsetting with IN= in Merge**

You have:

**dataset1**

| ID | Value1 |
| -- | ------ |
| 1  | A      |
| 2  | B      |
| 3  | C      |

**dataset2**

| ID | Value2 |
| -- | ------ |
| 2  | X      |
| 3  | Y      |
| 4  | Z      |

? **Tasks**:

* Merge the datasets using `IN=`.
* Create a third dataset:

  * Include only observations present in both datasets.
  * Then modify to keep only those present **only** in `dataset1` but not `dataset2`.

DATA DATASET1;
INPUT ID Value1$;
DATALINES;
1	A
2	B
3	C
;
RUN;
DATA DATASET2;
INPUT ID Value2$;
DATALINES;
2	X
3	Y
4	Z
;
RUN;
DATA BOTH;
MERGE DATASET1(IN=IN1) DATASET2(IN=IN2);
BY ID;
IF IN1 AND NOT IN2;
RUN;
---


