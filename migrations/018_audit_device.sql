-- Phase 2: Audit log + device binding + prorate note column

-- ─── Audit Log ────────────────────────────────────────────────────────────────

CREATE TABLE hr_audit_logs (
  id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  company_id   BIGINT UNSIGNED NOT NULL,
  user_id      BIGINT UNSIGNED NULL,
  employee_id  BIGINT UNSIGNED NULL,
  action       VARCHAR(50)  NOT NULL,
  entity_type  VARCHAR(50)  NOT NULL,
  entity_id    BIGINT UNSIGNED NULL,
  note         TEXT NULL,
  ip_address   VARCHAR(45) NULL,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_company  (company_id),
  INDEX idx_entity   (entity_type, entity_id),
  INDEX idx_created  (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Device Binding (mobile app login tracking) ──────────────────────────────

ALTER TABLE auth_users
  ADD COLUMN device_id  VARCHAR(100) NULL AFTER password_hash,
  ADD COLUMN last_login TIMESTAMP    NULL AFTER device_id,
  ADD COLUMN last_ip    VARCHAR(45)  NULL AFTER last_login;

-- ─── Prorate note on payslips ────────────────────────────────────────────────

ALTER TABLE hr_payslips
  ADD COLUMN prorate_days TINYINT UNSIGNED NULL AFTER working_days,
  ADD COLUMN prorate_note VARCHAR(100)     NULL AFTER prorate_days;
