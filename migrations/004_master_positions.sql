-- Master module — positions/jabatan.
-- Level untuk hierarchy approval nanti (Staff=1, Supervisor=2, Manager=3, dst).

CREATE TABLE master_positions (
  id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id   BIGINT UNSIGNED NOT NULL,
  code         VARCHAR(30) NOT NULL,
  name         VARCHAR(150) NOT NULL,
  level        INT UNSIGNED NOT NULL DEFAULT 1,
  is_active    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY uniq_company_code (company_id, code),
  INDEX idx_company (company_id),
  INDEX idx_level (level),
  INDEX idx_active (is_active),

  FOREIGN KEY (company_id) REFERENCES master_companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
