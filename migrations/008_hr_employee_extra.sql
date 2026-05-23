-- 008: extended employee profile (contract, payroll, personal details)
-- Note: uses IF NOT EXISTS (MySQL 8.0+). If on older MySQL, remove IF NOT EXISTS clauses.
-- Run: feel migrate.feel (or execute manually via mysql client)
-- Note: ensure uploads/contracts/ directory exists relative to server working dir before
--       using the contract upload endpoint. Create it once:
--   mkdir -p uploads/contracts

ALTER TABLE hr_employees
  ADD COLUMN contract_number    VARCHAR(50)   NULL,
  ADD COLUMN contract_start     DATE          NULL,
  ADD COLUMN contract_end       DATE          NULL,
  ADD COLUMN contract_months    INT           NULL,
  ADD COLUMN contract_file      VARCHAR(500)  NULL,
  ADD COLUMN bank_name          VARCHAR(100)  NULL,
  ADD COLUMN bank_account_no    VARCHAR(50)   NULL,
  ADD COLUMN bank_account_name  VARCHAR(150)  NULL,
  ADD COLUMN salary_grade       VARCHAR(20)   NULL,
  ADD COLUMN basic_salary       DECIMAL(15,2) NULL;

-- Note: birth_place, birth_date, national_id, tax_id, marital_status, address, nickname
-- already exist in 005_hr_employees.sql — do NOT re-add them.

-- Sequence tracker for auto employee_no generation: {DEPT_CODE}-{YEAR}{3-digit-seq}
-- e.g. IT-2026001, HR-2026002
CREATE TABLE IF NOT EXISTS hr_employee_no_seq (
  department_id  BIGINT UNSIGNED NOT NULL,
  year           INT             NOT NULL,
  last_seq       INT             NOT NULL DEFAULT 0,
  PRIMARY KEY (department_id, year),
  FOREIGN KEY (department_id) REFERENCES master_departments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
