-- Add selfie photo columns to hr_attendance for mobile attendance app.

ALTER TABLE hr_attendance
  ADD COLUMN selfie_in_path  VARCHAR(255) NULL AFTER clock_in_lng,
  ADD COLUMN selfie_out_path VARCHAR(255) NULL AFTER clock_out_lng;
