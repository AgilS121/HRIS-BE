-- 014: tambah 'payroll' ke ENUM menu_key di auth_role_menus

ALTER TABLE auth_role_menus
  MODIFY COLUMN menu_key
    ENUM('employees','departments','positions','attendance','leave','roles','users','payroll')
    NOT NULL;
