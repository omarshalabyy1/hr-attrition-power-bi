# The project explained, from zero

This page explains the whole project in plain words: what it does, what every word means, where every number comes from, and how to talk about it in an interview. You do not need to know Power BI or DAX to read it.

[← Back to the README](../README.md)

## 1. The project in one minute

A company has 1,470 employees. 237 of them have left. That is about one in six, and every person who leaves costs time and money to replace.

The human resources (HR) team knows the total, but not the three things it needs to act:

- **Where** do people leave? Which department, which job?
- **Why** do they leave? What do the leavers have in common?
- **Who** is likely to leave next, among the people still here?

This project answers them with a Power BI report. It takes one sheet with one row per employee, reshapes it into a clean model, writes the calculations once, and shows the answers on three pages. The last answer is a list: **295 current employees** who match three or more of six warning signs.

Think of the warning lights on a car's dashboard. One light on its own may be nothing. Three or four at once, and you stop the car. Each employee gets one "light" (a **risk flag**) for each of six signs, such as working overtime or being in the first two years at the company. The more lights, the more likely the person leaves: 4.6% of people with no flags left, 75% of people with five flags did.

## 2. Words you will meet

| Word | What it means here |
|---|---|
| **Attrition** | People leaving the company, for any reason. In the data, the column `Attrition` is "Yes" (left) or "No" (still here). |
| **Leaver, stayer, active employee** | A leaver has `Attrition` = Yes. A stayer (or active, or current, employee) has No. There are 237 leavers and 1,233 stayers. |
| **Headcount** | The number of employees in whatever you are looking at: 1,470 in total, 446 in Sales. |
| **Attrition rate** | Leavers divided by headcount. 237 / 1,470 = 16.12%. A rate lets you compare groups of different sizes. |
| **Snapshot** | The data is one picture of the company at one moment. It has no dates, so nothing here is a trend over time. |
| **Department, job role** | The three departments are Sales, Research and Development (R&D) and Human Resources. Job role is the job title, such as Sales Representative or Laboratory Technician (shortened to "Lab Tech"). |
| **Overtime** | Whether the employee works extra hours: Yes or No. |
| **Job level** | Seniority, from 1 (entry level) to 5 (most senior). |
| **Stock option level** | How many company shares the employee can get, from 0 (none) to 3. |
| **Environment satisfaction** | How happy the employee is with the workplace, a score from 1 (low) to 4 (very high). |
| **Job involvement** | How involved the employee feels in the job, a score from 1 (low) to 4 (high). |
| **Business travel** | How often the employee travels for work: Non-Travel, Travel_Rarely or Travel_Frequently. |
| **Tenure** | Years at the company (`YearsAtCompany`). |
| **Band** | A range that groups people: tenure bands 0-2, 3-5, 6-10 and 10+ years; income bands under 3k, 3-6k, 6-10k and 10k+ a month; age bands 18-25 up to 56+. |
| **Monthly income** | Monthly pay. The data does not say which currency, so the README gives it as a plain number. |
| **Risk flag** | One of six warning signs: overtime, single, job level 1, no stock options, two years or less at the company, environment satisfaction of 1. Each employee has 0 to 6 flags. |
| **Early-warning list** | The 295 current employees with three or more flags. |
| **Outlier** | A value far from the rest. Here: a very high income or a very long tenure. |
| **Quartile, IQR** | Sort everyone by a number and cut the list into four equal parts. Q1 is the value a quarter of the way up, Q3 three quarters of the way up. The interquartile range (IQR) is Q3 minus Q1. |
| **1.5 × IQR rule** | A common test for outliers: a value above Q3 + 1.5 × IQR is an outlier. See section 3 for the sums. |
| **Power BI** | Microsoft's tool for interactive reports. The whole project is one Power BI file, `HR_Attrition_Dashboard.pbix`. |
| **.pbix** | The Power BI file. It holds the data, the model, the formulas and the pages, so it opens without the source sheet. |
| **Power Query** | The part of Power BI that loads and cleans data before the report uses it. |
| **Staging query** | A Power Query step that loads and cleans the sheet once. The real tables are built from it; the staging query itself is not one of the tables you see in the model. |
| **Star schema** | One table of facts in the middle with small lookup tables around it, like a star. The standard shape for Power BI. See [data-model.png](../images/data-model.png). |
| **Fact table** | The table in the middle. Here `fact_employee`: one row per employee, with the numbers (income, years, levels, scores) and the `AttritionFlag`. |
| **Dimension table** | A small lookup table you filter and group by. Here seven: department, job role, education field, gender, marital status, travel and overtime. `dim_department` has 3 rows, one per department. |
| **Grain** | What one row stands for. The grain of `fact_employee` is "one employee". |
| **Natural key, surrogate key** | A natural key already exists in the data: `EmployeeNumber` (1 to 2,068, with gaps, never repeated). A surrogate key is a made-up number (1, 2, 3...) given to each dimension row and stored in the fact table instead of the text. |
| **Relationship, one-to-many** | The link between a dimension and the fact table. One row in `dim_department` (Sales) matches many employees. Filters flow one way: from the dimension to the facts. |
| **`AttritionFlag`** | `Attrition` turned into a number: 1 for Yes, 0 for No. Adding it up counts the leavers. |
| **DAX** | Data Analysis Expressions, the formula language of Power BI. It is used for **measures** and **calculated columns**. All of them are copied into [`dax/measures.dax`](../dax/measures.dax). |
| **Measure** | A formula worked out when a visual asks for it, for whatever is selected. `Attrition Rate %` gives 16.12% for everyone and 20.63% when only Sales is selected. There are 15, kept in their own table `_Measures`. |
| **Calculated column** | A DAX formula that adds a column and stores a value on every row. There are seven: the age, tenure and income bands, a sort order for each band, and `Risk Flags`. |
| **`VAR` ... `RETURN`** | A variable in DAX: work out a value once, give it a name, use the name below. It makes long formulas easier to read and check. 10 of the 15 measures use it; the one-line ones do not need it. |
| **`DIVIDE`** | Safe division in DAX: it returns blank instead of an error when the bottom number is 0, for example a filter that leaves no employees. |
| **`CALCULATE`, `REMOVEFILTERS`, `FILTER`, `RELATED`** | `CALCULATE` works out a measure under a changed filter ("only overtime staff"). `REMOVEFILTERS` drops all filters. `FILTER` keeps the rows that pass a test. `RELATED` reads a value from the dimension row an employee points to. |
| **`PERCENTILE.INC`** | The DAX function that finds Q1 and Q3. It works the same way as Excel's `PERCENTILE.INC`. |
| **Page, visual, card, slicer** | A report has pages; a page has visuals. A card shows one number ("Leavers 237"). A slicer is a drop-down filter; each of the three report pages has five: job role, gender, age, overtime and department. |
| **Reference line** | The red dashed line on some charts, at the company rate of 16.12%. Bars to the right of it are worse than the company as a whole. |
| **Tooltip page** | A small hidden page that pops up when you hover over a chart. Here `TT_Segment.`, with the headcount of the segment and a ring chart of how many stayed and left. |
| **SQL** | Structured Query Language, used to ask a database questions. [`sql/attrition_by_department.sql`](../sql/attrition_by_department.sql) is the one SQL file. |
| **KPI** | Key performance indicator: the one number that tells you if an action works, such as "attrition within the first two years". |
| **HR business partner (HRBP)** | An HR person who works with one part of the business, the natural owner of stay interviews. |
| **Stay interview** | A talk with an employee who is still here, about what would make them stay. The opposite of an exit interview. |
| **Correlation, cause** | Correlation: two things show up together (overtime and leaving). Cause: one makes the other happen. This data shows correlation only. |

## 3. How it works, file by file

The repo holds the finished report, the formulas copied out of it, one SQL check and the images. In build order:

| Step | Where | What it does |
|---|---|---|
| 1 | The source sheet (not in the repo; see Data in the README) | 1,470 rows and 35 columns, one row per employee. No empty cells and no repeated employees. Three columns hold the same value on every row (`EmployeeCount`, `Over18`, `StandardHours`), so they say nothing. |
| 2 | Power Query, inside `HR_Attrition_Dashboard.pbix` | One staging query cleans the sheet. Each dimension is built from the distinct values of one column, with an index as its surrogate key. `fact_employee` looks up the seven keys and keeps `EmployeeNumber`, the keys, `AttritionFlag` and the number columns. The Power Query code lives inside the .pbix; it is not exported as a text file, so this step is described from the README and the model diagram. |
| 3 | The model, inside the .pbix | The star schema: `fact_employee` (1,470 rows) and seven dimensions, each linked one-to-many. Measures sit in their own table, `_Measures`. |
| 4 | [`dax/measures.dax`](../dax/measures.dax) | A copy of the 15 measures and 7 calculated columns, taken out of the model as they are. |
| 5 | The pages, inside the .pbix | A Home page with three buttons, then 1-Overview, 2-Drivers and 3-Trends & Outliers, plus the hidden tooltip page. Screenshots: `images/pbi-*.png`. |
| 6 | [`sql/attrition_by_department.sql`](../sql/attrition_by_department.sql) | The check: counts leavers per department straight from the source sheet loaded as a database table, outside Power BI. It must give the same 133, 92 and 12 as the report. |
| 7 | `images/` | The page screenshots, five summary charts used in the README (where people leave, drivers, risk flags, outliers, actions), the model diagram, and the header and footer banners. The repo does not hold the code that drew the summary charts; their numbers match the report. |

### One real employee, step by step

Employee number 1 in the data: a 41-year-old woman, Sales Executive in the Sales department, single, works overtime, job level 2, stock option level 0, 6 years at the company, environment satisfaction 2, monthly income 5,993. She left (`Attrition` = Yes).

1. **Power Query.** "Yes" becomes `AttritionFlag` = 1. The text "Sales" is swapped for the surrogate key of the Sales row in `dim_department`; the same happens for her job role, education field (Life Sciences), gender, marital status, travel (Travel_Rarely) and overtime. Her row in `fact_employee` now holds keys and numbers, not repeated text.
2. **Bands.** Age 41 falls in the 36-45 band, 6 years in the 6-10 tenure band, 5,993 in the 3-6k income band.
3. **Risk flags.** The `Risk Flags` column tests her six signs:

   | Flag | Her value | Flag? |
   |---|---|---|
   | Overtime | Yes | 1 |
   | Single | Single | 1 |
   | Job level 1 | level 2 | 0 |
   | No stock options | level 0 | 1 |
   | Two years or less | 6 years | 0 |
   | Environment satisfaction 1 | 2 | 0 |

   1 + 1 + 0 + 1 + 0 + 0 = **3 flags**. `INT` turns each true/false test into 1 or 0 so they can be added up.
4. **Measures.** She is 1 of the 1,470 in `Headcount` and adds 1 to `Leavers` (`SUM` of `AttritionFlag`). She has three flags but is **not** in the 295: `High-Risk Active Employees` keeps only rows with `AttritionFlag = 0` **and** `Risk Flags >= 3`, and she has left. She is one of the 159 leavers among the 454 people with three or more flags.
5. **Outliers.** 5,993 is below the income line of 16,581 and 6 years is below the tenure line of 18, so she is not an outlier.

For contrast, employee number 2: 49, Research Scientist in R&D, married, no overtime, level 2, stock option level 1, 10 years, satisfaction 3. Zero flags, and he stayed. He adds 1 to `Headcount` and 0 to `Leavers`, and is one of the 285 people with no flags.

### The outlier sums

`PERCENTILE.INC` finds Q1 and Q3 of all 1,470 values:

- **Income:** Q1 = 2,911, Q3 = 8,379, so the IQR = 5,468. The line is 8,379 + 1.5 × 5,468 = **16,581**. 114 employees earn more.
- **Tenure:** Q1 = 3 years, Q3 = 9 years, so the IQR = 6. The line is 9 + 1.5 × 6 = **18 years**. 104 employees have more.

## 4. Every number, explained

The data file is not in the repo. Every number below was recomputed for this page from a local copy of the source sheet with pandas (a Python library for tables), and each one matches the README and the screenshots. The .pbix carries the same data inside, so anyone with Power BI Desktop can see the same figures there. Where the repo does not show a number, the table says so.

### The headline and the "What it found" table

| Number | What it means | How it is worked out | Where |
|---|---|---|---|
| **1,470 employees** | Everyone in the data. | Count of rows in `fact_employee`. | `Headcount`; Overview card "Employees" |
| **237 leavers** | People who left. | Sum of `AttritionFlag`. Also 133 + 92 + 12 from the SQL check. | `Leavers`; Overview card |
| **16.1% (16.12%)** | The company attrition rate. "One in six" in the banner is this number in words (1 / 6 = 16.7%). | 237 / 1,470 = 16.12%. | `Attrition Rate %`; Overview card |
| **Sales 20.6%** | The department with the highest rate. Human Resources is next at 19.0% (12 / 63). | 92 leavers / 446 in Sales. | `Attrition Rate %` by department; Overview, where-people-leave.png |
| **R&D: 133 people, 65% of staff, 13.8%** | R&D loses the most people but has the lowest rate. | 961 of 1,470 staff are in R&D (65.4%); 133 / 961 = 13.84%. | Same chart; SQL check |
| **Sales Representatives 39.8%** | The job role with the highest rate. | 33 / 83. 39.76 / 16.12 = 2.47, "two and a half times" the company rate. | `Attrition Rate %` by job role; Overview |
| **Overtime 30.5% vs 10.4%** | Attrition with and without overtime. | 127 / 416 and 110 / 1,054. | `OverTime Attrition Rate %`, `No OverTime Attrition Rate %`; Drivers cards |
| **28% of the workforce, 54% of leavers** | Overtime staff are a minority but more than half of all leavers. | 416 / 1,470 = 28.3%; 127 / 237 = 53.59%. | Drivers donut, drivers.png |
| **29.8% in the first two years** | Attrition of people with 2 years or less at the company. | 102 / 342. | `Tenure Band` "0-2" on the Overview tenure chart |
| **43% of all leavers** | Share of all leavers who left within two years. | 102 / 237 = 43.04%. | `Early Tenure Leavers %`; Drivers card |
| **8.1% after more than 10 years** | Attrition of the longest-serving band. | 20 / 246 (the 10+ band starts at 11 years). | Overview tenure chart |
| **Job level 1 at 26.3% (9.7% at level 2)** | Entry-level staff leave most. | 143 / 543 and 52 / 534. | Drivers job level chart |
| **52.6% of 156 people** | Attrition of people who are both on overtime and at level 1. | 82 / 156. | README and drivers.png only; no page in the report shows it |
| **2,046 a month** | Stayers earn this much more than leavers, on average. | 6,832.74 − 4,787.09 = 2,045.65, shown as 2,046. | `Income Gap Stayers vs Leavers`; Drivers card, drivers.png |
| **295 at risk now** | Current employees with three or more flags. | Rows with `AttritionFlag = 0` and `Risk Flags >= 3`: 454 people with 3+ flags, minus 159 who left. | `High-Risk Active Employees`; Overview card "At risk now" |
| **35% have already left** | Of everyone with three or more flags, the share who left. | 159 / 454 = 35.0%. | README only; you can add it up from risk-flags.png |

### The risk flags

| Flags | Employees | Left | Rate |
|---|---|---|---|
| 0 | 285 | 13 | 4.56% |
| 1 | 377 | 25 | 6.63% |
| 2 | 354 | 40 | 11.30% |
| 3 | 267 | 64 | 23.97% |
| 4 | 139 | 58 | 41.73% |
| 5 | 44 | 33 | 75.00% |
| 6 | 4 | 4 | 100.00% |

`Attrition Rate %` by `Risk Flags`; Drivers page and risk-flags.png. The README rounds these to 4.6%, 24%, 42% and 75%. The employee counts per row are in risk-flags.png; the "Left" column is worked out for this page (rate × employees).

### The outliers

| Number | What it means | How it is worked out | Where |
|---|---|---|---|
| **16,581** | The high-income line. | Q3 + 1.5 × IQR, see section 3. | `Income Outlier Threshold`; Trends card |
| **114** | Employees above that line. All are at job level 4 or 5. | Count of rows with income above 16,581. | `Income Outliers Count`; Trends card |
| **4.39%** | Their attrition rate. | 5 / 114. | `Income Outliers Attrition %`; Trends card "Their attrition" |
| **18 years, 104 people** | The tenure line, and how many are above it. | 9 + 1.5 × 6 = 18; count of rows above it. | `Tenure Outliers Count`; Trends card |
| **9.6%** | Attrition of the tenure outliers. | 10 / 104 = 9.62%. | README and outliers.png only; no measure computes it |

### The other numbers on the report pages

| Number | Where you see it | What it means |
|---|---|---|
| **Single 50.63%, Married 35.44%, Divorced 13.92%** | Overview pie | Each group's share of the 237 leavers (120, 84, 33). Single staff are 32% of employees (470 / 1,470) but 51% of leavers. |
| **Lab Tech 23.94% down to Research Director 2.50%** | Overview job role chart | Attrition rate per job role, for example Laboratory Technician 62 / 259. |
| **13.82%, 12.28%** | Overview tenure chart | Bands 3-5 years (60 / 434) and 6-10 years (55 / 448). |
| **9.74%, 14.68%, 4.72%, 7.25%** | Drivers job level chart | Levels 2 to 5: 52 / 534, 32 / 218, 5 / 106, 5 / 69. |
| **28.61%, 12.72%, 12.00%, 8.90%** | Drivers income chart | Income bands under 3k (113 / 395), 3-6k (66 / 519), 6-10k (33 / 275), 10k+ (25 / 281). |
| **Human Resources 25.93% ... Other 13.41%** | Trends education field chart | Rate by field of study. Human Resources is top (7 / 27), then Technical Degree (32 / 132) and Marketing (35 / 159). The chart title names the second and third; the Human Resources group is only 27 people. |
| **33.73%, 18.93%, 14.40%, 9.03%** | Trends involvement chart | Job involvement 1 to 4: 28 / 83, 71 / 375, 125 / 868, 13 / 144. |
| **277 / 69 / 24.91%, 1,043 / 156 / 14.96%, 150 / 12 / 8.00%** | Trends travel table | Headcount, leavers and rate for frequent, rare and no travel. 24.91 / 8.00 = 3.1, the "3×" in the title. |
| **5 slicers** | Top of every page | Job role (labelled "Job Rule"), gender, age band, overtime and department. |

### The other images

| Number | Where you see it | What it means |
|---|---|---|
| **24.4%** | actions.png | Attrition of people with no stock options: 154 / 631. |
| **66.7%** | actions.png | Attrition of Sales Representatives on overtime: 16 / 24. |
| **24 to 75% risk** | actions.png | The rates for 3, 4 and 5 flags. |
| **1,470 rows, 35 columns, 7 dimensions** | data-model.png | The fact table size, the source columns and the seven lookup tables. |
| **16.1%, 39.8%, 295, 30.5%, 10.4%** | header.svg | The company rate, Sales Representatives, the early-warning list and overtime, all from the tables above. |

Things that can look wrong but are not:

- **The pie and the donut show shares of leavers, not rates.** Single is 50.63% of leavers; the attrition rate of single staff is 25.5% (120 / 470, worked out for this page).
- **R&D has the most leavers and the lowest rate.** It is 65% of the company. Counts show the size of the cost; rates show where the problem is.
- **Level 3 (14.68%) is higher than level 2 (9.74%).** The line is not smooth; that is what the data says.
- **6 flags = 100%.** It is four people, all of whom left. Too few to read anything into.
- **"3+ flags means 1 in 4 leave" on the charts, but 35% in the README.** The charts point at the 3-flag bar, about 24%. The 35% is everyone with 3, 4, 5 or 6 flags together. And "295 current employees, a group where 35% have already left" means: among all 454 people with three or more flags, 35% left, and 295 are still here.
- **The red line stays at 16.12% when you use a slicer.** It is the company rate on purpose, so you can compare any selection with the whole company. In the .pbix it is typed in as a fixed value (0.1612), not taken from the `Company Attrition Rate %` measure. See section 7.
- **16.1% in the README, 16.12% in the report.** The same number, rounded to one or two decimals.
- **"Job Rule" on the slicer** means job role.
- **The scatter title says "above and right of the lines", but no lines are drawn.** Read it as: above 16,581 a month or right of 18 years.

## 5. What the results mean for the business

- **One in six people leave, and it is not spread evenly.** Sales has the highest rate, and Sales Representatives leave at two and a half times the company rate. R&D loses the most people only because it is the biggest department.
- **Overtime is the biggest single sign.** 30.5% of overtime staff leave against 10.4% of the rest, and they make up more than half of all leavers. It is also something the company controls.
- **The first two years are the danger zone.** 43% of leavers go in that window. Better onboarding reaches people before they decide.
- **Entry-level pay matters.** Level 1 staff leave at 26.3%, and leavers earn 2,046 a month less on average. Attrition falls as pay rises.
- **HR can act this month.** The 295 current employees with three or more flags are a short, named list for stay interviews, instead of spreading retention money across all 1,233 people still here.
- **The senior, well-paid and long-serving staff stay.** High-income outliers leave at 4.4%. Retention money is better spent lower down.
- **Each of the five actions in the README has a KPI and an owner**, so in six months HR can check whether it worked. See [actions.png](../images/actions.png).

## 6. Interview questions you can expect

**Explain the project in 30 seconds.**
An HR team saw one in six employees leave but could not say where, why or who was next. I cleaned the sheet in Power Query, built a star schema with one fact table and seven dimensions, wrote 15 DAX measures, and built a three-page Power BI report. Result: 16.1% attrition, highest in Sales Representatives at 39.8%, overtime staff leaving at three times the rate of others, and an early-warning list of 295 current employees with three or more risk flags.

**The data is one flat sheet. Why build a star schema?**
Each dimension becomes a small table with one row per value, so slicers read 3 departments instead of scanning 1,470 rows, and a filter flows one way, from the dimension to the facts, which is easy to reason about. It is also the shape Power BI is built for, and it makes the model ready for more data, such as monthly snapshots.

**Why is `Risk Flags` a calculated column and not a measure?**
It belongs to one employee and does not change with filters. Stored on each row, it can go on a chart axis (0 to 6 flags) and be tested row by row inside `FILTER` in `High-Risk Active Employees`. A measure gives one answer for a whole selection, not one per person.

**Why use `VAR` and `DIVIDE`?**
`VAR` names each part of a formula, so `Income Outlier Threshold` reads like the rule itself: Q1, Q3, then Q3 + 1.5 × (Q3 − Q1). Each value is worked out once. `DIVIDE` returns blank instead of an error when a slicer leaves no employees.

**How did you choose the six flags?**
The README calls them the six strongest single drivers. Each is a large group, 284 to 631 people, with an attrition rate between 24.4% and 30.5%, against 16.1% for the company. Some smaller groups have higher rates, for example employees aged 25 or under at 35.8% of 123 people (worked out for this page, not shown in the repo). A fair next step is to test whether adding a flag like that makes the list better at catching leavers.

**Why keep the outliers?**
They are real people, not typing errors: the 114 high earners are all at job level 4 or 5. They also carry a finding: they leave at 4.4%, far below 16.1%. Removing them would hide that seniority and pay protect retention.

**Which matters more, the count of leavers or the rate?**
Both, for different questions. R&D has the most leavers (133) but the lowest rate (13.8%), because it holds 65% of the staff. The count shows the size of the cost; the rate shows where something is wrong.

**Does overtime make people leave?**
The data cannot say. It is one snapshot with no exit reasons, so it shows that overtime and leaving go together, not that one causes the other. That is why the actions are written as pilots with a KPI: if overtime drops in Sales and attrition drops with it, that is much stronger evidence.

**How do you know the numbers are right?**
The SQL file counts leavers per department straight from the source table, outside Power BI, and gets 133, 92 and 12, the same as the report. The README says every number was also recomputed outside Power BI; for this page they were recomputed again from the source sheet with pandas, and all match.

**What would you do with more data?**
Load a monthly HR snapshot, so attrition can be tracked over time instead of across bands, and add exit-interview reasons, so the drivers can be tested and not only observed. Then run actions 1 and 2 as a pilot in Sales and the Lab Tech teams and compare their KPIs with the rest.

## 7. Limits, in plain words

- One snapshot with no dates: "trend" here means across bands (tenure, pay, age, involvement), not over time.
- No exit reasons, so the drivers show what leavers have in common, not why they left.
- Some groups are small: six flags is four people, and the Human Resources education field is 27 people.
- The six flags all count the same. Overtime and low environment satisfaction each add one, even though their rates differ.
- The employees are fictional (see Data in the README), and the data does not say which currency the income is in.
- The red 16.12% line is typed in as a fixed value. If the report were refreshed with new data, it would stay at 16.12% until someone changes it.
- The outlier lines are measures, so they are worked out for whatever is selected: pick Sales in the department slicer and Q1, Q3 and the line are worked out for Sales staff only.
- The source sheet is not in the repo, and the Power Query code is only inside the .pbix. The SQL check runs only after the sheet is loaded into a database as a table named `HR_Employee_Attrition`.
