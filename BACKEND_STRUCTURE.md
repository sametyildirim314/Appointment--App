# 🏗️ Backend Yapısı - Detaylı Dokümantasyon

## 📁 Klasör Yapısı

```
backend/
├── config/
│   └── database.js          # MySQL bağlantı havuzu yapılandırması
├── controllers/
│   ├── authController.js    # Kimlik doğrulama işlemleri
│   ├── appointmentController.js  # Randevu CRUD işlemleri
│   ├── businessController.js     # İşletme yönetim işlemleri
│   └── dataController.js         # Genel veri çekme işlemleri
├── middleware/
│   └── auth.js              # JWT token doğrulama middleware
├── routes/
│   ├── authRoutes.js        # Kimlik doğrulama route'ları
│   ├── appointmentRoutes.js # Randevu route'ları
│   ├── businessRoutes.js    # İşletme route'ları
│   └── dataRoutes.js        # Genel veri route'ları
├── server.js                # Express sunucu giriş noktası
├── seed_data.js             # Test verileri seed scripti
├── openapi.yaml             # API dokümantasyonu (OpenAPI 3.0.3)
├── package.json             # NPM bağımlılıkları
└── .env                     # Ortam değişkenleri (gizli)
```

---

## 🏛️ Mimari Yapı

### 3-Katmanlı Mimari (3-Layer Architecture)

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│                  (Express.js Routes)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ authRoutes   │  │appointment   │  │ business     │ │
│  │              │  │Routes        │  │ Routes       │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
└─────────┼─────────────────┼──────────────────┼─────────┘
          │                 │                  │
          ▼                 ▼                  ▼
┌─────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                  │
│                    (Controllers)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │authController│  │appointment   │  │ business     │ │
│  │              │  │Controller    │  │ Controller   │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
└─────────┼─────────────────┼──────────────────┼─────────┘
          │                 │                  │
          ▼                 ▼                  ▼
┌─────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER                     │
│              (MySQL Database Connection Pool)           │
│  ┌────────────────────────────────────────────────────┐ │
│  │         config/database.js (Connection Pool)       │ │
│  │  • Connection Limit: 10                            │ │
│  │  • Keep-Alive: Enabled                            │ │
│  │  • Charset: utf8mb4                               │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────┐
│                    MySQL DATABASE                       │
│  • admins                                               │
│  • businesses                                           │
│  • customers                                            │
│  • employees                                            │
│  • services                                             │
│  • appointments                                         │
│  • employee_schedules                                   │
└─────────────────────────────────────────────────────────┘
```

---

## 🔐 Güvenlik Katmanı

### JWT Authentication Flow

```
┌─────────────┐
│   Client    │
│  (Flutter)  │
└──────┬──────┘
       │ 1. POST /api/auth/customer/login
       │    { email, password }
       ▼
┌─────────────────────────────────────┐
│  authController.customerLogin()    │
│  • Email kontrolü                   │
│  • bcrypt.compare()                 │
│  • generateToken()                  │
└──────┬──────────────────────────────┘
       │ 2. JWT Token döner
       │    { token: "eyJhbGc..." }
       ▼
┌─────────────┐
│   Client    │
│  (Flutter)  │
└──────┬──────┘
       │ 3. GET /api/appointments/customer/:id
       │    Header: Authorization: Bearer {token}
       ▼
┌─────────────────────────────────────┐
│  middleware/auth.authenticateToken()│
│  • jwt.verify()                     │
│  • req.user = decoded               │
└──────┬──────────────────────────────┘
       │ 4. Token geçerliyse devam
       ▼
┌─────────────────────────────────────┐
│  appointmentController.getCustomer  │
│  Appointments()                     │
│  • Veritabanı sorgusu               │
│  • Sonuç döner                      │
└─────────────────────────────────────┘
```

---

## 📡 API Endpoint Yapısı

### Base URL: `http://localhost:3000/api`

### 1. Authentication Routes (`/api/auth`)

| Method | Endpoint | Controller | Açıklama |
|--------|----------|------------|----------|
| POST | `/customer/login` | `authController.customerLogin` | Müşteri girişi |
| POST | `/customer/register` | `authController.customerRegister` | Müşteri kaydı |
| POST | `/business/login` | `authController.businessLogin` | İşletme girişi |
| POST | `/business/register` | `authController.businessRegister` | İşletme kaydı |
| POST | `/admin/login` | `authController.adminLogin` | Admin girişi |

### 2. Appointment Routes (`/api/appointments`)

**🔒 Tüm endpoint'ler authentication gerektirir**

| Method | Endpoint | Controller | Açıklama |
|--------|----------|------------|----------|
| POST | `/create` | `appointmentController.createAppointment` | Yeni randevu oluştur |
| PUT | `/update/:id` | `appointmentController.updateAppointment` | Randevu güncelle |
| GET | `/customer/:id` | `appointmentController.getCustomerAppointments` | Müşteri randevuları |
| GET | `/business/:id` | `appointmentController.getBusinessAppointments` | İşletme randevuları |

### 3. Business Routes (`/api/business`)

| Method | Endpoint | Controller | Açıklama |
|--------|----------|------------|----------|
| GET | `/employees/:businessId` | `businessController.getEmployees` | İşletme çalışanları |
| POST | `/employees` | `businessController.createEmployee` | Çalışan ekle |
| PUT | `/employees/:id` | `businessController.updateEmployee` | Çalışan güncelle |
| DELETE | `/employees/:id` | `businessController.deleteEmployee` | Çalışan sil |
| GET | `/services/:businessId` | `businessController.getServices` | İşletme hizmetleri |
| POST | `/services` | `businessController.createService` | Hizmet ekle |
| PUT | `/services/:id` | `businessController.updateService` | Hizmet güncelle |
| DELETE | `/services/:id` | `businessController.deleteService` | Hizmet sil |

### 4. Data Routes (`/api`)

| Method | Endpoint | Controller | Açıklama |
|--------|----------|------------|----------|
| GET | `/businesses` | `dataController.getAllBusinesses` | Tüm işletmeler |
| GET | `/businesses/:id` | `dataController.getBusinessById` | İşletme detayı |
| GET | `/businesses/:id/employees` | `dataController.getBusinessEmployees` | İşletme çalışanları |
| GET | `/businesses/:id/services` | `dataController.getBusinessServices` | İşletme hizmetleri |
| GET | `/businesses/:id/schedule` | `dataController.getEmployeeSchedule` | Çalışan programı |

### 5. Health Check

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | `/api/health` | API durum kontrolü |

---

## 💻 Kod Örnekleri

### 1. Server.js - Express Sunucu Yapılandırması

```javascript
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// CORS Middleware
app.use(cors({
  origin: '*',
  credentials: false,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body Parser Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/appointments', require('./routes/appointmentRoutes'));
app.use('/api/business', require('./routes/businessRoutes'));
app.use('/api', require('./routes/dataRoutes'));

// Error Handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    message: 'Sunucu hatası'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server ${PORT} portunda çalışıyor`);
});
```

### 2. Database.js - MySQL Connection Pool

```javascript
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'kuafor_randevu',
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,        // Maksimum 10 bağlantı
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  charset: 'utf8mb4'
});

module.exports = pool;
```

### 3. Auth Middleware - JWT Token Doğrulama

```javascript
const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token bulunamadı'
    });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({
        success: false,
        message: 'Geçersiz token'
      });
    }
    req.user = user;  // Token'dan çıkarılan kullanıcı bilgisi
    next();
  });
};

const generateToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: '30d'  // 30 gün geçerli
  });
};
```

### 4. Controller Örneği - Randevu Oluşturma

```javascript
const createAppointment = async (req, res) => {
  try {
    const { customer_id, business_id, employee_id, service_id, 
            appointment_date, appointment_time, notes } = req.body;

    // Validasyon
    if (!customer_id || !business_id || !service_id || 
        !appointment_date || !appointment_time) {
      return res.status(400).json({
        success: false,
        message: 'Zorunlu alanlar eksik'
      });
    }

    // Çakışma kontrolü
    const [existing] = await pool.execute(
      `SELECT id FROM appointments 
       WHERE business_id = ? AND employee_id = ? 
       AND appointment_date = ? AND appointment_time = ? 
       AND status != 'cancelled'`,
      [business_id, employee_id || null, appointment_date, appointment_time]
    );

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Bu saatte zaten bir randevu var'
      });
    }

    // Randevu oluştur
    const [result] = await pool.execute(
      `INSERT INTO appointments 
       (customer_id, business_id, employee_id, service_id, 
        appointment_date, appointment_time, notes, status) 
       VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')`,
      [customer_id, business_id, employee_id || null, 
       service_id, appointment_date, appointment_time, notes || null]
    );

    // Oluşturulan randevuyu JOIN ile çek
    const [newAppointment] = await pool.execute(
      `SELECT a.*, 
              c.name as customer_name,
              b.business_name,
              e.name as employee_name,
              s.service_name, s.price, s.duration
       FROM appointments a
       LEFT JOIN customers c ON a.customer_id = c.id
       LEFT JOIN businesses b ON a.business_id = b.id
       LEFT JOIN employees e ON a.employee_id = e.id
       LEFT JOIN services s ON a.service_id = s.id
       WHERE a.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      data: newAppointment[0]
    });
  } catch (error) {
    console.error('Create appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};
```

---

## 🔧 Teknolojiler ve Paketler

### Core Dependencies

| Paket | Versiyon | Amaç |
|-------|----------|------|
| `express` | ^4.18.2 | Web framework |
| `mysql2` | ^3.6.5 | MySQL veritabanı driver |
| `jsonwebtoken` | ^9.0.2 | JWT token oluşturma/doğrulama |
| `bcryptjs` | ^2.4.3 | Şifre hashleme |
| `cors` | ^2.8.5 | Cross-Origin Resource Sharing |
| `dotenv` | ^16.3.1 | Ortam değişkenleri yönetimi |

### Development Dependencies

| Paket | Versiyon | Amaç |
|-------|----------|------|
| `nodemon` | ^3.0.2 | Otomatik sunucu yeniden başlatma |
| `@scalar/cli` | ^1.4.0 | OpenAPI dokümantasyon görüntüleme |

---

## 🔒 Güvenlik Özellikleri

### 1. Şifre Güvenliği
- **bcryptjs** ile şifre hashleme (10 salt rounds)
- Düz metin şifreler veritabanında saklanmaz
- Şifre karşılaştırması `bcrypt.compare()` ile yapılır

### 2. SQL Injection Koruması
- **Prepared Statements** kullanımı (`?` placeholder)
- Tüm kullanıcı girdileri parametreli sorgularla işlenir

### 3. JWT Token Güvenliği
- Token'lar 30 gün geçerlidir
- Secret key `.env` dosyasında saklanır
- Her istekte token doğrulaması yapılır

### 4. CORS Yapılandırması
- Development için tüm originlere izin verilir
- Production'da spesifik origin'ler belirtilmelidir

---

## 📊 Veritabanı İlişkileri

```
┌─────────────┐
│   admins    │
└─────────────┘

┌─────────────┐         ┌─────────────┐
│ businesses  │────────▶│  employees  │
└─────────────┘   1:N    └──────┬──────┘
      │                         │
      │ 1:N                     │ 1:N
      │                         │
      ▼                         ▼
┌─────────────┐         ┌─────────────┐
│  services   │         │appointments │
└─────────────┘         └──────┬──────┘
                               │
                               │ N:1
                               │
                      ┌────────┴────────┐
                      │                 │
                ┌─────▼─────┐    ┌─────▼─────┐
                │ customers │    │ employees │
                └───────────┘    └───────────┘
```

---

## 🚀 Çalıştırma Komutları

```bash
# Bağımlılıkları yükle
npm install

# Development modunda çalıştır (nodemon ile)
npm run dev

# Production modunda çalıştır
npm start

# Seed data yükle (test verileri)
node seed_data.js

# API dokümantasyonunu görüntüle
npx scalar document serve openapi.yaml --port 5050
```

---

## 📝 Response Formatı

### Başarılı Response
```json
{
  "success": true,
  "data": {
    // Response data
  }
}
```

### Hata Response
```json
{
  "success": false,
  "message": "Hata mesajı"
}
```

---

## 🔍 Önemli Notlar

1. **Connection Pool**: MySQL bağlantıları havuzda yönetilir, performans için optimize edilmiştir
2. **Error Handling**: Tüm controller'larda try-catch blokları kullanılır
3. **Validation**: Her endpoint'te gerekli alan kontrolü yapılır
4. **Prepared Statements**: SQL injection'a karşı korumalı sorgular
5. **JWT Expiry**: Token'lar 30 gün geçerlidir, yenileme mekanizması eklenebilir
6. **CORS**: Production'da spesifik origin'ler belirtilmelidir

---

**Son Güncelleme**: 2024
**Versiyon**: 1.0.0
