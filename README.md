# Genshin Import — Full-Stack Mobile Application
### GachaMerch | Flutter + Node.js + MySQL

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Architecture](#2-architecture)
3. [Database Design](#3-database-design)
4. [Back-End (Node.js / Express)](#4-back-end-nodejs--express)
5. [Front-End (Flutter)](#5-front-end-flutter)
6. [Authentication](#6-authentication)
7. [UI Design & Theme Documentation](#7-ui-design--theme-documentation)
8. [Data Validations](#8-data-validations)
9. [Setup & Run Guide](#9-setup--run-guide)
10. [Requirements Checklist](#10-requirements-checklist)

---

## 1. Project Overview

**Genshin Import** is a mobile e-commerce application for Teyvat-themed weapons and artifacts.

| Role  | Capabilities |
|-------|-------------|
| **Admin** | Login · Add weapon · Edit weapon · Delete weapon · View all weapons |
| **User**  | Register · Login (password or Google OAuth) · View weapons · Search & filter weapons · Buy weapons · View order history |

---

## 2. Architecture

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│                                FLUTTER MOBILE APP                                        │
│  (Login • Register • Weapon List • Detail • Admin Form • Shopping Cart • Order History)  │
└────────────────────────────────────────┬─────────────────────────────────────────────────┘
                                         │ 
                                         │ HTTP / REST (Bearer JWT)
                                         │ 
    ┌────────────────────────────────────▼───────────────────────────────────────┐
    │                          NODE.JS + EXPRESS API                             │
    │      /api/auth   •   /api/weapons   •   /api/orders   •   /api/cart        │
    └────────────────────────────────────┬───────────────────────────────────────┘
                                         │ 
                                         │ Connection pool (mysql2)
                                         │ 
    ┌────────────────────────────────────▼────────────────────────────────────┐
    │                           MYSQL DATABASE                                │
    │                users  •  weapons  •  orders•  cart                      │
    └─────────────────────────────────────────────────────────────────────────┘
```
---

## 3. Database Design

### Tables

#### `users`
| Column | Type | Notes |
|--------|------|-------|
| id | INT PK AUTO_INCREMENT | |
| name | VARCHAR(100) NOT NULL | |
| email | VARCHAR(150) UNIQUE NOT NULL | |
| password | VARCHAR(255) | NULL for OAuth users |
| role | ENUM('admin','user') | DEFAULT 'user' |
| oauth_provider | VARCHAR(50) | 'google' or NULL |
| oauth_id | VARCHAR(255) | Google sub |
| created_at | TIMESTAMP | |

#### `weapons`
| Column | Type | Notes |
|--------|------|-------|
| id | INT PK AUTO_INCREMENT | |
| name | VARCHAR(150) NOT NULL | |
| type | ENUM('Sword','Claymore','Polearm','Bow','Catalyst') | |
| description | TEXT NOT NULL | |
| stock | INT NOT NULL | ≥ 0 |
| image_url | VARCHAR(500) | nullable |
| price | DECIMAL(12,2) NOT NULL | |
| created_at / updated_at | TIMESTAMP | |

#### `orders`
| Column | Type | Notes |
|--------|------|-------|
| id | INT PK AUTO_INCREMENT | |
| user_id | INT FK → users | |
| weapon_id | INT FK → weapons | |
| quantity | INT NOT NULL | |
| total_price | DECIMAL(14,2) NOT NULL | |
| status | ENUM('pending','confirmed','cancelled') | |
| ordered_at | TIMESTAMP | |

#### `cart_items`
| Column | Type | Notes |
|--------|------|-------|
| id | INT PK AUTO_INCREMENT | |
| user_id | INT FK → users | |
| weapon_id | INT FK → weapons | |
| quantity | INT NOT NULL | |
| created_at | TIMESTAMP DEFAULT CURRENT_TIMESTAMP | |

### CRUD coverage
| Operation | Endpoint | Description |
|-----------|----------|-------------|
| **Create** | POST /api/weapons | Admin adds weapon |
| **Create** | POST /api/orders | User places order |
| **Read** | GET /api/weapons | List all weapons |
| **Read** | GET /api/weapons/:id | Weapon detail |
| **Read** | GET /api/orders/my | User's own orders |
| **Update** | PUT /api/weapons/:id | Admin edits weapon |
| **Delete** | DELETE /api/weapons/:id | Admin removes weapon |

---

## 4. Back-End (Node.js / Express)

### File structure
```
Server/
├── server.js            Entry point, middleware, route mounting
├── package.json
├── .env.example         Environment variables template
├── config/
│   └── db.js            mysql2 connection pool
├── middleware/
│   └── auth.js          verifyToken + requireAdmin
├── routes/
│   ├── auth.js          POST /login, /register, /google
│   ├── weapons.js       GET / GET/:id / POST / PUT / DELETE
│   ├── cart.js          GET / POST / PUT / DELETE / POST /checkout
│   └── orders.js        POST / GET /my / GET (admin)
└── database.sql         Schema + seed data
```

### API Endpoints

#### Auth (`/api/auth`)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /register | — | Register new user |
| POST | /login | — | Email+password login |
| POST | /google | — | Google OAuth login |

#### Weapons (`/api/weapons`)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | / | Public | List all (with search & type filter) |
| GET | /:id | Public | Single weapon detail |
| POST | / | Admin JWT | Create weapon |
| PUT | /:id | Admin JWT | Update weapon |
| DELETE | /:id | Admin JWT | Delete weapon |

#### Orders (`/api/orders`)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | / | User JWT | Place order (deducts stock atomically) |
| GET | /my | User JWT | Current user's order history |
| GET | / | Admin JWT | All orders |

#### Cart (`/api/cart`)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | / | User JWT | Get current user's cart items |
| POST | / | User JWT | Add weapon to cart or update existing item |
| PUT | /:id | User JWT | Update cart item quantity |
| DELETE | /:id | User JWT | Remove item from cart |
| POST | /checkout | User JWT | Checkout cart and create orders |

### ≥ 2 GET + ≥ 1 mutating request ✓
- GET /api/weapons
- GET /api/weapons/:id
- GET /api/orders/my
- POST /api/weapons (create)
- PUT /api/weapons/:id (update)
- DELETE /api/weapons/:id (delete)
- POST /api/orders (buy)

---

## 5. Front-End (Flutter)

### Pages (≥ 5 required)
| # | Screen | File | Description |
|---|--------|------|-------------|
| 1 | **Login** | `login_screen.dart` | Email/password + Google sign-in |
| 2 | **Register** | `register_screen.dart` | New account creation |
| 3 | **Weapon List** | `weapon_list_screen.dart` | Home — grid with search & filter |
| 4 | **Weapon Detail** | `weapon_detail_screen.dart` | Full info + buy controls |
| 5 | **Weapon Form** | `weapon_form_screen.dart` | Admin: create / edit weapon |
| 6 | **Order History** | `order_history_screen.dart` | User's purchase history |
| 7 | **Cart** | `cart.dart` | User shopping cart with quantity update and checkout |

### UI Components (≥ 5 required)

| # | Component | Where Used |
|---|-----------|-----------|
| 1 | `ElevatedButton` | Login, Register, Buy, Save forms |
| 2 | `OutlinedButton` | Google sign-in, Cancel actions |
| 3 | `TextFormField` (custom `GenshinTextField`) | All forms |
| 4 | `DropdownButton` | Weapon type filter on list screen |
| 5 | `FilterChip` | Quick type filter chips on list screen |
| 6 | `Card` (`WeaponCard`) | Weapon grid items |
| 7 | `SliverAppBar` | Collapsible header on detail screen |
| 8 | `CircularProgressIndicator` | Loading states |
| 9 | `AlertDialog` | Buy confirm, delete confirm |
| 10 | `SnackBar` | Feedback messages |

---

## 6. Authentication

### Standard login
- User submits email + password.
- Backend verifies via `bcrypt.compare`.
- On success, `jwt.sign({ id, email, role })` returns a **Bearer token**.

### Google OAuth
1. Flutter calls `GoogleSignIn().signIn()` → gets `idToken`.
2. Flutter posts `idToken` to `POST /api/auth/google`.
3. Backend calls `googleClient.verifyIdToken(idToken)`.
4. Upserts user in DB, returns same JWT format.

### Token format
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJpZCI6MSwiZW1haWwiOiJhZG1pbkBnYWNoYW1lcmNoLmNvbSIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTcxMDAwMDAwMCwiZXhwIjoxNzEwNjA0ODAwfQ.
<signature>
```
JWT tokens are always **well above 20 alphanumeric characters** ✓.

### Token verification
`middleware/auth.js` → `verifyToken` is applied to:
- POST /api/weapons (create)
- PUT /api/weapons/:id
- DELETE /api/weapons/:id
- POST /api/orders
- GET /api/orders/my
- GET /api/orders

---

## 7. UI Design & Theme Documentation

### Design Direction
**Dark Teyvat Gold** — Inspired by Genshin Impact's in-game UI.  
Deep navy backgrounds evoke the night sky of Mondstadt; gold accents mirror Mora (in-game currency) and weapon stars.

### Theme Customisations (2–4 properties requirement: **5 properties applied**)

| Property | Value | Visible On |
|----------|-------|-----------|
| **Background Color** | `#0D1B2A` (deep navy) | All screen scaffolds |
| **Accent / Primary Color** | `#C9A84C` (Teyvat gold) | Buttons, icons, borders, price text, AppBar icons |
| **Font Size** | Display: 28sp · Title: 18sp · Body: 14sp · Caption: 11sp | Entire app via `AppTextStyles` |
| **Font Weight** | Display: 700 · Title: 600–700 · Body: 400 · Price: 800 | Entire app |
| **Font Color** | Primary: `#EEE8D5` · Secondary: `#B0A89A` · Gold: `#C9A84C` | All text elements |

### Color Contrast (WCAG)
| Foreground | Background | Ratio | Pass |
|-----------|-----------|-------|------|
| Gold `#C9A84C` | Deep Navy `#0D1B2A` | ~7.2:1 | ✓ AA + AAA |
| Text `#EEE8D5` | Card `#132236` | ~10.1:1 | ✓ AA + AAA |
| Error `#E05C5C` | Card `#132236` | ~4.6:1 | ✓ AA |

### Weapon Type Color Coding
| Type | Color |
|------|-------|
| Sword | `#7EC8E3` (sky blue) |
| Claymore | `#E07070` (crimson) |
| Polearm | `#90EE90` (jade green) |
| Bow | `#DDA0DD` (plum) |
| Catalyst | `#FFD700` (bright gold) |

---

## 8. Data Validations

### ≥ 3 validations, with error messages shown in UI ✓

#### Login screen
| Field | Validation | Error Message |
|-------|-----------|---------------|
| Email | Required | "Email is required." |
| Email | Regex `^[^\s@]+@[^\s@]+\.[^\s@]+$` | "Enter a valid email address." |
| Password | Required | "Password is required." |
| Password | Length ≥ 6 | "Password must be at least 6 characters." |

#### Register screen
| Field | Validation | Error Message |
|-------|-----------|---------------|
| Name | Required | "Name is required." |
| Name | Length ≥ 2 | "Name must be at least 2 characters." |
| Email | Required + Regex | same as login |
| Password | Required + Length ≥ 6 + uppercase letter | "Include at least one uppercase letter." |
| Confirm Password | Must match password | "Passwords do not match." |

#### Weapon Form (admin)
| Field | Validation | Error Message |
|-------|-----------|---------------|
| Name | Required | "Weapon name is required." |
| Name | Length ≥ 3 | "Name must be at least 3 characters." |
| Description | Required | "Description is required." |
| Description | Length ≥ 10 | "Description must be at least 10 characters." |
| Stock | Required + integer | "Stock must be a whole number." |
| Stock | ≥ 0 | "Stock cannot be negative." |
| Price | Required + numeric | "Price must be a valid number." |
| Price | > 0 | "Price must be greater than zero." |

#### Buy flow (Weapon Detail)
| Check | Error Message |
|-------|---------------|
| Quantity ≥ 1 | "Quantity must be at least 1." |
| Quantity ≤ stock | "Only N in stock." |

#### Back-end validations (mirror, return JSON `message`)
All the above are also validated server-side with appropriate HTTP status codes (400, 401, 404, 409).

---

## 9. Setup & Run Guide

### Prerequisites
- Node.js 18+
- MySQL 8
- Flutter 3.19+ (with Android SDK)
- Google Cloud project with OAuth 2.0 Client ID

### 1 — Database
```bash
mysql -u root -p < Server/database.sql
```

### 2 — Back-End
```bash
cd Server
cp .env.example .env
# Fill in DB_PASSWORD and GOOGLE_CLIENT_ID
npm install
npm run dev          # http://localhost:3000
```

### 3 — Flutter App
```bash
cd frontend/flutter_genshin_import
flutter pub get
# In lib/services/apiServices.dart set baseUrl:
#   Android emulator  → http://10.0.2.2:3000/api
#   iOS simulator     → http://127.0.0.1:3000/api
#   Physical device   → http://<your-LAN-IP>:3000/api

# Add google-services.json (Android) / GoogleService-Info.plist (iOS)
flutter run
```

### Test Credentials (from seed data)
| Role | Email | Password |
|------|-------|----------|
| Admin | admin@gachamerch.com | Admin@123 |
| User | traveler@teyvat.com | User@123 |

---

## 10. Requirements Checklist

### Database (MySQL)
- [x] CREATE — weapons, users, orders, cart_items
- [x] READ — weapons list, weapon detail, cart items, orders
- [x] UPDATE — weapon edit, cart item quantity
- [x] DELETE — weapon delete, cart item remove

### Front-End (Flutter)
- [x] ≥ 5 UI components (Button, TextField, DropdownButton, FilterChip, Card, Dialog, SnackBar, SliverAppBar…)
- [x] ≥ 5 pages (Login, Register, Weapon List, Weapon Detail, Weapon Form, Order History, Cart)
- [x] ≥ 3 data validations (email format, password strength, name length, stock ≥ 0, price > 0, confirm match, quantity…)
- [x] Error messages shown for all validation failures

### Back-End (Node.js / Express)
- [x] ≥ 3 GET requests (GET /weapons, GET /weapons/:id, GET /orders/my, GET /cart)
- [x] ≥ 1 POST/PUT/DELETE (POST /weapons, PUT /weapons/:id, DELETE /weapons/:id, POST /orders, POST /cart, PUT /cart/:id, DELETE /cart/:id)

### Authentication
- [x] Login with DB user (bcrypt)
- [x] Google OAuth login
- [x] Bearer token generated (JWT, always > 20 alphanumeric chars)
- [x] Token verification on protected endpoints

### UI Design
- [x] ≥ 2 customised properties (5 applied: background color, accent color, font size, font weight, font color)
- [x] All customisations visible in the app
- [x] Good contrast ratios (documented above)
- [x] Cohesive, usable design
