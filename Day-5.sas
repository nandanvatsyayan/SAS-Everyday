?? Conceptual Questions (Day 5)
1.	Explain the difference between FORMAT and LABEL. How are they used differently in reports?
Ans:-	FORMAT - The FORMAT statement defines how the values of variables should be displayed in reports or outputs. It is most often used to:
		Show dates in readable form (ddmmmyy10.), Display numeric values with commas, currency symbols, or decimal control, Translate coded 
		values using custom formats (PROC FORMAT).

		LABEL - The LABEL statement assigns more descriptive names to variables that appear in reports. Useful for making variable names easier 
		to understand in printed output or reports, especially when variables are named briefly in the dataset.

2.	What does the LAG function do? Give a use case where it’s essential.
Ans:-	The LAG function in SAS is used to retrieve the value of a variable from a previous observation (row) during DATA step processing. It 
		essentially introduces a delay or "lag" in the value of a variable — returning a prior value rather than the current one. It is most 
		commonly used when you want to compare current values to previous values without writing complex code to track or retain them manually.

3.	What are the limitations of using MERGE in SAS without sorting the datasets first?
Ans:-	when using the MERGE statement in a DATA step with a BY statement, both datasets must be sorted by the BY variable(s) beforehand. 
		Failing to do so introduces serious limitations and risks, which can lead to incorrect results or program failure.
		
		a) Incorrect Matching of Observations -  When datasets are not sorted by the BY variable(s), SAS cannot properly align observations. 
		As a result, it may merge unrelated records simply based on their position rather than matching values.

		b)	Missing or Misleading Data - When records do not align correctly, one of two things might happen: Variables from one dataset may 
		be missing or mismatched, SAS might insert missing values where valid data actually exists in the other dataset. This causes inaccurate 
		results in summary reports, statistical analyses, or decisions based on the data.

		c)	No Warning or Error in Some Cases - One of the most dangerous aspects is that SAS may not throw an error or even a warning if the 
		datasets are not sorted. It simply performs the merge as-is, producing incorrect results silently.

		d)	FIRST. and LAST. Variables Will Not Work Properly - When datasets are not sorted, using FIRST.variable or LAST.variable with BY 
		processing becomes unreliable or completely invalid. These automatic variables are only meaningful if the data is in the correct order.

4.	What is the role of BY in MERGE vs BY in PROC MEANS?
Ans:-	BY in MERGE - When used in a DATA step with a MERGE statement, the BY statement tells SAS how to align records from two or more datasets 
		being combined.

		BY in PROC MEANS - In PROC MEANS, the BY statement is used to calculate separate summary statistics for each group defined by the BY 
		variable(s).

5.	How do you handle missing values in SAS—both for numeric and character data?
Ans:-	Handling missing values is an essential part of data cleaning and preparation. For numeric variables, missing values are represented by 
		a period (.), while for character variables, they appear as blank strings (""). SAS procedures like PROC MEANS, PROC FREQ, and PROC PRINT 
		typically ignore missing values by default during analysis. However, if you want to explicitly identify them, you can use conditional 
		checks such as if age = . for numeric and if name = "" for character variables. To replace or impute missing values, you can assign default 
		values or calculated statistics; for example, if income = . then income = 30000; or if city = "" then city = "Unknown";. SAS also provides 
		functions like NMISS() and CMISS() to count missing values across variables, and MISSING() to detect whether a variable is missing 
		regardless of its type. By carefully identifying, excluding, or replacing missing values, you ensure that your analysis remains accurate 
		and consistent.
________________________________________
?? Coding Practice (Day 5)
?? Problem 1: LABEL vs FORMAT
Create a dataset with employee info:
ID	Gender	Salary	JoinDate
1	M	50000	12JAN2020
2	F	60000	01MAR2021
? Tasks:
•	Assign a label to JoinDate as "Date of Joining".
•	Format Salary with commas and JoinDate as ddmmmyy10..
•	Print the formatted output using PROC PRINT.

DATA EMPLYEE_INFO;
INPUT ID Gender$	Salary	JoinDate DATE9.;
DATALINES;
1	M	50000	12JAN2020
2	F	60000	01MAR2021
;
RUN;
DATA EMPLYEE_LABELED;
SET EMPLOYEE_INFO;
LABEL JoinDate = "Date Of Joining";
FORMAT Salary COMMA10.
JoinDate DDMMYY10.;
RUN;
PROC PRINT DATA = EMPLYEE_LABELED;
TITLE "EMPLOYEE OUTPUT WITH FORMATED OUTPUT";
RUN;
________________________________________
?? Problem 2: Using LAG Function
Use this data:
Month	Sales
Jan	2000
Feb	2500
Mar	1800
Apr	3000
? Task:
Add a new column Diff_From_Previous showing the difference from previous month using the LAG function.

DATA SALES;
INPUT Month$ Sales;
DATALINES;
Jan 2000
Feb 2500
Mar 1800
Apr 3000
;
RUN;
DATA LAG_FUNCTIONS;
SET SALES;
Prev_Sales = LAG(Sales);
DIFF_FROM_PERVOIS = Sales - Prev_Sales;
RUN;
PROC PRINT DATA= LAG_FUNCTIONS;
TITLE "SALE WITH DIFFERENCE FROM PERVOIS SALES";
RUN;

________________________________________
?? Problem 3: PROC MEANS with CLASS and BY
Using dataset orders:
Region	Sales
North	5000
South	4000
North	6000
South	4500
? Tasks:
•	Use PROC MEANS with CLASS and then with BY to get summary statistics.
•	Explain the difference in output.

DATA SALES;
INPUT Region$ Sales;
DATALINES;
North 5000
South 4000
North 6000
South 4500
;
RUN;
PROC SORT DATA = SALES;
BY REGION;
RUN;
PROC MEANS DATA = SALES MEAN;
CLASS Region ;
VAR Sales;
TITLE "Summary Statistics Uisng Class";
RUN;

________________________________________
?? Problem 4: PROC TRANSPOSE
Using this wide dataset:
Name	Math	Science	English
Ria	85	78	92
Aman	90	88	86
? Task:
Transpose it so that each subject becomes a row, not a column, for each student. 

DATA STUDENT;
INPUT Name$	Math Science English;
DATALINES;
Ria		85	78	92
Aman	90	88	86
;
RUN;
PROC SORT DATA = STUDENT;
BY Name;
RUN;
PROC TRANSPOSE DATA = STUDENT OUT=MARK(RENAME=(COL=Score _name_= Subject));
BY Name;
VAR Math Science English;
RUN;
PROC PRINT DATA = MARK;
RUN;
 
________________________________________
?? Problem 5: Missing Values Logic
Create a dataset with some missing values:
ID	Age	Score
1	25	90
2	.	85
3	27	.
? Tasks:
•	Count how many missing values exist for Age and Score.
•	Replace missing Score with average score using IF and MEANS.

DATA SCORE;
INPUT ID Age Score;
DATALINES;
1	25	90
2	.	85
3	27	.
;
RUN;
PROC MEANS DATA = SCORE N NMISS;
VAR ID Age Score;
RUN;
PROC MEANS DATA = SCORE MEAN NOPRINT;
VAR Score;
OUTPUT OUT = Score_Mean MEAN = Avg_Score;
RUN;

DATA STUDENT_FILLED;
IF _N_ = 1 THEN SET Score_Mean;
SET SCORE;
IF Score = . THEN Score = Avg_Score;
RUN;

PROC PRINT DATA = STUDENT_FILLED;
TITLE "STUDENT DATA WITH MISSING SCORE FILLED";
RUN;

