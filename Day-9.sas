?? Mini Project #3: Lab Data Analysis
?? Scenario:
You’ve received two datasets:
1.	Demographics
2.	Lab Test Results
Your task is to:
•	Clean and merge the data
•	Flag abnormal values
•	Create reports grouped by treatment and gender
________________________________________
?? Datasets
1. demographics
Subject_ID	Treatment	Gender	Age
101	Drug A	M	34
102	Placebo	F	40
103	Drug A	M	28
104	Drug A	F	45
105	Placebo	M	38
________________________________________
2. lab_results
Subject_ID	Test_Date	Lab_Test	Result	Units	Normal_Low	Normal_High
101	10JAN2023	Hemoglobin	11.5	g/dL	13.5	17.5
101	10JAN2023	WBC	6.0	10^3/uL	4.0	10.0
102	12JAN2023	Hemoglobin	14.0	g/dL	12.0	16.0
103	15JAN2023	WBC	11.0	10^3/uL	4.0	10.0
104	18JAN2023	Hemoglobin	13.5	g/dL	12.0	16.0
________________________________________
? Tasks
?? 1. Data Preparation
•	Create both datasets using DATALINES.
•	Ensure numeric values are read correctly using INPUT.
•	Assign appropriate formats for Test_Date.

DATA Demographics;
INFILE "D:\Practice\SAS\Chat-GPT Daily\Demographics.csv" DSD DLM="," FIRSTOBS=2;
INPUT Subject_ID Treatment$ Gender$ Age;
RUN;
PROC SORT DATA = Demographics;
BY Subject_ID;
RUN;
DATA Lab_Results;
INFILE "D:\Practice\SAS\Chat-GPT Daily\Lab_Results.csv" DSD DLM="," FIRSTOBS=2;
INPUT Subject_ID Test_Date : Date9. Lab_Test : $10. Result Units$ Normal_Low Normal_High;
INFORMAT Test_Date DDMMYY10.;
FORMAT Test_Date DDMMYY10.;
RUN;
PROC SORT DATA = Lab_Results;
BY Subject_ID;
RUN;
________________________________________
?? 2. Merge Datasets
•	Merge demographics and lab_results by Subject_ID.

DATA Lab_Results_Merged;
MERGE Demographics Lab_Results;
BY Subject_ID;
RUN;
________________________________________
?? 3. Flag Abnormal Results
•	Create a new variable Abnormal_Flag:
o	'Low' if Result < Normal_Low
o	'High' if Result > Normal_High
o	'Normal' otherwise

DATA Abnormal_Flag;
SET Lab_Results_Merged;
LENGTH Abnormal_Flag $7;
IF Result < Normal_Low THEN Abnormal_Flag = 'Low';
ELSE IF Result > Normal_High THEN Abnormal_Flag = 'High';
ELSE Abnormal_Flag = 'Normal';
RUN;
________________________________________
?? 4. Summary Report
•	Use PROC REPORT to show:
o	Number of tests per treatment group
o	Count of abnormal results by test and treatment
o	Include gender grouping

PROC REPORT DATA = Abnormal_Flag;
COLUMN Lab_Test Gender Treatment Abnormal_Flag ;
DEFINE Lab_Test / Group;
DEFINE Treatment / Group;
DEFINE Gender / Group;
DEFIN Abnormal_Flag / ACORSS "Result Flag";
TITLE "Abnormal Lab Result Summary by Treatment and Gender";
RUN;

PROC FREQ DATA = Abnormal_Flag;
TABLES Treatment*Lab_Test / NOCUM NOPERCENT;
TITLE "Test Counts Per Treatment Group";
RUN;

________________________________________
?? 5. Create AE-Ready View
•	Prepare a filtered dataset that includes only abnormal results.
•	Include: Subject_ID, Test_Date, Lab_Test, Result, Abnormal_Flag, Treatment, Gender, Age

DATA AE_Ready;
SET Abnormal_Flag;
WHERE Abnormal_Flag IN ("Low", "High");
KEEP Subject_ID Test_Date Lab_Test Result Abnormal_Flag Treatment Gender Age;
RUN;

PROC PRINT DATA = AE_Ready;
TITLE "AE Ready View : Filtered Abnormal Result";
RUN;


________________________________________
?? 6. Optional Enhancements
•	Count how many subjects had multiple abnormal tests
•	Use PROC SGPLOT to plot Hemoglobin levels by treatment group
•	Create a Severity_Score variable (optional formula: abs(Result - mean([Low, High])))

PROC SQL;
CREATE TABLE Abnormal_Counts AS
SELECT Subject_ID, Count(*) AS Abnormal_Counts
FROM AE_Ready
GROUP BY Subject_ID
HAVING Abnormal_Counts>1;
QUIT;
PROC PRINT DATA = Abnormal_Counts;
TITLE "Subjects with Multiple Abnormal Lab Tests";
RUN;


DATA Hemo_Data;
SET Abnormal_Flag;
WHERE Lab_Test = "Hemoglobin";
RUN;
PROC SGPLOT DATA=Hemo_Data;
VBOX Result / Category= Treatment;
TITLE "Hemoglobin Levels by Treatment Group";
YAXIS LABEL = "Hemohlobin(g/dL)";
RUN;

DATA Flagged_Results_Severity;
SET Abnormal_Flag;
Severity_Score = ABS(Result - mean(Normal_Low, Normal_High));
FORMAT Severity_Score 6.2;
RUN;

PROC PRINT DATA = Flagged_Results_Severity;
VAR Subject_ID Lab_Test Result Normal_Low Normal_High Severity_Score;
    TITLE "Calculated Severity Score for Each Test Result";
RUN;



