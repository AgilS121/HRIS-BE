-- Payroll module: components, runs, payslips
-- Also extends leave_types & leave_requests with deduction policy

-- ─── Extend leave types ───────────────────────────────────────────────────────

ALTER TABLE hr_leave_types
  ADD COLUMN deduction_type    ENUM('none','salary_cut','quota_cut','employee_choice')
                               NOT NULL DEFAULT 'none'   AFTER is_encashable,
  ADD COLUMN deduction_formula ENUM('none','per_day','percentage','fixed_amount')
                               NOT NULL DEFAULT 'none'   AFTER deduction_type,
  ADD COLUMN deduction_rate    DECIMAL(10,4) NOT NULL DEFAULT 0  AFTER deduction_formula;
  -- per_day:      potongan = basic_salary / working_days * absent_days
  -- percentage:   potongan = basic_salary * rate/100 * absent_days
  -- fixed_amount: potongan = rate * absent_days (nominal flat per hari)

-- ─── Extend leave requests ────────────────────────────────────────────────────

ALTER TABLE hr_leave_requests
  ADD COLUMN deduction_choice  ENUM('salary_cut','quota_cut') NULL AFTER attachment_path,
  ADD COLUMN deduction_amount  DECIMAL(15,2) NULL              AFTER deduction_choice;
  -- deduction_choice: diisi karyawan saat submit (jika leave type = employee_choice)
  -- deduction_amount: bisa di-override HR saat approve (NULL = hitung otomatis)

-- ─── Payroll components (master per perusahaan) ───────────────────────────────

CREATE TABLE hr_payroll_components (
  id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id   BIGINT UNSIGNED NOT NULL,
  code         VARCHAR(20)  NOT NULL,
  name         VARCHAR(100) NOT NULL,
  type         ENUM('earning','deduction') NOT NULL,
  category     ENUM(
                 'basic',        -- gaji pokok (referensi, tidak digenerate)
                 'allowance',    -- tunjangan (makan, transport, jabatan, dll)
                 'absence_cut',  -- potongan dari komponen absen (legacy)
                 'bpjs_kes',     -- BPJS Kesehatan
                 'bpjs_jht',     -- BPJS Jaminan Hari Tua
                 'bpjs_jkk',     -- BPJS Jaminan Kecelakaan Kerja
                 'bpjs_jp',      -- BPJS Jaminan Pensiun
                 'tax',          -- PPh21 / pajak
                 'loan',         -- cicilan pinjaman karyawan
                 'custom'        -- bebas
               ) NOT NULL DEFAULT 'custom',
  calc_basis   ENUM('fixed','pct_basic','pct_gross','per_absent_day') NOT NULL DEFAULT 'fixed',
  rate         DECIMAL(10,4) NOT NULL DEFAULT 0,
  -- fixed:          amount = rate
  -- pct_basic:      amount = basic_salary * rate / 100
  -- pct_gross:      amount = gross_earnings * rate / 100
  -- per_absent_day: amount = rate * absent_days_bulan_itu
  is_taxable   BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order   SMALLINT NOT NULL DEFAULT 0,
  is_active    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uq_component_code (company_id, code),
  INDEX idx_company (company_id),
  FOREIGN KEY (company_id) REFERENCES master_companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Employee component overrides ────────────────────────────────────────────

CREATE TABLE hr_employee_components (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  employee_id     BIGINT UNSIGNED NOT NULL,
  component_id    BIGINT UNSIGNED NOT NULL,
  override_amount DECIMAL(15,2)   NULL,   -- NULL = pakai rate dari company default
  effective_from  DATE            NOT NULL,
  effective_to    DATE            NULL,    -- NULL = tidak ada batas
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  note            VARCHAR(255)    NULL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_employee (employee_id),
  INDEX idx_component (component_id),
  FOREIGN KEY (employee_id)  REFERENCES hr_employees(id)           ON DELETE CASCADE,
  FOREIGN KEY (component_id) REFERENCES hr_payroll_components(id)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Payroll runs (batch bulanan) ────────────────────────────────────────────

CREATE TABLE hr_payroll_runs (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id    BIGINT UNSIGNED NOT NULL,
  period_year   SMALLINT UNSIGNED NOT NULL,
  period_month  TINYINT  UNSIGNED NOT NULL,   -- 1–12
  working_days  TINYINT  UNSIGNED NOT NULL DEFAULT 22,
  status        ENUM('draft','locked','paid') NOT NULL DEFAULT 'draft',
  notes         TEXT NULL,
  processed_at  TIMESTAMP NULL,
  processed_by  BIGINT UNSIGNED NULL,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uq_run (company_id, period_year, period_month),
  INDEX idx_company (company_id),
  FOREIGN KEY (company_id) REFERENCES master_companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Payslips per karyawan ────────────────────────────────────────────────────

CREATE TABLE hr_payslips (
  id               BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  payroll_run_id   BIGINT UNSIGNED NOT NULL,
  employee_id      BIGINT UNSIGNED NOT NULL,
  basic_salary     DECIMAL(15,2) NOT NULL DEFAULT 0,
  gross_earnings   DECIMAL(15,2) NOT NULL DEFAULT 0,
  total_deductions DECIMAL(15,2) NOT NULL DEFAULT 0,
  net_salary       DECIMAL(15,2) NOT NULL DEFAULT 0,
  absent_days      TINYINT UNSIGNED NOT NULL DEFAULT 0,
  leave_days       TINYINT UNSIGNED NOT NULL DEFAULT 0,
  working_days     TINYINT UNSIGNED NOT NULL DEFAULT 22,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uq_payslip (payroll_run_id, employee_id),
  INDEX idx_run (payroll_run_id),
  FOREIGN KEY (payroll_run_id) REFERENCES hr_payroll_runs(id) ON DELETE CASCADE,
  FOREIGN KEY (employee_id)    REFERENCES hr_employees(id)    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Payslip line items ───────────────────────────────────────────────────────

CREATE TABLE hr_payslip_items (
  id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  payslip_id     BIGINT UNSIGNED NOT NULL,
  component_id   BIGINT UNSIGNED NULL,   -- NULL = item manual / izin ad-hoc
  component_name VARCHAR(100) NOT NULL,
  type           ENUM('earning','deduction') NOT NULL,
  amount         DECIMAL(15,2) NOT NULL DEFAULT 0,
  note           TEXT NULL,
  sort_order     SMALLINT NOT NULL DEFAULT 0,

  INDEX idx_payslip (payslip_id),
  FOREIGN KEY (payslip_id) REFERENCES hr_payslips(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
