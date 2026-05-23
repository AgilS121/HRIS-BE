-- HR module — employees.
-- Catatan disiplin: HR HARUS akses department/position via master/service.feel,
-- bukan join langsung. FK di sini hanya untuk integritas, bukan untuk query lintas modul.

CREATE TABLE hr_employees (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id      BIGINT UNSIGNED NOT NULL,
  user_id         BIGINT UNSIGNED NULL,   -- link ke auth_users (kalau ybs bisa login)
  department_id   BIGINT UNSIGNED NOT NULL,
  position_id     BIGINT UNSIGNED NOT NULL,
  superior_id     BIGINT UNSIGNED NULL,   -- atasan langsung (self-reference)

  -- Identitas
  employee_no     VARCHAR(30) NOT NULL,
  full_name       VARCHAR(150) NOT NULL,
  nickname        VARCHAR(50),
  gender          ENUM('M','F') NOT NULL,
  birth_place     VARCHAR(100),
  birth_date      DATE,
  national_id     VARCHAR(30),            -- KTP / NIK
  tax_id          VARCHAR(30),            -- NPWP
  marital_status  ENUM('single','married','divorced','widowed') DEFAULT 'single',

  -- Kontak
  email           VARCHAR(120),
  phone           VARCHAR(30),
  address         TEXT,

  -- Employment
  join_date       DATE NOT NULL,
  resign_date     DATE NULL,
  employment_type ENUM('permanent','contract','intern','outsource') DEFAULT 'permanent',
  status          ENUM('active','resigned','terminated','suspended') NOT NULL DEFAULT 'active',

  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY uniq_company_no (company_id, employee_no),
  INDEX idx_company (company_id),
  INDEX idx_department (department_id),
  INDEX idx_position (position_id),
  INDEX idx_superior (superior_id),
  INDEX idx_status (status),
  INDEX idx_user (user_id),

  FOREIGN KEY (company_id)    REFERENCES master_companies(id)    ON DELETE CASCADE,
  FOREIGN KEY (department_id) REFERENCES master_departments(id)  ON DELETE RESTRICT,
  FOREIGN KEY (position_id)   REFERENCES master_positions(id)    ON DELETE RESTRICT,
  FOREIGN KEY (superior_id)   REFERENCES hr_employees(id)        ON DELETE SET NULL,
  FOREIGN KEY (user_id)       REFERENCES auth_users(id)          ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
