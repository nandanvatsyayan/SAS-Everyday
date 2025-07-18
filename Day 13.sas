/*## ?? *Optional Conceptual (1 Question)*

**Q: What is the difference between `FIRST.` and `FIRST.variable` in a `BY` group context? Give an example.**

---

## ?? **Practical Coding Tasks (Day 13)**

---

### ?? **Problem 1: Running Totals Using `RETAIN`**

Given:

| Subject\_ID | Visit | Dose |
| ----------- | ----- | ---- |
| 101         | Day 1 | 50   |
| 101         | Day 2 | 50   |
| 101         | Day 3 | 0    |
| 102         | Day 1 | 100  |
| 102         | Day 2 | 0    |

? **Tasks**:

* Create a new variable `Cumulative_Dose` per `Subject_ID`
* Use `BY Subject_ID` and `RETAIN` to calculate running total */

DATA Total;
INFILE DATALINES DSD DLM='' TRUNCOVER;
INPUT Subject_ID Visit$ Dose;
DATALINES;
101 'DAY 1' 50
101 'DAY 2' 50
101 'DAY 3' 0
102	'DAY 1' 100
102 'DAY 2' 0
;
RUN;
DATA Cumulative_Dose;
SET Total;
BY Subject_ID;
RETAIN Cumulative_Dose;
IF FIRST.Subject_ID THEN Cumulative_Dose=0;
Cumulative_Dose + Dose;
RUN;
PROC PRINT DATA = Cumulative_Dose;
TITLE "Cumulative Dose Per Subject ID";
RUN;

/* ### ?? **Problem 2: Identify Repeat AEs**

Given:

| Subject\_ID | AE\_Term  | AE\_Start\_Date | 
| ----------- | --------- | --------------- |
| 101         | Headache  | 10JAN2023       |
| 101         | Headache  | 15JAN2023       |
| 102         | Dizziness | 12JAN2023       |
| 103         | Headache  | 16JAN2023       |

? **Tasks**:

* Identify `Subject_ID`s who had the **same AE more than once**
* Create a separate dataset with just those cases */

DATA Repeated_AEs;
INPUT Subject_ID AE_Terms : $10. AE_Start_Date : DATE9.;
FORMAT AE_Start_Date DATE9.;
DATALINES;
101 Headache 10JAN2023
101 Headache 15JAN2023
102 Dizziness 12JAN2023
103 Headache 16jan2023
;
RUN;
PROC SQL;
CREATE TABLE AE_Counts AS
SELECT Subject_ID, AE_Terms, COUNT(*) AS AE_Count
FROM Repeated_AEs
GROUP BY Subject_ID, AE_Terms
HAVING COUNT(*) > 1;
QUIT;

PROC SQL;
CREATE TABLE Repeats_Only AS
SELECT A.*
FROM Repeated_AEs A
INNER JOIN AE_Counts B
ON A.Subject_ID = B.Subject_ID AND A.AE_Terms = B.AE_Terms;
QUIT;

PROC PRINT DATA=Repeats_Only;
TITLE "Subjects with Repeated AEs";
RUN;


/* ### ?? **Problem 3: Subgroup Summary Using `PROC MEANS` and `CLASS`**

Use:

| Subject\_ID | Gender | Treatment | Weight |
| ----------- | ------ | --------- | ------ |
| 101         | M      | Drug A    | 70     |
| 102         | F      | Placebo   | 65     |
| 103         | M      | Drug A    | 72     |
| 104         | F      | Drug A    | 66     |

? **Tasks**:

* Use `PROC MEANS` with `CLASS Gender Treatment`
* Output: Mean and Std Dev of Weight by subgroup */

DATA Subgroup_Summary;
INFILE DATALINES DSD DLM='' TRUNCOVER;
INPUT Subject_ID Gender$ Treatment$ Weight;
DATALINES;
101 M 'Drug A' 70
102 F Placebo 65
103 M 'Drug A' 72
104 F 'Drug A' 66
;
RUN;
PROC SORT DATA = Subgroup_Summary;
BY Weight;
RUN;
PROC MEANS DATA = Subgroup_Summary MEAN STDDEV;
VAR Weight;
CLASS Gender Treatment;
RUN;

/*## ?? **Mini Project: Patient Drug Exposure Summary**

You're working with drug administration data and need to prepare an **exposure summary report** for regulatory submission.

---

### ?? **Dataset: `drug_admin`**

| Subject\_ID | Date      | Dose\_mg |
| ----------- | --------- | -------- |
| 101         | 01JAN2023 | 50       |
| 101         | 02JAN2023 | 50       |
| 101         | 03JAN2023 | 0        |
| 102         | 01JAN2023 | 100      |
| 102         | 02JAN2023 | 100      |
| 103         | 01JAN2023 | 0        |

---

### ?? **Dataset: `demo`**

| Subject\_ID | Age | Gender | Treatment |
| ----------- | --- | ------ | --------- |
| 101         | 34  | M      | Drug A    |
| 102         | 45  | F      | Drug A    |
| 103         | 52  | F      | Placebo   |

---

### ? **Tasks**

1. **Merge** the datasets */

DATA Drug_Admin;
INPUT Subject_ID Date : DATE9. Dose_Mg;
DATALINES;
101 01JAN2023 50
101 02JAN2023 50
101 03JAN2023 0
102 01JAN2023 100
102 02JAN2023 100
103 01JAN2023 0
;
RUN;
PROC SORT DATA = Drug_Admin;
BY Subject_ID;
RUN;
DATA Demo;
INFILE DATALINES DSD DLM='' TRUNCOVER;
INPUT Subject_ID Age Gender$ Treatment : $10.;
DATALINES;
101 34 M 'Drug A'
102 45 F 'Drug A'
103 52 F Placebo
;
RUN;
PROC SORT DATA = Demo;
BY Subject_ID;
RUN;

DATA Merged;
MERGE Drug_Admin Demo;
BY Subject_ID;
RUN;
PROC PRINT DATA = Merged;
FORMAT Date Date9.; 
RUN;

/* 2. **Create Summary Table**:

   * `Total_Dose` per subject
   * `Exposure_Days` (days where `Dose_mg > 0`) */

PROC MEANS DATA = Merged NOOBS;
CLASS Subject_ID;
VAR Dose_Mg;
LABEL N = 'Total_Dose_Per_Subject';
RUN;

PROC FREQ DATA = Merged;
TABLES Subject_ID * Dose_Mg;
RUN;

PROC TABULATE DATA = Merged;
CLASS Subject_ID Dose_Mg;
TABLE Subject_ID* Dose_Mg;
RUN;

PROC REPORT DATA = Merged;
COLUMN Subject_ID Dose_Mg;
DEFINE Dose_Mg / GROUP;
DEFINE Subject_ID/ GROUP;
RUN;

PROC SQL;
CREATE TABLE Merged_Data AS
SELECT
	A.Subject_ID,
	A.Date,
	A.Dose_Mg,
	B.Gender,
	B.Treatment,
FROM
	Drug_Admin
	LEFT JOIN Demo B
	ON A.Subject_ID = B.Subject_ID;
	QUIT;

PROC SQL;
CREATE TABLE Summary_Table AS
SELECT 
	Subject_ID,
	SUM (Dose_Mg) AS Total_Dose,
	COUNT(Case WHEN Dose_Mg >0 THEN 1 END) AS Exposure_Days
	FROM Merged
	GROUP BY Subject_ID;
	QUIT;
/* 3. **Flag Patients**:

   * `No_Exposure_Flag = 1` for subjects who got only 0 dose 
	*/

DATA SUMMARY_TABLE_FLAGGED;
    SET SUMMARY_TABLE;
    IF Total_Dose = 0 THEN No_Exposure_Flag = 1;
    ELSE No_Exposure_Flag = 0;
RUN;

PROC PRINT DATA=SUMMARY_TABLE_FLAGGED;
RUN;


/*
4. **Group Summary**:

   * Use `PROC MEANS` to get avg `Total_Dose` by Treatment 
*/

PROC SQL;
    CREATE TABLE MERGED_SUMMARY AS
    SELECT A.*, B.Treatment
    FROM SUMMARY_TABLE_FLAGGED A
    LEFT JOIN DEMO B
    ON A.Subject_ID = B.Subject_ID;
QUIT;

PROC MEANS DATA=MERGED_SUMMARY NOPRINT;
    CLASS Treatment;
    VAR Total_Dose;
    OUTPUT OUT=GROUP_SUMMARY
        MEAN(Total_Dose)=Avg_Total_Dose;
RUN;

PROC PRINT DATA=GROUP_SUMMARY;
    VAR Treatment Avg_Total_Dose;
RUN;

/*
5. **Optional Enhancements**:

   * Add `Avg_Dose_Per_Day` for exposed subjects
   * Create chart: `Total_Dose` by Subject\_ID using `PROC SGPLOT` */

DATA FINAL_REPORT_ENHANCED;
    SET MERGED_SUMMARY;
    IF Exposure_Days > 0 THEN Avg_Dose_Per_Day = Total_Dose / Exposure_Days;
    ELSE Avg_Dose_Per_Day = .;
RUN;

PROC PRINT DATA=FINAL_REPORT_ENHANCED;
    VAR Subject_ID Treatment Total_Dose Exposure_Days Avg_Dose_Per_Day;
    FORMAT Avg_Dose_Per_Day 8.2;
RUN;

PROC SGPLOT DATA=FINAL_REPORT_ENHANCED;
    VBAR Subject_ID / RESPONSE=Total_Dose DATALABEL
                      FILLATTRS=(COLOR=Goldenrod)
                      STAT=SUM;
    YAXIS LABEL="TOTAL DOSE (MG)";
    XAXIS LABEL="SUBJECT ID";
    TITLE "TOTAL DOSE ADMINISTERED PER SUBJECT";
RUN;



PROC IMPORT DATAFILE = "D:\Data\Data Sets\dataset.xlsx" OUT= DATASET_IMPORTED 
DBMS = XLSX
REPALCE;
SHEET='DATASET';
GETNAMES=YES;
RUN;
DATA TEST2;
SET DATASET_IMPORTED;
EMPLOYEE_ID = SCAN(Employee_ID_First_Name_Last_Name, 1, ';' , 'M');
FIRST_NAME= SCAN(Employee_ID_First_Name_Last_Name, 2, ';', 'M');
LAST_NAME=SCAN(Employee_ID_First_Name_Last_Name, 3, ';', 'M');
GENDER=SCAN(Employee_ID_First_Name_Last_Name, 4, ';', 'M');
STATE=SCAN(Employee_ID_First_Name_Last_Name, 5, ';', 'M');
CITY=SCAN(Employee_ID_First_Name_Last_Name, 6, ';', 'M');
EDUCATION_LEVEL=SCAN(Employee_ID_First_Name_Last_Name, 7, ';', 'M');
BIRTH_DATE= SCAN(Employee_ID_First_Name_Last_Name, 8, ';', 'M');
HIRE_DATE=SCAN(Employee_ID_First_Name_Last_Name, 9, ';', 'M');
TERM_DATE=SCAN(Employee_ID_First_Name_Last_Name, 10, ';','M');
DEPARTMENT=SCAN(Employee_ID_First_Name_Last_Name, 11, ';', 'M');
JOB_TITILE=SCAN(Employee_ID_First_Name_Last_Name, 12, ';', 'M');
SALARY=SCAN(Employee_ID_First_Name_Last_Name, 13, ';', 'M');
PERFORMANCE_RATING= SCAN(Employee_ID_First_Name_Last_Name, 14, ';', 'M');
DROP Employee_ID_First_Name_Last_Name;
RUN;
PROC PRINT DATA = TEST2 NOOBS;
RUN;



