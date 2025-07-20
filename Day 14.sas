/*

**Problem 1: Rate Calculation**

Given this dataset of vaccinations:

| District | Population | Fully\_Vaccinated |
| -------- | ---------- | ----------------- |
| A        | 100000     | 85000             |
| B        | 75000      | 69000             |
| C        | 120000     | 114000            |

? **Tasks**:

* Add a column `Coverage_Percent = (Fully_Vaccinated / Population) * 100`
* Format it to show 1 decimal place (e.g., 95.3%) 
*/

DATA Vaccination;
INPUT District$ Population Fully_Vaccinated;
DATALINES;
A 100000 85000
B 75000 69000
C 120000 114000
;
RUN;
DATA Vaccinations2;
SET Vaccination;
Coverage_Percent = (Fully_Vaccinated / Population) * 100;
RUN;
PROC PRINT DATA = Vaccinations2;
FORMAT Coverage_Percent COMMA8.1;
RUN;


/*
**Problem 2: Group-wise Aggregation**

| State | District | Cases | Deaths |
| ----- | -------- | ----- | ------ |
| X     | A        | 1000  | 20     |
| X     | B        | 1200  | 25     |
| Y     | C        | 900   | 15     |

? **Tasks**:

* Calculate total `Cases` and `Deaths` by State using `PROC SQL`
* Also compute `CFR = (Deaths / Cases) * 100` per state
*/

DATA Group_Wise;
INPUT State$ District$ Cases Deaths;
DATALINES;
X A 1000 20
X B 1200 25
Y C 900 15
;
RUN;
PROC SQL;
CREATE TABLE Group_Wised AS
SELECT State,
		SUM(Cases) AS Total_Case,
		SUM(Deaths) AS Total_Death,
		(SUM(Deaths) / SUM(Cases)) *  100 AS CFR FORMAT = 8.2
FROM Group_Wise 
GROUP BY State;
PROC PRINT DATA = Group_Wised;
RUN;

/*
### ?? **Problem 3: Date-Based Filtering** 

| Report\_Date | Cases |
| ------------ | ----- |
| 01JAN2023    | 250   |
| 02JAN2023    | 310   |
| 15MAR2023    | 700   |

? **Tasks**:

* Filter records from March only
* Use `intnx()` to calculate start & end of each month
*/

DATA Filtering;
INFILE DATALINES DSD DLM='' TRUNCOVER;
FORMAT Report_Date DATE9.;
INPUT Report_Date : DATE9. Cases;
DATALINES;
01JAN2023 250
02JAN2023 310
15MAR2023 700
;
RUN;

PROC SQL;
CREATE TABLE Filtered AS
SELECT *
FROM Filtering
WHERE MONTH(Report_Date) = 3;
PROC PRINT DATA = Filtered;
RUN;

/*
## ?? **Mini Project: Public Health – COVID-19 Surveillance Report**

### ?? **Scenario:**

You're working with a national health agency and tasked to create a **district-wise COVID-19 monitoring dashboard**. 
The goal is to flag underperforming areas based on vaccination and fatality metrics.

---

### ?? **Dataset 1: `district_stats`**

| District | State | Population | Vaccinated | Cases | Deaths |
| -------- | ----- | ---------- | ---------- | ----- | ------ |
| A        | X     | 100000     | 85000      | 1500  | 25     |
| B        | X     | 75000      | 69000      | 1200  | 28     |
| C        | Y     | 120000     | 114000     | 1800  | 30     |
| D        | Y     | 90000      | 60000      | 2000  | 40     |

---

### ? **Project Tasks**

#### 1. **Calculate Indicators**

* `Vaccination_Rate` = Vaccinated / Population
* `Case_Fatality_Rate` = Deaths / Cases
*/

DATA District_Stats;
INPUT District$ State$ Population Vaccinated Cases Deaths;
DATALINES;
A X 100000 85000 1500 25
B X 75000 69000 1200 28
C Y 120000 114000 1800 30
D Y 90000 60000 2000 40
;
RUN;
DATA Stats;
SET District_Stats;
Vaccination_Rate = Vaccinated / Population;
Case_Fatality_Rate = Deaths / Cases;
RUN;
PROC PRINT DATA = Stats;
FORMAT Vaccination_Rate COMMA8.2 Case_Fatality_Rate COMMA8.2;
RUN;

/*
#### 2. **Create Flags**

* Flag districts with `Vaccination_Rate < 80%` ? "Low Coverage"
* Flag districts with `CFR > 2%` ? "High Fatality"
*/

DATA Stats_Flagged;
SET Stats;
IF Vaccination_Rate < 0.80 THEN Coverage_Flag = "Low Coverage";
ELSE Coverage_Flag = "Adequate Coverage";

IF Case_Fatality_Rate > 0.02 THEN CFR_Flag = "High Fatality";
ELSE CFR_Flag = "Normal Fatality";

RUN;
PROC PRINT DATA = Stats_Flagged;
FORMAT Vaccination_Rate PERCENT8.2 Case_Fatality_Rate PERCENT8.2;
VAR District State Population Vaccinated Cases Deaths 
    Vaccination_Rate Case_Fatality_Rate Coverage_Flag CFR_Flag;
RUN;

								*OR;

PROC SQL;
    CREATE TABLE Stats_Flagged_SQL AS
    SELECT *,
         
           CASE 
               WHEN (Vaccinated / Population) < 0.80 THEN 'Low Coverage'
               ELSE 'Adequate Coverage'
           END AS Coverage_Flag,
           
         
           CASE 
               WHEN (Deaths / Cases) > 0.02 THEN 'High Fatality'
               ELSE 'Normal Fatality'
           END AS CFR_Flag

    FROM District_Stats;
QUIT;


/*
#### 3. **Regional Summary**

* Use `PROC MEANS` or `SQL` to calculate:

  * Avg vaccination rate and CFR per State
*/

PROC MEANS DATA=Stats NOPRINT NWAY;
    CLASS State;
    VAR Vaccination_Rate Case_Fatality_Rate;
    OUTPUT OUT=Regional_Summary_Means
        MEAN(Vaccination_Rate)=Avg_Vaccination_Rate
        MEAN(Case_Fatality_Rate)=Avg_CFR;
RUN;


					*SQL;


PROC SQL;
    CREATE TABLE Regional_Summary_SQL AS
    SELECT State,
           MEAN(Vaccinated / Population) AS Avg_Vaccination_Rate FORMAT=8.2,
           MEAN(Deaths / Cases) AS Avg_CFR FORMAT=8.2
    FROM District_Stats
    GROUP BY State;
QUIT;

/*
#### 4. **Tabulated Output**

* Use `PROC REPORT` or `TABULATE`:

  * Display District, State, Vaccination Rate, CFR, and Flags
*/

PROC TABULATE DATA=Stats_Flagged FORMAT=percent8.2;
    CLASS District State Coverage_Flag CFR_Flag;
    VAR Vaccination_Rate Case_Fatality_Rate;

    TABLE 
        District * State,
        Vaccination_Rate * mean 
        Case_Fatality_Rate * mean 
        Coverage_Flag 
        CFR_Flag;
RUN;


/*
#### 5. **Optional Visualizations**

* Bar chart of CFR per district
* Heat map of vaccination rate (using `SGPLOT` or `PROC GMAP` if licensed)
*/

PROC SGPLOT DATA=Stats_Flagged;
    VBAR District / RESPONSE=Case_Fatality_Rate 
                    DATALABEL 
                    FILLATTRS=(COLOR=RED)
                    STAT=MEAN;
    YAXIS LABEL="CASE FATALITY RATE (CFR)" GRID VALUES=(0 TO 0.05 BY 0.01);
    XAXIS LABEL="DISTRICT";
    FORMAT Case_Fatality_Rate PERCENT8.2;
    TITLE "CFR (%) PER DISTRICT";
RUN;



PROC SGPLOT DATA=Stats_Flagged;
    HBAR District / RESPONSE=Vaccination_Rate 
                    DATALABEL
                    STAT=MEAN
                    FILLATTRS=(COLOR=BLUE);
    XAXIS LABEL="VACCINATION RATE" GRID;
    YAXIS LABEL="DISTRICT";
    FORMAT Vaccination_Rate PERCENT8.2;
    TITLE "VACCINATION RATE HEAT MAP (SIMULATED)";
RUN;
