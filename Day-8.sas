?? Mini Project #2: Adverse Event Summary Report
?? Scenario:
You're working for a CRO (Clinical Research Organization). You’ve received data from a Phase III clinical trial comparing Drug A vs Placebo. 
Your task is to generate a clean summary report on Adverse Events (AEs) by System Organ Class (SOC) and Treatment Group.
________________________________________
?? Dataset: adverse_events
You can create this dataset using DATALINES. Here's the structure:
Subject_ID	Treatment	AE_Term	SOC	Severity	Serious	AE_StartDate
101	Drug A	Nausea	Gastrointestinal	Mild	No	12JAN2023
102	Placebo	Headache	Nervous System	Moderate	No	13JAN2023
103	Drug A	Vomiting	Gastrointestinal	Severe	Yes	15JAN2023
104	Drug A	Dizziness	Nervous System	Mild	No	20JAN2023
105	Placebo	Fatigue	General Disorders	Moderate	No	22JAN2023
106	Drug A	Diarrhea	Gastrointestinal	Moderate	Yes	25JAN2023
________________________________________
? Tasks
?? 1. Data Creation & Cleaning
•	Create dataset using DATALINES.
•	Use appropriate informats for AE_StartDate.
•	Standardize text (capitalize or use PROPERCASE() if needed).

DATA Adverse_Events;
INFILE "D:\Practice\SAS\Chat-GPT Daily\Adverse Event Summary Report.csv" DSD DLM="," FIRSTOBS=2;
INPUT Subject_ID Treatment$ AE_Term : $10. SOC : $20. Severity$ Serious$ AE_StartDate Date9.;
Treatment = PROPCASE(Treatment);
AE_Term = PROPCASE(AE_Term);
SOC= PROPCASE(SOC);
Severity = PROPCASE(Severity);
Serious = PROPCASE(Serious);
INFORMAT AE_StartDate Date9.;
FORMAT AE_StartDate DDMMYY10.;
RUN;
 
________________________________________
?? 2. AE Summary by SOC and Treatment
•	Use PROC FREQ or PROC TABULATE:
o	Count number of AEs by SOC and Treatment.
o	Show percentages if possible.

PROC FREQ DATA = Adverse_Events;
TABLE SOC * Treatment / NOCOL NOPERCENT NOROW;
TITLE "Adverse Even Count By SOC & Treatment";
RUN;

PROC TABULATE DATA= Adverse_Events;
CLASS SOC Treatment;
TABLE SOC,
Treatment * (N colpctn='%');
TITLE 'Adverse Even Summary By SOC Treatment';
RUN;

________________________________________
?? 3. Serious vs Non-serious AE Count
•	Use PROC FREQ to get:
o	Total serious AEs per treatment group.
o	Total non-serious AEs.

PROC FREQ DATA = Adverse_Events;
TABLE Serious * Treatment / NOCOL NOPERCENT NOROW;
TITLE 'Total Serious Adverse Event By Treatment Group';
RUN;
 

________________________________________
?? 4. Severity Breakdown
•	Use PROC REPORT to show:
o	How many Mild, Moderate, Severe AEs occurred per treatment.
o	Grouped by SOC.
o	Include row totals.

PROC REPORT DATA = Adverse_Events;
COLUMN Severity Treatment SOC;
DEFINE SOC / GROUP "System Organ Class";
DEFINE Severity / ACCROSS "Severity";
DEFINE  Treatment / ACORSS "Treatment Group";
RBREAK AFTER / SUMMRIZE DOL;
TITLE "Adverse Event Severity Breakdown By Treatment Group";
RUN;

________________________________________
?? 5. Additional Derived Variable
•	Create a variable Severe_Flag:
o	1 if Severity = "Severe" and Serious = "Yes", else 0
•	Filter out and display only subjects with this flag.

DATA Severe_Event;
SET Adverse_Events;
IF Severity = "Severe" AND Serious = "Yes" THEN Severe_Flag=1;
ELSE Severe_Flag = 0;
RUN;
PROC PRINT DATA = Severe_Event;
WHERE Severe_Flag= 1;
VAR Subject_ID Treatment AE_Term SOC Severity Serious AE_StartDate Severe_Flag;
TITLE "Subject With Serious And Sever Adverse Events";
RUN;

________________________________________
?? 6. Optional Enhancements
•	Add a Month or Week variable from AE_StartDate.
•	Highlight subjects who had more than one AE (you’ll need to create multiple records for some Subject_IDs to test this).
•	Plot a simple bar chart using PROC SGPLOT for AE counts by SOC.

DATA Adverse_Events_Enhanced;
SET Adverse_Events;
AE_Month=PUT(AE_StartDate, MONNAME.);
AE_Week = WEEK(AE_StartDate);
RUN;

PROC SQL;
CREATE TABLE Subject_AE_Count AS
SELECT*,
COUNT(*) AS AE_Count
FROM Adverse_Events_Enhanced
GROUP BY Subject_ID;
QUIT;
DATA Multiple_AE_Flag;
SET Subject_AE_Count;
IF AE_Count > 1 THEN Multiple_AE_Flag = 1;
ELSE Multiple_AE_Flag = 0;
RUN;
PROC PRINT DATA = Multiple_AE_Flag;
WHERE Multiple_AE_Flag = 1;
TITLE "Subjects With Multiple Adverse Events";
RUN;

PROC FREQ DATA = Adverse_Events_Enhanced NOPRINT;
TABLE SOC / OUT = AE_BY_SOC;
RUN;
PROC SGPLOT DATA = AE_BY_SOC;
VBAR SOC/ RESPONSE= COUNT DATALABEL
FILLATTRS = (COLOR=BLUE)
BARWIDTH = 0.5;
TITLE "Adverse Events By System Organ Class";
YAXIS LABEL = "Number Of AEs";
XAXIS LABEL = "System Organ Class";
RUN;
