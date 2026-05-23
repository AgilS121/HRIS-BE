# HRIS — Feel Backend

HRIS (Human Resource Information System) yang dibangun dengan [Feel](https://github.com/AgilS121/feel).
Arsitektur: **Modular Monolith** dengan disiplin boundary supaya bisa di-extract ke
microservices nanti tanpa rewrite.

## Modul

| Modul | Tabel prefix | Tanggung jawab |
|---|---|---|
| `auth/` | `auth_*` | Users, sessions, JWT |
| `master/` | `master_*` | Companies, departments, positions, lookup data |
| `hr/` | `hr_*` | Employees, attendance, leave |

**Aturan boundary:** Modul tidak boleh `SELECT` langsung dari tabel modul lain.
Cross-module access via `{module}/service.feel`. Lihat `shared/` untuk pattern.

## Setup

### 1. Install Feel
```bash
git clone https://github.com/AgilS121/feel ~/feel
# Pastikan python D:/feel/main.py jalan
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
feel run migrate.feel        # apply semua SQL di migrations/
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
├── main.feel                  # Entry point — imports all routes
├── config.feel                # Env + DB connection
├── migrate.feel               # Apply migrations
├── seed_admin.feel            # Create admin user
├── shared/
│   ├── response.feel          # Standard envelope (ok/error)
│   └── auth_middleware.feel   # JWT verification helpers
├── auth/
│   ├── service.feel           # find_user_by_email, find_user_by_id, make_token
│   └── routes.feel            # POST /api/auth/login, GET /api/auth/me, POST /api/auth/logout
├── master/
│   ├── service.feel           # companies/departments/positions CRUD + cross-module find_*
│   └── routes.feel            # /api/master/{companies,departments,positions}
├── hr/
│   ├── service.feel           # employees, attendance, leave + cross-module find_employee
│   └── routes.feel            # /api/hr/{employees,attendance,leave-requests}
└── migrations/
    ├── 001_auth.sql
    ├── 002_master_companies.sql
    ├── 003_master_departments.sql
    ├── 004_master_positions.sql
    ├── 005_hr_employees.sql
    ├── 006_hr_attendance.sql
    ├── 007_hr_leave.sql
    └── 999_seed.sql

Frontend: ../feel-hris-fe/  (Vite + React 18 + TypeScript + Tailwind + TanStack Query)
```

## Status

- [x] **Chunk 1** Foundation (migrations + skeleton)
- [x] **Chunk 2** Auth module — POST /api/auth/login, GET /api/auth/me, POST /api/auth/logout
- [x] **Chunk 3** Master module — companies, departments, positions CRUD
- [x] **Chunk 4** HR module — employees, attendance clock-in/out, leave requests + approve/reject
- [x] **Chunk 5** Frontend — Vite + React + TypeScript + Tailwind + TanStack Query (in feel-hris-fe/)

## Roadmap (ERP)

Setelah HRIS solid:
- `fin/` Finance — GL, AP, AR
- `inv/` Inventory — items, stocks, warehouses
- `sales/` Sales — orders, invoices, customers
- `purch/` Purchasing — PO, vendors, GRN
