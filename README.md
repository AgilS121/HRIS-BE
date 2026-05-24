# HRIS — Feel Backend

HRIS (Human Resource Information System) yang dibangun dengan [Feel](https://github.com/AgilS121/feel).
Arsitektur: **Modular Monolith** dengan disiplin boundary supaya bisa di-extract ke microservices nanti tanpa rewrite.

## Modul

| Modul | Tabel prefix | Tanggung jawab |
|---|---|---|
| `auth/` | `auth_*` | Users, sessions, JWT, device binding, temp credentials |
| `master/` | `master_*` | Companies, departments, positions, work schedules, late rules, shifts, rosters |
| `hr/` | `hr_*` | Employees, attendance, leave, payroll, overtime, audit log |

**Aturan boundary:** Modul tidak boleh `SELECT` langsung dari tabel modul lain.
Cross-module access via `{module}/service.feel`. Lihat `shared/` untuk pattern.

## Fitur

### Auth
- Login + JWT, logout, refresh me
- Temporary credentials (auto-expire 3 hari) + extend
- Role-based access (RBAC) per menu + permission level
- Device binding — simpan `device_id` saat login
- Change password, reset password by admin

### Master Data
- Companies, Departments (dengan parent hierarki), Positions
- Work Schedules — jam kerja, grace period, geofence radius + koordinat kantor
- Late Rules — tiers deduction otomatis berdasarkan menit keterlambatan
- **Shifts** — template shift (nama, jam mulai/selesai)
- **Rosters** — penugasan shift per karyawan per hari (upsert, unique per emp+date)

### HR — Karyawan
- CRUD karyawan dengan employee_no auto-generate per departemen
- Extended profile: gender, NIK, BPJS, status perkawinan, bank, pendidikan
- Reporting To (supervisor) — dropdown ke karyawan lain
- Upload contract file (multipart), simpan metadata kontrak
- Terminate karyawan (soft delete)
- Contract expiry alert (badge di frontend)

### HR — Absensi
- Clock-in / clock-out dengan selfie (opsional) + GPS
- Geofencing — validasi jarak dari koordinat kantor
- Auto-detect keterlambatan vs work schedule
- Deduction amount otomatis dari late rules
- Auto-close rekaman hari sebelumnya yang belum clock-out

### HR — Cuti
- Tipe cuti per perusahaan (annual, sick, permit, dll)
- Saldo cuti per karyawan per tahun + inisialisasi batch
- Pengajuan cuti dengan attachment
- Approve / reject / cancel dengan catatan
- Adjustment manual saldo

### HR — Payroll
- Komponen gaji: earning & deduction, berbagai basis kalkulasi (fixed, % basic, % gross, per absent day)
- Override komponen per karyawan
- **Seed BPJS & PPh21** — INSERT IGNORE komponen standar (BPJS_KES_EE 1%, BPJS_JHT_EE 2%, BPJS_JP_EE 1%, PPH21 5%)
- Payroll run — generate payslip bulanan, lock, mark paid
- **Prorate payroll** — karyawan join tengah bulan dapat gaji proporsional (hari kalender / total hari bulan)
- **Batch import** komponen via `POST /api/hr/payroll/batch-components` (Excel import dari FE)

### HR — Overtime
- Submit overtime request (employee_id, date, start/end time, duration hours, reason)
- Approve / reject dengan catatan
- Cancel pending request
- List per perusahaan (HR) atau per karyawan sendiri

### HR — Audit Log
- Rekam semua perubahan sensitif: create/update/terminate employee, lock/paid payroll run
- Simpan user_id, timestamp, IP, entity yang berubah
- `GET /api/hr/audit-logs?company_id=X&limit=N`

## Setup

### 1. Install Feel
```bash
git clone https://github.com/AgilS121/feel ~/feel
# Pastikan python D:/feel/main.py bisa dijalankan
```

### 2. Buat database
```sql
CREATE DATABASE hris_feel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 3. Config `.env`
```ini
database_url=mysql://root:@localhost:3306/hris_feel
jwt_secret=ganti-dengan-random-32-char-min
port=3000
cors=true
```

### 4. Run migration + seed
```bash
feel run migrate.feel        # apply semua SQL di migrations/ (001–019)
feel run seed_admin.feel     # bikin admin@hris.local / admin123
```

### 5. Start server
```bash
feel run main.feel
# atau production:
feel build main.feel -o hris-server && ./hris-server
```

## Struktur folder

```
feel-hris-be/
├── main.feel                      # Entry point — imports semua route modules
├── config.feel                    # Env + DB connection
├── migrate.feel                   # Apply migrations
├── seed_admin.feel                # Create admin user
├── shared/
│   ├── response.feel              # Standard envelope (ok/error/not_found)
│   └── auth_middleware.feel       # JWT verification helpers
├── auth/
│   ├── service.feel               # User CRUD, token, device binding, temp creds
│   ├── routes.feel                # /api/auth/{login,me,logout,change-password,...}
│   └── temp_service.feel          # Temporary credential management
├── master/
│   ├── service.feel               # Companies, departments, positions, schedules,
│   │                              # late rules, shifts, rosters
│   ├── routes.feel                # /api/master/{companies,departments,positions,
│   │                              # work-schedules,late-rules,shifts,rosters}
│   └── roles_routes.feel          # /api/master/roles
├── hr/
│   ├── service.feel               # Employees, attendance, leave, audit log
│   ├── routes.feel                # /api/hr/{employees,attendance,leave-*,audit-logs}
│   ├── payroll_service.feel       # Payroll components, runs, payslips, prorate, BPJS seed
│   ├── payroll_routes.feel        # /api/hr/{payroll-*,payslips,payroll/seed-bpjs,
│   │                              # payroll/batch-components}
│   ├── overtime_service.feel      # Overtime request CRUD + approve/reject
│   └── overtime_routes.feel       # /api/hr/overtime
└── migrations/
    ├── 001_auth.sql
    ├── 002_master_companies.sql
    ├── 003_master_departments.sql
    ├── 004_master_positions.sql
    ├── 005_hr_employees.sql
    ├── 006_hr_attendance.sql
    ├── 007_hr_leave.sql
    ├── 008_hr_employee_extra.sql
    ├── 009_rbac_roles.sql
    ├── 010_rbac_fk.sql
    ├── 011_temp_credentials.sql
    ├── 012_leave_enhancements.sql
    ├── 013_payroll.sql
    ├── 014_payroll_menu_key.sql
    ├── 015_attendance_selfie.sql
    ├── 016_work_schedule.sql
    ├── 017_geofence_reporting.sql
    ├── 018_audit_device.sql       # audit_log, device_id, prorate_days
    ├── 019_overtime_shift.sql     # overtime_requests, shifts, rosters
    └── 999_seed.sql
```

## Status

- [x] **Phase 1** Foundation, auth, master, HR employees/attendance/leave, frontend skeleton
- [x] **Phase 2** Audit log, device binding, BPJS seed, prorate payroll, AuditLog page
- [x] **Phase 3** Overtime requests, shifts & rostering, offline attendance, Excel import

## Roadmap (ERP)

Setelah HRIS solid:
- `fin/` Finance — GL, AP, AR
- `inv/` Inventory — items, stocks, warehouses
- `sales/` Sales — orders, invoices, customers
- `purch/` Purchasing — PO, vendors, GRN
