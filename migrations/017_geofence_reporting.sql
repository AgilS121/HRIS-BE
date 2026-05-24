-- Phase 1: geofencing on work schedules + reporting_to on employees

-- Geofencing columns for work schedules
ALTER TABLE master_work_schedules
  ADD COLUMN office_lat      DECIMAL(10,7) NULL         AFTER grace_period_minutes,
  ADD COLUMN office_lng      DECIMAL(10,7) NULL         AFTER office_lat,
  ADD COLUMN geofence_radius INT           NOT NULL DEFAULT 0 AFTER office_lng;
-- geofence_radius in meters; 0 = disabled

-- Supervisor / reporting line for employees
ALTER TABLE hr_employees
  ADD COLUMN reporting_to BIGINT UNSIGNED NULL AFTER user_id;

ALTER TABLE hr_employees
  ADD CONSTRAINT fk_emp_reporting_to
    FOREIGN KEY (reporting_to) REFERENCES hr_employees(id) ON DELETE SET NULL;
