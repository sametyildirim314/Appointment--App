# Backend Kurulum Rehberi

## Hızlı Başlangıç

### 1. Backend Klasörüne Gidin

```bash
cd backend
```

### 2. Bağımlılıkları Yükleyin

```bash
npm install
```

### 3. Ortam Değişkenlerini Ayarlayın

`.env.example` dosyasını `.env` olarak kopyalayın:

```bash
cp .env.example .env
```

`.env` dosyasını düzenleyin ve MySQL bilgilerinizi girin:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=sizin_sifreniz
DB_NAME=kuafor_randevu
DB_PORT=3306

JWT_SECRET=super_secret_key_buraya_rastgele_bir_anahtar_yazin
PORT=3000
CORS_ORIGIN=http://localhost
```

### 4. MySQL Veritabanını Oluşturun

MySQL'e bağlanın ve şu komutları çalıştırın:

```sql
CREATE DATABASE kuafor_randevu;
USE kuafor_randevu;
```

Sonra `flutter_application_1/database_schema.sql` dosyasını MySQL'de çalıştırın.

### 5. Backend Sunucusunu Başlatın

**Development modu (otomatik yeniden başlatma):**
```bash
npm run dev
```

**Production modu:**
```bash
npm start
```

Sunucu başarıyla başladığında şu mesajı göreceksiniz:
```
🚀 Server 3000 portunda çalışıyor
📡 API: http://localhost:3000/api
💚 Health Check: http://localhost:3000/api/health
```

### 6. Flutter Uygulamasını Yapılandırın

`flutter_application_1/lib/config/api_config.dart` dosyasında URL zaten ayarlanmış:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

Eğer farklı bir port kullanıyorsanız veya uzak sunucu kullanıyorsanız, bu URL'i güncelleyin.

## Test Etme

### API Health Check

Tarayıcıda veya Postman'de şu URL'i açın:
```
http://localhost:3000/api/health
```

Şu yanıtı görmelisiniz:
```json
{
  "success": true,
  "message": "API çalışıyor",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

### İşletmeleri Listeleme

```
GET http://localhost:3000/api/businesses
```

## Sorun Giderme

### "Cannot find module" Hatası
```bash
npm install
```

### MySQL Bağlantı Hatası
- MySQL servisinin çalıştığından emin olun
- `.env` dosyasındaki veritabanı bilgilerini kontrol edin
- Veritabanının oluşturulduğunu kontrol edin

### Port 3000 Zaten Kullanılıyor
`.env` dosyasında farklı bir port kullanın:
```env
PORT=3001
```

Ve Flutter uygulamasındaki `api_config.dart` dosyasını da güncelleyin.

### CORS Hatası
Flutter uygulamanız farklı bir adresten çalışıyorsa, `.env` dosyasında `CORS_ORIGIN` değerini güncelleyin.

## Production Deployment

Production için:

1. `.env` dosyasında production değerlerini ayarlayın
2. `JWT_SECRET` için güçlü bir rastgele anahtar kullanın
3. `CORS_ORIGIN` değerini production domain'iniz ile güncelleyin
4. HTTPS kullanın
5. Process manager kullanın (PM2 önerilir):

```bash
npm install -g pm2
pm2 start server.js --name kuafor-api
```

## API Dokümantasyonu

Detaylı API dokümantasyonu için `backend/README.md` dosyasına bakın.

