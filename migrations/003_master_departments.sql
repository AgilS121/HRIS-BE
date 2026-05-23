-- Master module — departments per company.
-- Parent_id support hirarki (Direksi → Divisi → Departemen → Seksi).

CREATE TABLE master_departments (
  id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id   BIGINT UNSIGNED NOT NULL,
  parent_id    BIGINT UNSIGNED NULL,
  code         VARCHAR(30) NOT NULL,
  name         VARCHAR(150) NOT NULL,
  is_active    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY uniq_company_code (company_id, code),
  INDEX idx_company (company_id),
  INDEX idx_parent (parent_id),
  INDEX idx_active (is_active),

  FOREIGN KEY (company_id) REFERENCES master_companies(id) ON DELETE CASCADE,
  FOREIGN KEY (parent_id)  REFERENCES master_departments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
