/*Here’s your **Day 12 SAS Practice Set** – focused on **practical skills and a mini-project**, with just one high-impact conceptual question to keep theory relevant.

---

## ?? *Minimal Conceptual (Optional)*

**Q: In clinical trials, why do we often track visit windows (e.g., Week 4 ± 2 days)? How would you handle this logic in a dataset using SAS?** */

Ans:- 	In **clinical trials**, visit windows  are crucial because they ensure that subjects are evaluated consistently 
		around predefined time points, while allowing flexibility for unavoidable scheduling issues like holidays, illness, or travel delays. 
		Strict adherence to visit timing is essential for 'regulatory compliance', 'data integrity', and 'scientific accuracy', especially 
		when measuring drug effects at critical milestones. If a visit occurs too early or too late, the data may not be valid for analysis at 
		that intended time point.

		--->	Why We Track Visit Windows

		1. Standardization:- Ensures comparability across subjects by aligning assessments with the protocol timepoints.
		2. Flexibility with Control:- ± windows allow practical flexibility without compromising data integrity.
		3. Protocol Compliance Monitoring:- Helps monitor whether investigators follow the study schedule.
		4. Analysis Flagging:- Out-of-window visits may be excluded from primary endpoint analyses.
		5. Regulatory Expectation:- Agencies like the FDA often require justification for missed or late visits.

		--->	How to Handle Visit Window Logic in SAS

		1. Calculate the difference between actual visit date and planned visit date.
		2. Compare the difference to allowed limits.
		3. Create flags like `Visit_Window_Flag` ("Within", "Early", "Late", etc.).

/*## ?? **Practical Coding Problems (Day 12)**

---

### ?? **Problem 1: Visit Window Flagging**

You have:

| Subject\_ID | Visit\_Date | Planned\_Visit | Planned\_Date |
| ----------- | ----------- | -------------- | ------------- |
| 101         | 06FEB2023   | Week 4         | 04FEB2023     |
| 102         | 08FEB2023   | Week 4         | 04FEB2023     |
| 103         | 15FEB2023   | Week 4         | 04FEB2023     |

? **Tasks**:

* Create a variable `Visit_Window_Flag`:

  * Value = "Within Window" if Visit\_Date is ±3 days of Planned\_Date
  * Otherwise "Out of Window" */

DATA Visit_Window_Flag;
INPUT Subject_ID Visit_Date : Date9. Planned_Visit : $10. Planned_Date : Date9.;
DATALINES;
101	06FEB2023	WEEK4 04FEB2023
102	08FEB2023	WEEK4 04FEB2023
103	15FEB2023	WEEK4 04FEB2023
;
RUN;
PROC PRINT DATA = Visit_Window_Flag;
FORMAT Visit_Date DATE9. Planned_Date DATE9.;
RUN;
DATA Value;
SET Visit_Window_Flag;
DIFF = ABS(Visit_Date - Planned_Date);
IF DIFF <= 3 THEN Visit_Window= 'Within Window';
ELSE Visit_Window = 'Out Of Window';
RUN;
PROC PRINT DATA = Value;
FORMAT Visit_Date DATE9. Planned_Date DATE9.;
TITLE "Visit Window Flag (±3)";
RUN;

/* ### ?? **Problem 2: AE Flagging with Conditions**

You have:

| Subject\_ID | AE\_Term | Serious | Severity |
| ----------- | -------- | ------- | -------- |
| 101         | Nausea   | No      | Mild     |
| 102         | Vomiting | Yes     | Severe   |
| 103         | Headache | No      | Moderate |

? **Tasks**:

* Create a `Flag` column:

  * "Critical" if Serious = Yes AND Severity = Severe
  * "Review" if Severity = Moderate or Serious = Yes
  * "Normal" otherwise */

DATA AE_Flagging_With_Condition;
INPUT Subject_ID AE_Term$ Serious$ Severity$;
DATALINES;
101	Nausea	No	Mild
102	Vomiting	Yes	Severe
103	Headche	No	Moderate
;
RUN;
DATA Flag;
SET AE_Flagging_With_Condition;
IF Serious = 'Yes' AND Severity = 'Severe' THEN Flag= 'Critical';
ELSE IF Severity = 'Moderate' OR Serious = 'Yes' THEN Flag = 'Review';
ELSE Flag = 'Normal';
RUN;
PROC PRINT DATA = Flag;
TITLE 'AE Flagging With Condition';
RUN;

/* ### ?? **Problem 3: Simple PROC SQL Join**

Two datasets:

**demographics**

| Subject\_ID | Gender | Age |
| ----------- | ------ | --- |
| 101         | M      | 34  |
| 102         | F      | 40  |

**lab\_results**

| Subject\_ID | Lab\_Test  | Result |
| ----------- | ---------- | ------ |
| 101         | Hemoglobin | 13.5   |
| 102         | WBC        | 5.2    |

? **Tasks**:

* Join both tables using `PROC SQL`
* Output: Subject\_ID, Gender, Age, Lab\_Test, Result */

DATA Demographics;
INPUT Subject_ID Gender$ Age;
DATALINES;
101	M	34
102	F	40
;
RUN;
DATA Lab_Results;
INPUT Subject_ID Lab_Test$ Result;
DATALINES;
101	Hemoglobin	13.5
102	WBC	5.2
;
RUN;
PROC SQL;
SELECT A.Subject_ID, A.Gender, A.Age, B.Lab_Test, B.Result 
FROM Demographics AS A
FULL JOIN Lab_Results AS B
ON A.Subject_ID = B.Subject_ID;
QUIT;

PROC SQL;
SELECT A.Subject_ID, A.Gender, A.Age, B.Lab_Test, B.Result 
FROM Demographics AS A
INNER JOIN Lab_Results AS B
ON A.Subject_ID = B.Subject_ID;
QUIT;


/* # ?? **Mini Project: Demographic Profile & Lab Summary**

### ?? **Scenario:**

You received 2 datasets — **Demographics** and **Lab Results** — from a clinical trial. You need to summarize key info for a study report.

---

### ?? **Dataset 1: `demo`**

| Subject\_ID | Gender | Age | Treatment |
| ----------- | ------ | --- | --------- |
| 101         | M      | 45  | Drug A    |
| 102         | F      | 52  | Placebo   |
| 103         | M      | 47  | Drug A    |
| 104         | F      | 50  | Drug A    |

---

### ?? **Dataset 2: `labs`**

| Subject\_ID | Visit    | Lab\_Test  | Result | Normal\_Low | Normal\_High |
| ----------- | -------- | ---------- | ------ | ----------- | ------------ |
| 101         | Baseline | Hemoglobin | 12.5   | 13.5        | 17.5         |
| 102         | Baseline | Hemoglobin | 14.2   | 12.0        | 16.0         |
| 103         | Baseline | WBC        | 11.0   | 4.0         | 10.0         |
| 104         | Baseline | Hemoglobin | 13.8   | 12.0        | 16.0         |

---

### ? **Tasks**

1. **Merge datasets on Subject\_ID** */

DATA Demo;
INFILE DATALINES DSD DLM='' TRUNCOVER;
INPUT Subject_ID Gender$ Age Treatment$;
DATALINES;
101 M 45 'Drug A'
102 F 52 'Placebo'
103 M 47 'Drug A'
104 F 50 'Drug A'
;
RUN;
PROC SORT DATA = Demo;
BY Subject_ID;
RUN;
DATA Labs;
INPUT Subject_ID	Visit : $10.	Lab_Test : $10.	Result	Normal_Low	Normal_High;
DATALINES;
101	Baseline	Hemoglobin	12.5	13.5	17.5
102	Baseline	Hemoglobin	14.2	12.0	16.0
103	Baseline	WBC	11.0	4.0	10.0
104	Baseline	Hemoglobin	13.8	12.0	16.0
;
RUN;
PROC SORT DATA=Demo;
BY Subject_ID;
RUN;

DATA Merged;
MERGE Demo Labs;
BY Subject_ID;
RUN;
PROC PRINT DATA=Merged;
TITLE "Demo & Lab Data Merged By Subject ID ";
RUN;


/*2. **Create `Abnormal_Flag` column:**

   * "Low" if Result < Normal\_Low
   * "High" if Result > Normal\_High
   * "Normal" otherwise */


DATA Abnormal_Flag;
SET Merged;
LENGTH Abnormal_Flag $12;
IF Result < Normal_Low THEN Abnormal_Flag= 'Low';
ELSE IF Result > Normal_High THEN Abnormal_Flag = 'High';
ELSE Abnormal_Flag = 'Normal';
RUN;
PROC PRINT DATA = Abnormal_Flag;
TITLE "Data With Abnormal Flag";
RUN;



/* 3. **Create summary table:**

   * Count of abnormal results per Treatment group
   * % of abnormal results by Gender and Treatment */

PROC FREQ DATA = Abnormal_Flag;
TABLE Treatment*Abnormal_Flag / NOCUM NOPERCENT;
TITLE "Count of Abnormal Results by Treatment Group";
RUN;
PROC FREQ DATA = Abnormal_Flag;
TABLE Gender*Treatment*Abnormal_Flag / NOCUM NOROW NOCOL;
TITLE "Percentage of Abnormal Results by Gender and Treatment";
RUN;

/*4. **Optional:**

   * Create frequency table of `Lab_Test * Abnormal_Flag`
   * Use `PROC SGPLOT` to graph average Hemoglobin by Treatment */

PROC FREQ DATA= Abnormal_Flag;
TABLE Lab_Test*Abnormal_Flag / NOCUM NOROW NOCOL NOPERCENT;
TITLE "Count Of Abnormal Flag By Lab Test";
RUN;

PROC MEANS DATA=Abnormal_Flag NOPRINT;
WHERE Lab_Test = "Hemoglobin";
CLASS Treatment;
VAR Result;
OUTPUT OUT=Hemoglobin_Means MEAN=Avg_Hemoglobin;
RUN;
PROC SGPLOT DATA=Hemoglobin_Means;
VBAR Treatment / RESPONSE=Avg_Hemoglobin DATALABEL;
YAXIS LABEL="Average Hemoglobin";
TITLE "Average Hemoglobin by Treatment Group";
RUN;

---



