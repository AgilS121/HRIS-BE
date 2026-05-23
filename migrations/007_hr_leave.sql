-- HR module — leave (cuti) management.
-- leave_types: master cuti yang berlaku (annual, sick, maternity, dll).
-- leave_balances: berapa hari sisa per (employee, leave_type, year).
-- leave_requests: pengajuan cuti — di-approve/reject by atasan.

CREATE TABLE hr_leave_types (
  id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id   BIGINT UNSIGNED NOT NULL,
  code         VARCHAR(20) NOT NULL,    -- "annual", "sick", "maternity", "permit", dll
  name         VARCHAR(100) NOT NULL,
  default_quota_days INT NOT NULL DEFAULT 0,  -- -1 = unlimited (sick leave)
  is_paid      BOOLEAN NOT NULL DEFAULT TRUE,
  is_active    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY uniq_company_code (company_id, code),
  FOREIGN KEY (company_id) REFERENCES master_companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE hr_leave_balances (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  employee_id   BIGINT UNSIGNED NOT NULL,
  leave_type_id BIGINT UNSIGNED NOT NULL,
  year          INT UNSIGNED NOT NULL,
  quota_days    INT NOT NULL DEFAULT 0,
  used_days     INT NOT NULL DEFAULT 0,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY uniq_employee_type_year (employee_id, leave_type_id, year),
  INDEX idx_employee (employee_id),
  INDEX idx_year (year),

  FOREIGN KEY (employee_id)   REFERENCES hr_employees(id)    ON DELETE CASCADE,
  FOREIGN KEY (leave_type_id) REFERENCES hr_leave_types(id)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE hr_leave_requests (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  employee_id     BIGINT UNSIGNED NOT NULL,
  leave_type_id   BIGINT UNSIGNED NOT NULL,
  start_date      DATE NOT NULL,
  end_date        DATE NOT NULL,
  total_days      INT NOT NULL,
  reason          TEXT,
  status          ENUM('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
  approved_by     BIGINT UNSIGNED NULL,    -- employee_id approver
  approved_at     TIMESTAMP NULL,
  rejection_note  TEXT,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_employee (employee_id),
  INDEX idx_status (status),
  INDEX idx_dates (start_date, end_date),

  FOREIGN KEY (employee_id)   REFERENCES hr_employees(id)   ON DELETE CASCADE,
  FOREIGN KEY (leave_type_id) REFERENCES hr_leave_types(id) ON DELETE RESTRICT,
  FOREIGN KEY (approved_by)   REFERENCES hr_employees(id)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
