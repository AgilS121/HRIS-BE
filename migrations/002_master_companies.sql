-- Master module — companies (top of HRIS hierarchy)

CREATE TABLE master_companies (
  id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  code         VARCHAR(20) UNIQUE NOT NULL,
  name         VARCHAR(150) NOT NULL,
  legal_name   VARCHAR(200),
  tax_id       VARCHAR(50),
  address      TEXT,
  phone        VARCHAR(30),
  email        VARCHAR(120),
  is_active    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
