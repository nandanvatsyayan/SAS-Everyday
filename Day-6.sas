?? Conceptual Questions (Day 6)
1.	What is the purpose of the ARRAY statement in SAS? How is it useful?
Ans:- 	The ARRAY statement in SAS is used to group a set of related variables under a single name so that you can perform repetitive operations on 
		them more efficiently. Instead of writing the same code for each variable individually, arrays allow you to use loops to apply logic across 
		multiple variables with minimal code.

2.	How does PROC TRANSPOSE handle multiple ID variables vs one?
Ans:-	In SAS, `PROC TRANSPOSE` reshapes data by turning rows into columns, and the `ID` statement plays a key role in defining how those new 
		column names are generated. When you use a single `ID` variable, each unique value of that variable becomes a column in the transposed 
		output. For instance, if you have a dataset with student names, subjects, and scores, and you use `Subject` as the `ID` variable, the 
		resulting dataset will have one row per student and separate columns for each subject containing the corresponding scores. This is 
		straightforward and produces clean, readable output.

		However, when you use multiple `ID` variables, SAS combines the values of those variables to generate column names. This is useful when 
		your data involves multiple dimensions, such as year and quarter, and you want each combination to appear as a separate column. In this 
		case, the column names in the output dataset are formed by concatenating the values of the multiple ID variables. While this provides 
		flexibility for more complex data structures, it can result in long or unintuitive column names that may need to be cleaned or renamed 
		afterward.

		In summary, using a single `ID` variable creates columns based on individual categories, while using multiple `ID` variables creates 
		columns for combinations of categories. The former is simpler and easier to manage, whereas the latter is powerful for representing 
		multidimensional data but may require additional steps for output formatting.

3.	What is the difference between INPUT function and PUT function in SAS?
Ans:-	INPUT - The INPUT function is used to convert character values into numeric or date values using an informat. This is particularly useful 
		when raw data is read as text but needs to be interpreted as a number or date for further analysis. For example, if a variable contains a 
		character string like "100" or "12JAN2024", you can use INPUT to convert it to a numeric or date value, respectively. 

		PUT - The PUT function does the reverse of INPUT—it converts numeric or date values into character strings using a format. This is often 
		used when preparing data for reports, labels, or exporting, where values need to be presented in a human-readable form. For example, 
		turning a numeric salary value like 50000 into "50,000" using a comma format, or converting a date into "12Jan2024". The syntax usually 
		looks like:


4.	Explain the use of automatic _N_ and _ERROR_ variables.
Ans:=	_N_ - The _N_ variable keeps track of the number of iterations of the DATA step. In simple terms, it tells you the row number currently 
		being processed. This can be helpful when you want to perform actions at a specific iteration or if you want to include a counter in your 
		data. For example, you might use _N_ = 1 to execute something only for the first observation, or use it to generate a unique ID for each 
		row.

		_ERROR_ - The _ERROR_ variable is a logical flag that helps in error detection. It has a value of 0 when no error occurs in the DATA step 
		during an iteration, and changes to 1 if there is a data-related error, such as trying to convert invalid data types. This is especially 
		useful when you want to create custom error messages or log problematic rows during data cleaning or importing. Together, _N_ and _ERROR_ 
		provide a powerful way to monitor and control the flow of a DATA step.

5.	What are some common ways to debug errors in a SAS program?
Ans:-	To debug errors in a SAS program, start by carefully reviewing the **SAS log**, which highlights syntax and data-related issues. Use 
		automatic variables like **`_ERROR_`** to flag problematic observations and **`_N_`** to track iteration counts. Insert **`PUT` 
		statements** to print variable values during execution, helping you trace logic errors. Procedures like **`PROC PRINT`** and **`PROC 
		CONTENTS`** help verify data structure and formats. When merging datasets, ensure they are **sorted correctly** and use **`IN=`** and 
		**`BY`** to control the merge process. Lastly, test your code in **small chunks** to isolate issues more easily.

________________________________________
?? Coding Practice (Day 6)
?? Problem 1: Using ARRAYS for Data Cleaning
You have this dataset of test scores:
ID	Test1	Test2	Test3
1	75	.	80
2	88	85	.
3	.	78	90
? Tasks:
•	Use an ARRAY to loop over the Test scores.
•	Replace missing scores with 0.
•	Calculate a new variable Total.


DATA SCORE;
INPUT ID TEST1 TEST2 TEST3;
DATALINES;
1 75 . 80
2 88 85 .
3 . 78 90
;
RUN;

DATA CLEANED_SCORE;
SET SCORE;
ARRAY TESTS[*] TEST1-TEST3;
TOTAL = 0;
DO I = 1 TO DIM(TESTS);
IF TESTS[I]=. THEN TESTS[I]=0;
TOTAL + TESTS[I];
END;
DROP I;
RUN;
PROC PRINT DATA= CLEANED_SCORE;
TITLE "CLEANED TEST SCORES WITH TOTAL";
RUN;

________________________________________
?? Problem 2: INPUT vs PUT Functions
You have the following raw data:
101 "12JAN2023" 45000
? Tasks:
•	Read this using INPUT (with INFORMAT) to create EmpID, JoinDate, and Salary.
•	Create a new variable JoinYear by converting JoinDate to a string using PUT.

DATA EMPLOYEE;
INPUT EmpID	JoinDate DATE9.	Salary;
INFORMAT JoinDate DDMMYY10.;
FORMAT JoinDate DDMMYY10.;
JoinYear = PUT(JoinDate, Year4.);
DATALINES;
101	12JAN2023	45000
;
RUN;
PROC PRINT DATA = EMPLOYEE;
RUN;

________________________________________
?? Problem 3: PROC TRANSPOSE with BY and ID
Input dataset:
Year	Quarter	Revenue
2023	Q1	10000
2023	Q2	12000
2023	Q3	15000
2024	Q1	13000
2024	Q2	14000
? Tasks:
•	Transpose the dataset so each Quarter becomes a column.
•	Use BY Year and ID Quarter.

DATA REVENUE;
INPUT YEAR QUARTER$ REVENUE;
DATALINES;
2023	Q1	10000
2023	Q2	12000
2023	Q3	15000
2024	Q1	15000
2024	Q2	15000
;
RUN;
PROC SORT DATA= REVENUE;
BY YEAR;
RUN;
PROC TRANSPOSE DATA = REVENUE OUT = QUARTERLY_REVENUE(DROP=_NAME_);
BY YEAR;
ID QUARTER;
VAR REVENUE;
RUN;
PROC PRINT DATA = QUARTERLY_REVENUE;
TITLE "Revenue by Quarter Transposed for Each Year";
RUN;
________________________________________
?? Problem 4: Using Character Functions
You have this dataset:
ID	Full_Name
1	"Ravi Kumar"
2	"Anita Sharma"
3	"Priya"
? Tasks:
•	Extract First Name and Last Name using SCAN().
•	If no last name exists, store "NA".

DATA CHARACTER;
INPUT ID FULL_NAME : $20.;
DATALINES;
1 'RAVI KUMAR'
2 'ANITA SHARMA'
3 'PRIYA'
;
RUN;
DATA SPLIT_NAME;
SET CHARACTER;
FIRST_NAME = SCAN(FULL_NAME,1);
LAST_NAME=SCAN(FULL_NAME,2);
IF MISSING (LAST_NAME) THEN LAST_NAME = "NA";
RUN;
PROC PRINT DATA = SPLIT_NAME;
TITLE title "Split First and Last Names";
RUN;
______
__________________________________
?? Problem 5: Generating a Report using PROC REPORT
Using this dataset:
Dept	Employee	Salary
HR	Ria	60000
IT	Amit	75000
HR	Neha	58000
IT	Arjun	77000
? Tasks:
•	Use PROC REPORT to show average salary by Dept.
•	Group by Dept and display totals.
•	Format salary with commas.

DATA SALARY;
INPUT Dept$	Emploee$ Salary;
DATALINES;
HR	Ria	60000
IT	Amit	75000
HR	Neha	58000
IT	Arjun	77000
;
RUN;
PROC REPORT DATA = SALARY nowd;
COLUMN Dept Salary;
DEFINE Dept / Group;
DEFINE Salary / ANALYSIS MEAN FORMAT = COMMA10. "Average Salary";
RBREAK AFTER / SUMMARIZE DOL;
TITLE "AVERAGE SALARY BY DEPT";
RUN; 



