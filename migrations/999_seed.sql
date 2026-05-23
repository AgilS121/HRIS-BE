-- Seed master + lookup data untuk demo.
-- Admin user di-seed terpisah via seed_admin.feel (butuh crypto.hash_password).

INSERT INTO master_companies (id, code, name, legal_name, is_active) VALUES
  (1, 'HRIS-DEMO', 'Demo Company', 'PT Demo Indonesia', TRUE);

INSERT INTO master_departments (id, company_id, code, name) VALUES
  (1, 1, 'BOD',  'Board of Directors'),
  (2, 1, 'HR',   'Human Resources'),
  (3, 1, 'IT',   'Information Technology'),
  (4, 1, 'FIN',  'Finance');

INSERT INTO master_positions (id, company_id, code, name, level) VALUES
  (1, 1, 'CEO',     'Chief Executive Officer', 10),
  (2, 1, 'MGR',     'Manager',                 5),
  (3, 1, 'SPV',     'Supervisor',              3),
  (4, 1, 'STAFF',   'Staff',                   1);

INSERT INTO hr_leave_types (id, company_id, code, name, default_quota_days, is_paid) VALUES
  (1, 1, 'annual',    'Cuti Tahunan',     12, TRUE),
  (2, 1, 'sick',      'Sakit',            -1, TRUE),
  (3, 1, 'maternity', 'Cuti Melahirkan',  90, TRUE),
  (4, 1, 'permit',    'Izin',             3,  FALSE);
