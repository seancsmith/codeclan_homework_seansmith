-- LAB + HW

-- Question 1

SELECT 
    count(id) AS lacking_both
FROM employees
WHERE grade IS NULL
AND salary IS NULL

-- Question 2

SELECT 
    concat(first_name, ' ', last_name),
    department
FROM employees
ORDER BY last_name 


-- Question 3

SELECT 
    first_name,
    last_name,
    salary 
FROM employees
WHERE last_name LIKE 'A%'
ORDER BY salary DESC NULLS LAST
LIMIT 10;

-- Question 4

SELECT
    department,
    count(id)
FROM employees 
WHERE EXTRACT(YEAR FROM start_date) = 2003
GROUP BY department;


-- Question 5

SELECT 
    department,
    fte_hours,
    count(id) 
FROM employees
GROUP BY department, fte_hours
ORDER BY department , fte_hours


-- Question 6

SELECT
    count(id) AS n_employees,
    pension_enrol 
FROM employees
GROUP BY pension_enrol;


-- Question 7

SELECT *
FROM employees 
WHERE (department = 'Accounting')
    AND (pension_enrol = FALSE)
ORDER BY salary DESC NULLS LAST
LIMIT 1;

-- Question 8

SELECT
    country,
    count(id) AS n_employees,
    avg(salary)
FROM employees
GROUP BY country
HAVING count(id) > 30
ORDER BY avg(salary) DESC NULLS LAST

-- Question 9

SELECT 
    first_name,
    last_name,
    fte_hours,
    salary,
    fte_hours * salary AS effective_yearly_salary
FROM employees
WHERE (fte_hours * salary) > 30000

-- Question 10

SELECT *
FROM employees AS e INNER JOIN teams AS t
ON e.team_id  = t.id 
WHERE t.name = 'Data Team 1'
    OR t.name = 'Data Team 2'


-- Question 11

SELECT
    e.first_name,
    e.last_name
FROM employees AS e FULL JOIN pay_details AS p_d
ON e.pay_detail_id = p_d.id
WHERE p_d.local_tax_code IS NULL;


-- Question 12

SELECT
    e.id,
    e.first_name,
    e.last_name,
    (48 * 35 * CAST(t.charge_cost AS INT) - e.salary) * e.fte_hours AS expected_profit
FROM employees AS e INNER JOIN teams AS t
ON e.team_id = t.id
ORDER BY expected_profit DESC NULLS LAST


-- Question 13

SELECT
    count(id),
    fte_hours
FROM employees
GROUP BY fte_hours
ORDER BY count(fte_hours) ASC
LIMIT 1;

SELECT 
    first_name,
    last_name,
    salary
FROM employees
WHERE country = 'Japan'
    AND (fte_hours = (
    SELECT
        fte_hours
    FROM employees
    GROUP BY fte_hours
    ORDER BY count(fte_hours)
    LIMIT 1)
    )
ORDER BY salary
LIMIT 1    
;
    

-- Question 14

SELECT 
    department,
    count(id) AS no_name_count
FROM employees
WHERE first_name IS NULL
GROUP BY department
HAVING count(id) >= 2
ORDER BY department 


-- Question 15

SELECT
    first_name,
    count(first_name)
FROM employees
WHERE first_name IS NOT NULL
GROUP BY first_name
HAVING count(first_name) > 1
ORDER BY count(first_name) DESC, first_name


-- Question 16

SELECT
    department,
    sum(CAST((grade = 1) AS INT)) AS grade_1_total,
    sum(CAST((grade != 1) AS INT)) AS grade_not_1,
    CAST(sum(CAST((grade = 1) AS INT)) AS REAL)/ CAST(count(id) AS REAL) AS grade_prop
FROM employees
GROUP BY department
ORDER BY department;

SELECT
    department,
    sum(CAST((grade = 1) AS INT)) AS grade_1_total,
    sum(CAST((grade != 1) AS INT)) AS grade_not_1,
    CAST(sum(CAST((grade = 1) AS INT)) AS REAL)/ 
    CAST((sum(CAST((grade = 1) AS INT))) + sum(CAST((grade != 1) AS INT)) AS REAL) AS grade_1_prop
FROM employees
GROUP BY department
ORDER BY department;

-- 2 Extension

-- Question 1

SELECT
  id,  
  first_name,
  last_name,
  department,
  salary,
  (salary / avg(salary) OVER (PARTITION BY department)) AS salary_ratio,
  fte_hours,
  (fte_hours / avg(fte_hours) OVER (PARTITION BY department)) as fte_hours_ratio
FROM employees
ORDER BY id;

-- Question 2

SELECT
    count(id) AS n_employees,
    (CASE 
    WHEN pension_enrol IS FALSE THEN
        'unknown'
    WHEN pension_enrol IS TRUE THEN
        'enrolled'
    WHEN pension_enrol IS NULL THEN
        'not enrolled'
    END) AS enrolement_status,
    pension_enrol   
FROM employees
GROUP BY pension_enrol;

-- Question 3

SELECT 
    e.first_name,
    e.last_name,
    e.email,
    e.start_date,
    e_c.committee_id 
FROM employees AS e INNER JOIN employees_committees AS e_c
ON e.id = e_c.employee_id 

SELECT
    ec_details.first_name,
    ec_details.last_name,
    ec_details.email,
    ec_details.start_date
FROM (
    SELECT 
        e.first_name,
        e.last_name,
        e.email,
        e.start_date,
        e_c.committee_id 
    FROM employees AS e INNER JOIN employees_committees AS e_c
    ON e.id = e_c.employee_id) AS ec_details
    INNER JOIN committees AS c
    ON ec_details.committee_id = c.id
WHERE c.name = 'Equality and Diversity' 
ORDER BY ec_details.start_date


-- Question 4

SELECT 
    count(DISTINCT(e.id)),
    (CASE
        WHEN salary < 40000 THEN 'low'
        WHEN salary >= 40000 THEN 'high'
        WHEN salary IS NULL THEN 'none'
        END) AS salary_class
FROM employees AS e INNER JOIN employees_committees AS e_c 
ON e.id = e_c.employee_id
GROUP BY salary_class;

