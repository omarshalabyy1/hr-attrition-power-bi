-- HR Attrition Case Study | Omar Sabry
-- Question: How many employees left the company in each department?
-- Table: HR_Employee_Attrition (the raw data sheet, 1,470 rows)

SELECT
    Department,
    COUNT(*) AS Leavers              -- count the employees in each department
FROM HR_Employee_Attrition
WHERE Attrition = 'Yes'              -- keep only employees who left
GROUP BY Department                  -- one row per department
ORDER BY Leavers DESC;               -- highest number first
