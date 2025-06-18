## ?? **Conceptual Questions

1. **What is the difference between `INPUT` and `INFILE` in a DATA step?**

Ans:-	"INPUT" - Input is a statement in SAS DATA step which tells SAS how to read the data - it is used to describe the name of the variables and
		how the data value are formated or positioned in raw file. It works together with "INFILE".

		"INFILE" - Infile statement in SAS is an option which is used to read the raw file. It is used to specify the file location and other
		file-handling options like delimeters, length line etc etc. The downside of using "INFILE" statement is that we can only read
		.CSV and .TEXT file with it. 



2. **What does the `SET` statement do in a DATA step?**

Ans:-	'SET' statement is DATA step is used to read observations from existing datasets into current datastep. It Brings data from one or more
		existing datasets into the programm so that we can view, modify or create new dataset based on it. "SET" statement does not change original
		dataset. we can use "SET" statement with one or multiple datasets. It is commonly used for tasks like data tranformation, adding new
		variables, or combing datasets.


3. **Explain the difference between `PROC PRINT` and `PROC REPORT`.**

Ans:-	"PROC PRINT" - Used to display raw data from a SAS dataset. It prints all or selected variables and observations to the output window or 
		results viewer. 
	
	  	"PROC REPORT" - Proc Report is used to create professional and flexible reports that can include grouping, summaries, calculations, and 
		customized layouts. It supports grouping, ordering, summerizing. It ptovides more formatting controls over headers, alingment, column
		width and labels. It can act like a mix of "PROC PRINT", "PROC SORT" & "PROC MEANS".

4. **What is the purpose of a `LIBNAME` statement in SAS?**

Ans:-	The LIBNAME statement in SAS is used to assign a library reference (LIBREF) to a directory (folder) on your system or a database. This 
		allows SAS to read from or write to permanent datasets stored in that location. It connects SAS Library Name (LIBREF) to a physical file
		path or database. Enables access to permanent dataset. 

5. **What are SAS libraries and how do temporary vs. permanent libraries differ?**

Ans:-	A SAS library is a logical collection of SAS files, typically SAS datasets, stored in a specific location. It acts as a folder or directory 
		that SAS can use to read from or write to. In SAS, libraries are accessed using library references (LIBREFs), which are names assigned 
		using the LIBNAME statement or default names like WORK.
---

## ?? **Coding Practice (Day 1)**

### Problem 1: Basic Data Step

Create a dataset named `students` with the following data:

| Name    | Age | Score |
| ------- | --- | ----- |
| Alice   | 20  | 85    |
| Bob     | 22  | 90    |
| Charlie | 21  | 78    |


DATA STUDENT;
INPUT Name$ Age Score;
DATALINES;
Alice 20 85
Bob 22 90
Charlie 21 78
;
RUN; 
? **Task**: Write a `DATA` step to create this dataset and then print it.

---

### Problem 2: Reading Data from DATALINES

Using `DATALINES`, create a dataset named `products` with the following structure:

| ProductID | Name      | Price |
| --------- | --------- | ----- |
| 101       | Pencil    | 5.5   |
| 102       | Eraser    | 3.0   |
| 103       | Sharpener | 7.2   |


DATA PRODUCT;
INPUT ProductID	Name$	Price;
DATALINES;
101	Pencil	5.5
102	Eraser	3.0
103	Sharpener	7.2
;
RUN;
? **Task**: Use `INPUT` and `DATALINES` to read this data and print the result.

---

### Problem 3: IF Statement

Using the `students` dataset from Problem 1, add a new variable called `Grade`:

* If Score = 90, Grade = 'A'
* If 80 = Score < 90, Grade = 'B'
* Else, Grade = 'C'

DATA students_with_grade;
Set Student; 
if score = 90 then Grade ='A';
Else if 80=Score<90 then Grade='B';
Else Grade = 'C';
RUN;
? **Task**: Add logic inside a `DATA` step to assign this grade.

---

### Problem 4: PROC SORT

Sort the `students` dataset by `Score` in descending order.

PROC SORT DATA = Student;
BY descending Score;
RUN;
PROC PRINT DATA = Student;
RUN;
? **Task**: Use `PROC SORT` with `DESCENDING`.


---

### Problem 5: PROC MEANS

Use the `products` dataset and compute the **average price**.

? **Task**: Use `PROC MEANS` to calculate the average of the `Price` variable.

PROC MEANS DATA = PRODUCT MEAN;
VAR Price;
RUN;
