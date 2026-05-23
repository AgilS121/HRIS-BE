-- Leave system enhancements: policy fields, balance adjustments, cancellation, attachment

ALTER TABLE hr_leave_types
  ADD COLUMN requires_attachment BOOLEAN NOT NULL DEFAULT FALSE   AFTER is_paid,
  ADD COLUMN min_days_advance    INT     NOT NULL DEFAULT 0       AFTER requires_attachment,
  ADD COLUMN carry_over_max      INT     NOT NULL DEFAULT 0       AFTER min_days_advance,
  ADD COLUMN is_encashable       BOOLEAN NOT NULL DEFAULT FALSE   AFTER carry_over_max;

ALTER TABLE hr_leave_balances
  ADD COLUMN adjusted_days     INT NOT NULL DEFAULT 0 AFTER used_days,
  ADD COLUMN carried_over_days INT NOT NULL DEFAULT 0 AFTER adjusted_days;

ALTER TABLE hr_leave_requests
  ADD COLUMN attachment_path VARCHAR(500) NULL AFTER reason,
  ADD COLUMN cancel_reason   TEXT         NULL AFTER rejection_note,
  ADD COLUMN cancelled_at    TIMESTAMP    NULL AFTER cancel_reason,
  ADD COLUMN cancelled_by    BIGINT UNSIGNED NULL AFTER cancelled_at;

CREATE TABLE hr_leave_adjustments (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  employee_id   BIGINT UNSIGNED NOT NULL,
  leave_type_id BIGINT UNSIGNED NOT NULL,
  year          INT UNSIGNED NOT NULL,
  days          INT NOT NULL,
  reason        TEXT NOT NULL,
  adjusted_by   BIGINT UNSIGNED NULL,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_employee (employee_id),
  FOREIGN KEY (employee_id)   REFERENCES hr_employees(id)   ON DELETE CASCADE,
  FOREIGN KEY (leave_type_id) REFERENCES hr_leave_types(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
