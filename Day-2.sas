## ?? **Conceptual Questions (Day 2)**

1. **What are the different types of variables in SAS? How does SAS distinguish between them?**
Ans:- 	SAS has 2 types of Variables. Numeric & Character. 

		Numeric Variables - Numeric variables store numbers like integer, decimal or scintific notation. It can be used in mathematical operations, 
		agrregation and statistical operations.

		Character Variables - Character variables stores text, strings or alpha numeric data. They are enclosed in quotation marks when assigned
		manually. Character variables can not be used in arthmetic operations.   

		SAS Distinguish it if a variable is read with a $ in an INPUT statement, it is character, otherwise, it is numeric.

2. **What is the difference between a `DATA` step and a `PROC` step?**
Ans:-	Data Step- The DATA step is used when you want to create, read, or modify datasets. It allows you to perform row-wise processing, apply 
		conditional logic, define new variables, clean raw data, and much more.

		Proc step -  The PROC (short for Procedure) step is used to analyze, summarize, manage, or report data using SAS built-in procedures. 
		It performs operations such as sorting, statistical analysis, printing, exporting, frequency counts, and more.

3. **Explain the role of `INFORMAT` and `FORMAT` in SAS. When should each be used?**
Ans:-	INFORMAT - INFORMAT tells SAS how to read or interpret raw data values from an external file or data lines during input. When raw data 
		includes dates, times, or non-standard values, INFORMAT converts them into SAS-recognized internal formats.

		FORMAT - FORMAT tells SAS how to display a variable’s value when printing, reporting, or viewing data.

4. **What does the `KEEP` and `DROP` statement do? Where can you use them?**
Ans:-	KEEP - Keep Statement specifies which variable we want to retain in the final data set. It is used when we need only subset of Variables.

		Drop - Drop statement specifies which variable we want to exclude from final data set. It is useful when we want to drop a few variables
		from many variables.

		We can use them within a DATA Step or as dataset options.
 
5. **What happens if you use `SET` with two datasets in one `DATA` step? What kind of output will it produce?**
Ans:-	When you use the SET statement with two or more datasets in a single DATA step, SAS performs a vertical concatenation (stacking) of the 
		datasets. This means it reads all observations from the first dataset, then all observations from the second, and so on — one after 
		another — and combines them into a single output dataset. 


		Output will be 
			- The resulting dataset will have the combined number of rows (observations) from all the input datasets.

			- SAS will include all variables that exist in any of the input datasets.

			- If a variable exists in one dataset but not the other, its value will be missing for the observations where it is not present.
---

## ?? **Coding Practice (Day 2)**

### ?? **Problem 1: Using INFORMAT and FORMAT**

You have data in this form:

```
101 12/06/2024 3500
102 15/06/2024 4600
103 20/06/2024 2900
```

? **Task**:

* Read this into a dataset named `payments` with variables `ID`, `Pay_Date` (date), and `Amount`.
* Assign the proper `INFORMAT` to read the date and a `FORMAT` to display it as `ddmmmyy10.`.

DATA PAYMENTS;
INPUT ID	PAY_DATE DDMMYY10.	AMOUNT;
INFORMAT PAY_DATE DDMMYY10.;
FORMAT PAY_DATE DDMMYY10.; 
DATALINES;
101	12/06/2024	3500
102	15/06/2024	4600
103	20/06/2024	2900
;
RUN;

---

### ?? **Problem 2: KEEP and DROP**

Using the `payments` dataset:

? **Task**:

* Create a new dataset `pay_summary` that includes only `ID` and `Amount`.
* Use both `KEEP` and `DROP` in two different approaches to achieve the same result.

DATA PAYMENTS;
INPUT ID	PAY_DATE DDMMYY10.	AMOUNT;
KEEP ID AMOUNT;
DATALINES;
101	12/06/2024	3500
102	15/06/2024	4600
103	20/06/2024	2900
;
RUN;

DATA PAYMENTS2;
INPUT ID	PAY_DATE DDMMYY10.	AMOUNT;
DROP PAY_DATE;
DATALINES;
101	12/06/2024	3500
102	15/06/2024	4600
103	20/06/2024	2900
;
RUN;

---

### ?? **Problem 3: Concatenating Datasets**

You have two datasets:

**sales\_q1**

| ID | Month | Sales |
| -- | ----- | ----- |
| 1  | Jan   | 2000  |
| 2  | Feb   | 2200  |

**sales\_q2**

| ID | Month | Sales |
| -- | ----- | ----- |
| 3  | Apr   | 2100  |
| 4  | May   | 2500  |

? **Task**: Combine both datasets using `SET` to create a single dataset `sales_h1`.

DATA SALES_Q1;
INPUT ID MONTH$ SALES;
DATALINES;
1	JAN	2000
2	FEB	2200
;
RUN;

DATA SALES_Q2;
INPUT ID MONTH$ SALES;
DATALINES;
3	APR	2100
4	MAY	2500
;
RUN;
DATA SALES_H1;
SET SALES_Q1 SALES_Q2;
RUN;

---

### ?? **Problem 4: Conditional Logic with IF-THEN-ELSE**

Use the `sales_h1` dataset:

? **Task**:
Add a new column called `Bonus`:

* If Sales = 2300 ? Bonus = 300
* If Sales between 2000 and 2299 ? Bonus = 200
* Else ? Bonus = 100

DATA SALE_BONUS;
SET SALES_H1;
IF SALES >= 2300 THEN BONUS = 300;
ELSE IF 2000 <= SALES < 2300 THEN BONUS = 200;
ELSE BOUNS = 100;
RUN;
---

### ?? **Problem 5: PROC FREQ and PROC FORMAT**

Using the dataset below:

| ID | Gender | Dept    |
| -- | ------ | ------- |
| 1  | M      | HR      |
| 2  | F      | IT      |
| 3  | F      | HR      |
| 4  | M      | Finance |
| 5  | M      | IT      |

? **Tasks**:

* Create a dataset `employees` with the above data using `DATALINES`.
* Use `PROC FORMAT` to display `M` as "Male", `F` as "Female".
* Use `PROC FREQ` to find the count of employees by `Dept` and `Gender`.

DATA EMPLOYEES;
INPUT ID GENDER$ DEPT$;
DATALINES;
1	M	HR
2	F	IT
3	F	HR
4	M	FINANCE
5	M	IT
;
RUN;
PROC FORMAT;
VALUE $GENDERFMT
'M'= "MALE"
'F'= "FEMALE";
RUN;
PROC FREQ DATA = EMPLOYEES;
TABLES DEPT GENDER;
FORMAT GENDER $GENDERFMT.;
RUN;
---

