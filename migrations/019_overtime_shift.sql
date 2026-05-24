-- 019: Overtime requests, shifts, and rosters

CREATE TABLE hr_overtime_requests (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id    BIGINT UNSIGNED NOT NULL,
  employee_id   BIGINT UNSIGNED NOT NULL,
  date          DATE NOT NULL,
  start_time    TIME NOT NULL,
  end_time      TIME NOT NULL,
  duration_hours DECIMAL(4,2) NOT NULL,
  reason        TEXT NULL,
  status        ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  approved_by   BIGINT UNSIGNED NULL,
  approved_at   TIMESTAMP NULL,
  note          TEXT NULL,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_employee  (employee_id),
  INDEX idx_company   (company_id, date),
  FOREIGN KEY (employee_id) REFERENCES hr_employees(id)
) ENGINE=InnoDB;

CREATE TABLE master_shifts (
  id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id BIGINT UNSIGNED NOT NULL,
  name       VARCHAR(100) NOT NULL,
  start_time TIME NOT NULL,
  end_time   TIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_company (company_id)
) ENGINE=InnoDB;

CREATE TABLE hr_rosters (
  id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id  BIGINT UNSIGNED NOT NULL,
  employee_id BIGINT UNSIGNED NOT NULL,
  shift_id    BIGINT UNSIGNED NOT NULL,
  date        DATE NOT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_emp_date (employee_id, date),
  INDEX idx_company_date (company_id, date),
  FOREIGN KEY (employee_id) REFERENCES hr_employees(id),
  FOREIGN KEY (shift_id)    REFERENCES master_shifts(id)
) ENGINE=InnoDB;
