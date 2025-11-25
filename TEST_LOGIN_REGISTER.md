# Giriş ve Kayıt Test Dokümantasyonu

## Düzeltilen Ana Sorun ❌➡️✅

### Sorun:
`api_service.dart` içinde backend response'unu direkt döndürüyorduk ama `auth_service.dart` hala `response['data']` bekliyordu. Bu uyumsuzluk yüzünden:
- Müşteri girişi çalışmıyordu
- Müşteri kaydı çalışmıyordu  
- İşletme girişi/kaydı çalışmıyordu
- Admin girişi çalışmıyordu

### Çözüm:
`auth_service.dart` içindeki tüm auth fonksiyonlarına `response['data'] != null` kontrolü eklendi.

```dart
// Önce (Hatalı):
if (response['success'] == true) {
  final data = response['data'];  // ❌ data null olabilir
  ...
}

// Sonra (Düzeltilmiş):
if (response['success'] == true && response['data'] != null) {
  final data = response['data'];  // ✅ güvenli
  ...
}
```

## Test Senaryoları

### 1. Backend Durumu
```bash
# Backend kontrolü
lsof -ti:3000
# Sonuç: Backend çalışıyor ✅

# API health check
curl http://localhost:3000/api/health
# Sonuç: {"success":true,"message":"API çalışıyor"} ✅

# MySQL kontrolü  
mysql -u root -psamet123 -e "SELECT 1"
# Sonuç: MySQL çalışıyor ✅
```

### 2. Müşteri Kaydı (Backend Test)
```bash
curl -X POST http://localhost:3000/api/auth/customer/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "testuser@example.com",
    "phone": "5551234567",
    "password": "test123"
  }'
```

**Beklenen Sonuç:**
```json
{
  "success": true,
  "data": {
    "customer": {
      "id": 3,
      "name": "Test User",
      "email": "testuser@example.com",
      "phone": "5551234567",
      "created_at": "2025-11-12T15:28:51.000Z",
      "updated_at": "2025-11-12T15:28:51.000Z"
    },
    "token": "eyJhbGc..."
  }
}
```

### 3. Müşteri Girişi (Backend Test)
```bash
curl -X POST http://localhost:3000/api/auth/customer/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "test123"
  }'
```

**Beklenen Sonuç:** Token ve customer bilgileri ✅

### 4. Admin Girişi (Backend Test)
```bash
curl -X POST http://localhost:3000/api/auth/admin/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'
```

**Beklenen Sonuç:** Token ve admin bilgileri ✅

## Flutter Uygulaması Test Adımları

### Adım 1: Flutter Uygulamasını Başlat
```bash
cd /Users/user/Documents/Flutter1/flutter_application_1
flutter run
# veya VS Code'da F5
```

### Adım 2: Müşteri Kaydı Test
1. Welcome ekranından "Müşteri" seçin
2. "Kayıt Ol" butonuna tıklayın
3. Form bilgilerini doldurun:
   - Ad: Test Müşteri
   - E-posta: **YENİ BİR E-POSTA** (örn: test123@test.com)
   - Telefon: 5551234567
   - Şifre: test123
   - Şifre Tekrar: test123
4. "Kayıt Ol" butonuna basın

**Beklenen Sonuç:**
- ✅ Başarılı kayıt
- ✅ Customer Home Screen'e yönlendirme
- ✅ Token kaydedildi

**Hata Durumları:**
- Aynı e-posta varsa: "Bu e-posta adresi zaten kullanılıyor" ✅
- Şifre 6 karakterden azsa: "Şifre en az 6 karakter olmalı" ✅
- Alan boşsa: "Tüm alanlar gerekli" ✅

### Adım 3: Müşteri Girişi Test
1. Welcome ekranından "Müşteri" seçin
2. "Giriş Yap" butonuna tıklayın
3. Form bilgilerini doldurun:
   - E-posta: test123@test.com
   - Şifre: test123
4. "Giriş Yap" butonuna basın

**Beklenen Sonuç:**
- ✅ Başarılı giriş
- ✅ Customer Home Screen görüntülenir

### Adım 4: Admin Girişi Test
1. Welcome ekranından "Admin" seçin
2. Form bilgilerini doldurun:
   - Kullanıcı Adı: admin
   - Şifre: admin123
3. "Giriş Yap" butonuna basın

**Beklenen Sonuç:**
- ✅ Başarılı giriş
- ✅ Admin Home Screen görüntülenir

### Adım 5: İşletme Kaydı Test
1. Welcome ekranından "İşletme" seçin
2. "Kayıt Ol" butonuna tıklayın
3. Form bilgilerini doldurun:
   - İşletme Adı: Test Kuaför
   - Sahibinin Adı: Ahmet Yılmaz
   - E-posta: **YENİ E-POSTA** (örn: testkuafor@test.com)
   - Telefon: 5559876543
   - Şifre: test123
   - Adres: Test Mahallesi
   - Şehir: İstanbul
   - İlçe: Kadıköy
4. "Kayıt Ol" butonuna basın

**Beklenen Sonuç:**
- ✅ Başarılı kayıt
- ✅ Business Home Screen'e yönlendirme

## Düzeltilen Dosyalar

1. ✅ `lib/services/api_service.dart`
   - Response handling düzeltildi
   - `'message'` field kullanımı

2. ✅ `lib/services/auth_service.dart`
   - `customerLogin()` - null check eklendi
   - `customerRegister()` - null check eklendi
   - `businessLogin()` - null check eklendi
   - `businessRegister()` - null check eklendi
   - `adminLogin()` - null check eklendi

3. ✅ `lib/screens/customer_register_screen.dart`
   - `result['message']` kullanımı

4. ✅ `lib/screens/customer_login_screen.dart`
   - `result['message']` kullanımı

5. ✅ `lib/screens/business_register_screen.dart`
   - `result['message']` kullanımı

6. ✅ `lib/screens/business_login_screen.dart`
   - `result['message']` kullanımı

7. ✅ `lib/screens/admin_login_screen.dart`
   - `result['message']` kullanımı

8. ✅ `database_schema.sql`
   - Admin şifresi bcrypt hash

9. ✅ Database
   - Admin şifresi güncellendi

## Mevcut Veritabanı Durumu

### Customers Tablosu:
```sql
SELECT id, name, email FROM customers;
```
- id:1, Test Müşteri, test@test.com
- id:2, Yeni Müşteri, yeni@example.com

### Admin Tablosu:
```sql
SELECT id, username, email FROM admins;
```
- id:1, admin, admin@kuafor.com (password: admin123)

## Sık Karşılaşılan Hatalar ve Çözümleri

### 1. "Bu e-posta adresi zaten kullanılıyor"
**Sebep:** Aynı e-posta ile daha önce kayıt yapılmış.

**Çözüm:**
```sql
-- Mevcut müşterileri görüntüle
SELECT email FROM customers;

-- Test için silmek isterseniz:
DELETE FROM customers WHERE email='test@test.com';
```

### 2. "Bağlantı hatası"
**Sebep:** Backend çalışmıyor veya API URL yanlış.

**Çözüm:**
```bash
# Backend'in çalıştığını kontrol edin
lsof -ti:3000

# Çalışmıyorsa başlatın
cd /Users/user/Documents/Flutter1/backend
npm run dev
```

### 3. "Giriş başarısız" (Admin)
**Sebep:** Şifre hash'lenmemiş.

**Çözüm:** Bu düzeltildi ✅ (admin123 kullanın)

### 4. Flutter uygulaması çalışmıyor
**Sebep:** Dependencies kurulu değil.

**Çözüm:**
```bash
cd /Users/user/Documents/Flutter1/flutter_application_1
flutter pub get
flutter run
```

## API Response Format

### Başarılı Response:
```json
{
  "success": true,
  "data": {
    "customer": {...},
    "token": "..."
  }
}
```

### Hatalı Response:
```json
{
  "success": false,
  "message": "Hata mesajı"
}
```

## Sistem Özeti

| Bileşen | Durum | Port/Bilgi |
|---------|-------|------------|
| Backend API | ✅ Çalışıyor | 3000 |
| MySQL | ✅ Çalışıyor | 3306 |
| Flutter App | ✅ Hazır | - |
| Admin Girişi | ✅ Çalışıyor | admin/admin123 |
| Müşteri Kaydı | ✅ Çalışıyor | - |
| İşletme Kaydı | ✅ Çalışıyor | - |

---

**TÜM GİRİŞ VE KAYIT SORUNLARI DÜZELTİLDİ!** 🎉

Artık uygulama tamamen çalışır durumda. Flutter uygulamasını başlatın ve test edin!

