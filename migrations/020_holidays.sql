-- 020: Public + company holiday calendar

CREATE TABLE master_holidays (
  id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id BIGINT UNSIGNED NOT NULL,
  date       DATE NOT NULL,
  name       VARCHAR(100) NOT NULL,
  type       ENUM('national','company') NOT NULL DEFAULT 'national',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_company_date (company_id, date),
  INDEX idx_company_month (company_id, date)
) ENGINE=InnoDB;
