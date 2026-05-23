-- HR module — attendance daily records.
-- Satu baris per (employee, work_date). Clock-in/out punya timestamp masing-masing.

CREATE TABLE hr_attendance (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  employee_id     BIGINT UNSIGNED NOT NULL,
  work_date       DATE NOT NULL,
  clock_in_at     TIMESTAMP NULL,
  clock_in_lat    DECIMAL(10,7) NULL,
  clock_in_lng    DECIMAL(10,7) NULL,
  clock_out_at    TIMESTAMP NULL,
  clock_out_lat   DECIMAL(10,7) NULL,
  clock_out_lng   DECIMAL(10,7) NULL,
  status          ENUM('present','late','absent','sick','permit','leave','holiday','wfh')
                  NOT NULL DEFAULT 'present',
  note            TEXT,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY uniq_employee_date (employee_id, work_date),
  INDEX idx_employee (employee_id),
  INDEX idx_date (work_date),
  INDEX idx_status (status),

  FOREIGN KEY (employee_id) REFERENCES hr_employees(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
