-- 010: add role_id to auth_users + default_role_id to master_departments

ALTER TABLE auth_users
  ADD COLUMN role_id BIGINT UNSIGNED NULL,
  ADD FOREIGN KEY fk_user_role (role_id) REFERENCES auth_roles(id) ON DELETE SET NULL;

ALTER TABLE master_departments
  ADD COLUMN default_role_id BIGINT UNSIGNED NULL,
  ADD FOREIGN KEY fk_dept_role (default_role_id) REFERENCES auth_roles(id) ON DELETE SET NULL;
