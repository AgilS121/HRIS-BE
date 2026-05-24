-- Work schedules and late deduction rules per company.

CREATE TABLE master_work_schedules (
  id                   BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id           BIGINT UNSIGNED NOT NULL,
  name                 VARCHAR(100) NOT NULL DEFAULT 'Standard',
  work_start           TIME NOT NULL DEFAULT '08:00:00',
  work_end             TIME NOT NULL DEFAULT '17:00:00',
  grace_period_minutes INT NOT NULL DEFAULT 15,
  is_default           TINYINT(1) NOT NULL DEFAULT 1,
  is_active            TINYINT(1) NOT NULL DEFAULT 1,
  created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (company_id) REFERENCES master_companies(id) ON DELETE CASCADE
);

-- Tiered late deduction rules.
-- min_minutes <= minutes_late < max_minutes (null max = no upper bound).
CREATE TABLE master_late_rules (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id       BIGINT UNSIGNED NOT NULL,
  min_minutes      INT NOT NULL,
  max_minutes      INT NULL,
  deduction_type   ENUM('fixed', 'percentage') NOT NULL DEFAULT 'fixed',
  deduction_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  description      VARCHAR(255) NULL,
  FOREIGN KEY (company_id) REFERENCES master_companies(id) ON DELETE CASCADE
);

-- Add late tracking columns to hr_attendance.
ALTER TABLE hr_attendance
  ADD COLUMN minutes_late     INT NULL          AFTER selfie_in_path,
  ADD COLUMN deduction_amount DECIMAL(15,2) NULL DEFAULT 0 AFTER minutes_late;

-- Default schedule for company 1.
INSERT INTO master_work_schedules (company_id, name, work_start, work_end, grace_period_minutes, is_default)
VALUES (1, 'Standard', '08:00:00', '17:00:00', 15, 1);
