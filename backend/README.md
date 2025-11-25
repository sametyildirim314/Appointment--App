# Kuaför Randevu Sistemi - Backend API

Node.js/Express ve MySQL kullanılarak geliştirilmiş RESTful API.

## Kurulum

### 1. Bağımlılıkları Yükleyin

```bash
npm install
```

### 2. Ortam Değişkenlerini Yapılandırın

`.env.example` dosyasını `.env` olarak kopyalayın ve veritabanı bilgilerinizi girin:

```bash
cp .env.example .env
```

`.env` dosyasını düzenleyin:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=kuafor_randevu
DB_PORT=3306

JWT_SECRET=your_super_secret_jwt_key_change_this
PORT=3000
CORS_ORIGIN=http://localhost
```

### 3. Veritabanını Oluşturun

MySQL'de veritabanını oluşturun ve `database_schema.sql` dosyasını çalıştırın:

```sql
CREATE DATABASE kuafor_randevu;
USE kuafor_randevu;
-- database_schema.sql dosyasını burada çalıştırın
```

### 4. Sunucuyu Başlatın

**Development (nodemon ile):**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

Sunucu varsayılan olarak `http://localhost:3000` adresinde çalışacaktır.

## API Endpoints

### Authentication

- `POST /api/auth/customer/login` - Müşteri girişi
- `POST /api/auth/customer/register` - Müşteri kaydı
- `POST /api/auth/business/login` - İşletme girişi
- `POST /api/auth/business/register` - İşletme kaydı
- `POST /api/auth/admin/login` - Admin girişi

### Data (Public)

- `GET /api/businesses` - Tüm işletmeler
- `GET /api/services?business_id=:id` - İşletme hizmetleri
- `GET /api/employees?business_id=:id` - İşletme çalışanları

### Appointments (Protected - Token gerekli)

- `POST /api/appointments/create` - Randevu oluştur
- `PUT /api/appointments/update/:id` - Randevu güncelle
- `GET /api/appointments/customer/:id` - Müşteri randevuları
- `GET /api/appointments/business/:id` - İşletme randevuları

### Health Check

- `GET /api/health` - API durumu

## Request/Response Formatları

### Login Request
```json
{
  "email": "customer@example.com",
  "password": "password123"
}
```

### Login Response
```json
{
  "success": true,
  "data": {
    "customer": {
      "id": 1,
      "name": "Ahmet Yılmaz",
      "email": "customer@example.com",
      "phone": "5551234567"
    },
    "token": "jwt_token_here"
  }
}
```

### Create Appointment Request
```json
{
  "customer_id": 1,
  "business_id": 1,
  "employee_id": 1,
  "service_id": 1,
  "appointment_date": "2024-01-15",
  "appointment_time": "14:00",
  "notes": "Notlar buraya"
}
```

**Header:**
```
Authorization: Bearer jwt_token_here
```

## Güvenlik

- Şifreler bcrypt ile hash'lenir
- JWT token kullanılır (30 gün geçerli)
- CORS yapılandırılabilir
- SQL injection koruması (prepared statements)

## Hata Yönetimi

Tüm hatalar şu formatta döner:

```json
{
  "success": false,
  "message": "Hata mesajı"
}
```

## Geliştirme

### Yeni Endpoint Ekleme

1. Controller oluştur: `controllers/yourController.js`
2. Route oluştur: `routes/yourRoutes.js`
3. `server.js`'e route'u ekle

### Veritabanı Sorguları

Tüm sorgular prepared statements kullanır:

```javascript
const [rows] = await pool.execute(
  'SELECT * FROM table WHERE id = ?',
  [id]
);
```

## Sorun Giderme

### MySQL Bağlantı Hatası
- `.env` dosyasındaki veritabanı bilgilerini kontrol edin
- MySQL servisinin çalıştığından emin olun
- Veritabanının oluşturulduğunu kontrol edin

### Port Zaten Kullanılıyor
- `.env` dosyasında farklı bir PORT değeri kullanın
- Veya kullanan process'i durdurun

### CORS Hatası
- `.env` dosyasında `CORS_ORIGIN` değerini Flutter uygulamanızın adresi ile güncelleyin

