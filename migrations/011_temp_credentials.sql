-- 011: temporary login credentials for new employees

ALTER TABLE auth_users
  ADD COLUMN is_temp_password BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN temp_until       TIMESTAMP NULL;

-- Index for quick lookup of expiring temp accounts
ALTER TABLE auth_users ADD INDEX idx_temp (is_temp_password, temp_until);
