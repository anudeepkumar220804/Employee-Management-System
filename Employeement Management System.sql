USE EmployeeManagementSystem;

CREATE TABLE JobDepartment (
	Job_ID INT PRIMARY KEY,
	jobdept VARCHAR(50),
	name VARCHAR(100),
	description TEXT,
	salaryrange VARCHAR(50)
);

SELECT * FROM jobdepartment;

CREATE TABLE SalaryBonus (
	salary_ID INT PRIMARY KEY,
	Job_ID INT,
	amount DECIMAL(10,2),
	annual DECIMAL(10,2),
	bonus DECIMAL(10,2),
	CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
	ON DELETE CASCADE ON UPDATE CASCADE
);
SELECT * FROM salarybonus;

CREATE TABLE Employee (
	emp_ID INT PRIMARY KEY,
	firstname VARCHAR(50),
	lastname VARCHAR(50),
	gender VARCHAR(10),
	age INT,
	contact_add VARCHAR(100),
	emp_email VARCHAR(100) UNIQUE,
	emp_pass VARCHAR(50),
	Job_ID INT,
	CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
	REFERENCES JobDepartment(Job_ID)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);
SELECT * FROM employee;

CREATE TABLE Qualification (
	QualID INT PRIMARY KEY,
	Emp_ID INT,
	Position VARCHAR(50),
	Requirements VARCHAR(255),
	Date_In DATE,
	CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
	REFERENCES Employee(emp_ID)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);
SELECT * FROM Qualification;

CREATE TABLE Leaves (
	leave_ID INT PRIMARY KEY,
	emp_ID INT,
	date DATE,
	reason TEXT,
	CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
	ON DELETE CASCADE ON UPDATE CASCADE
);
SELECT * FROM Leaves;

CREATE TABLE Payroll (
	payroll_ID INT PRIMARY KEY,
	emp_ID INT,
	job_ID INT,
	salary_ID INT,
	leave_ID INT,
	date DATE,
	report TEXT,
	total_amount DECIMAL(10,2),
	CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES
	SalaryBonus(salary_ID)
	ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
	ON DELETE SET NULL ON UPDATE CASCADE
);
SELECT * FROM  Payroll;

# 1.EMPLOYEE INSIGHTS

# 1.1 How many unique employees are currently in the system?

SELECT count(DISTINCT Job_ID) AS Total_Employee
FROM employee;

# 1.2 Which departments have the highest number of employees?

SELECT j.jobdept,COUNT(e.emp_id) AS employee_count
FROM employee e
JOIN JobDepartment j ON e.Job_ID = j.Job_ID
GROUP BY j.jobdept
ORDER BY employee_count DESC;

# 1.3 What is the average salary per department?

SELECT jd.jobdept,AVG(sb.amount)
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

# 1.4 Who are the top 5 highest-paid employees?

SELECT 
    e.emp_ID,
    e.firstname,
    e.lastname,
    sb.amount AS Salary
FROM Employee e
JOIN SalaryBonus sb
    ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

# 1.5 What is the total salary expenditure across the company?

SELECT SUM(annual + bonus ) AS total_salary_expenditure
FROM Salarybonus;

# 2 . JOB ROLE AND DEPARTMENT ANALYSIS

# 2.1 How many different job roles exist in each department?

SELECT jobdept,COUNT(DISTINCT name) AS total_job_roles
FROM JobDepartment
GROUP BY jobdept;

# 2.2 What is the average salary range per department?

SELECT jd.jobdept,avg(sb.amount) as avg_salary,min(sb.amount) as min_salary, max(sb.amount) as max_amount
FROM jobdepartment as jd
join salarybonus as sb
on jd.job_id = sb.job_id
group by jd. jobdept
order by avg_salary;

# 2.3 Which job roles offer the highest salary?

SELECT jd.name, sb.amount
FROM Jobdepartment jd
JOIN Salarybonus sb ON jd.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC;

# 2.4 Which departments have the highest total salary allocation?

SELECT jd.jobdept,SUM(sb.amount) AS total_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_salary DESC;

# 3 QUALIFICATION AND SKILLS ANALYSIS

# 3.1 How many employees have at least one qualification listed?

SELECT COUNT(DISTINCT Emp_ID) AS employees_with_qualification
FROM Qualification;

# 3.2 Which positions require the most qualifications?

SELECT Position,COUNT(*) AS qualification_count
FROM Qualification
GROUP BY Position
ORDER BY qualification_count DESC;

# 3.3 Which employees have the highest number of qualifications?

SELECT e.firstname,e.lastname,COUNT(q.QualID) AS total_qualifications
FROM Employee e
JOIN Qualification q ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID
ORDER BY total_qualifications DESC;

# 4 LEAVE AND ABSENCE PATTERNS

# 4.1 Which year had the most employees taking leaves?

SELECT YEAR(date) AS year, COUNT(*) AS leave_count
FROM Leaves
GROUP BY YEAR(date)
ORDER BY leave_count DESC;

# 4.2 What is the average number of leave days taken by its employees per department?

# 4.3 Which employees have taken the most leaves?

SELECT e.emp_ID,
       e.firstname,
       e.lastname,
       COUNT(l.leave_ID) AS total_leaves
FROM Employee e
JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY total_leaves DESC;

# 4.4 What is the total number of leave days taken company-wide?

SELECT COUNT(*) AS total_leave_days
FROM Leaves;

# 4.5 How do leave days correlate with payroll amounts?

select p.emp_id,count(l.leave_id),sum(p.total_amount)
from leaves as l
left join payroll as p
on l.emp_id = p.emp_id
group by p.emp_id
order by sum(p.total_amount)desc;

# PAYROLL AND COMPENSATION ANALYSIS

# 5.1 What is the total monthly payroll processed?

SELECT YEAR(date) AS year,
       MONTH(date) AS month,
       SUM(total_amount) AS total_monthly_payroll
FROM Payroll
GROUP BY YEAR(date), MONTH(date)
ORDER BY year, month;


# 5.2 What is the average bonus given per department?

SELECT jd.jobdept,
       AVG(sb.bonus) AS avg_bonus
FROM JobDepartment jd
JOIN SalaryBonus sb
     ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

# 5.3 Which department receives the highest total bonuses?

SELECT jd.jobdept,
       SUM(sb.bonus) AS total_bonus
FROM JobDepartment jd
JOIN SalaryBonus sb
     ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_bonus DESC;

# 5.4 What is the average value of total_amount after considering leave deductions?

SELECT AVG(total_amount) AS avg_net_salary
	FROM Payroll;





