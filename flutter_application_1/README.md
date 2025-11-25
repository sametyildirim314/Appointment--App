# Kuaför Randevu Sistemi

Modern bir Flutter uygulaması ile geliştirilmiş kuaför randevu yönetim sistemi.

## Özellikler

### Müşteri Özellikleri
- ✅ Müşteri kayıt ve giriş sistemi
- ✅ İşletme listesi görüntüleme
- ✅ Randevu oluşturma (işletme, hizmet, çalışan, tarih, saat seçimi)
- ✅ Randevu listesi görüntüleme
- ✅ Randevu durumu takibi

### İşletme Özellikleri
- ✅ İşletme kayıt ve giriş sistemi
- ✅ Randevu yönetimi (onaylama, iptal etme, tamamlandı işaretleme)
- ✅ Randevu filtreleme (tümü, beklemede, onaylı, tamamlandı, iptal)
- ✅ İstatistik görüntüleme
- ✅ Randevu detayları görüntüleme

### Admin Özellikleri
- ✅ Admin giriş sistemi
- ✅ Dashboard görünümü
- ✅ İşletme, müşteri ve randevu yönetimi (backend entegrasyonu sonrası aktif)

## Teknolojiler

- **Flutter** - UI Framework
- **MySQL** - Veritabanı
- **HTTP** - API İletişimi
- **Shared Preferences** - Yerel veri saklama
- **Provider** - State Management

## Proje Yapısı

```
lib/
├── config/
│   └── api_config.dart          # API yapılandırması
├── models/
│   ├── customer.dart            # Müşteri modeli
│   ├── business.dart            # İşletme modeli
│   ├── employee.dart            # Çalışan modeli
│   ├── service.dart              # Hizmet modeli
│   ├── appointment.dart          # Randevu modeli
│   └── admin.dart                # Admin modeli
├── services/
│   ├── api_service.dart          # API servis katmanı
│   ├── auth_service.dart         # Kimlik doğrulama servisi
│   └── appointment_service.dart  # Randevu servisi
├── screens/
│   ├── welcome_screen.dart        # Ana giriş ekranı
│   ├── customer_login_screen.dart # Müşteri giriş
│   ├── customer_register_screen.dart # Müşteri kayıt
│   ├── customer_home_screen.dart # Müşteri ana sayfa
│   ├── business_login_screen.dart # İşletme giriş
│   ├── business_register_screen.dart # İşletme kayıt
│   ├── business_home_screen.dart # İşletme ana sayfa
│   ├── admin_login_screen.dart   # Admin giriş
│   ├── admin_home_screen.dart     # Admin ana sayfa
│   └── create_appointment_screen.dart # Randevu oluşturma
└── main.dart                      # Ana uygulama dosyası
```

## Kurulum

1. Flutter SDK'yı yükleyin: https://flutter.dev/docs/get-started/install

2. Projeyi klonlayın veya indirin

3. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

4. Backend API URL'ini yapılandırın:
   - `lib/config/api_config.dart` dosyasını açın
   - `baseUrl` değişkenini backend API URL'iniz ile güncelleyin

5. Veritabanını oluşturun:
   - `database_schema.sql` dosyasını MySQL veritabanınızda çalıştırın

6. Uygulamayı çalıştırın:
```bash
flutter run
```

## Veritabanı Şeması

Veritabanı şeması `database_schema.sql` dosyasında tanımlanmıştır. Şema şu tabloları içerir:

- **customers** - Müşteri bilgileri
- **businesses** - İşletme bilgileri
- **employees** - Çalışan bilgileri
- **services** - Hizmet bilgileri
- **appointments** - Randevu bilgileri
- **employee_schedules** - Çalışan çalışma saatleri
- **business_holidays** - İşletme tatil günleri
- **admins** - Admin kullanıcıları

## Backend API Gereksinimleri

Backend API'niz şu endpoint'leri sağlamalıdır:

### Authentication
- `POST /auth/customer/login` - Müşteri girişi
- `POST /auth/customer/register` - Müşteri kaydı
- `POST /auth/business/login` - İşletme girişi
- `POST /auth/business/register` - İşletme kaydı
- `POST /auth/admin/login` - Admin girişi

### Appointments
- `GET /appointments/customer/:id` - Müşteri randevuları
- `GET /appointments/business/:id` - İşletme randevuları
- `POST /appointments/create` - Randevu oluştur
- `PUT /appointments/update/:id` - Randevu güncelle
- `PUT /appointments/cancel/:id` - Randevu iptal

### Data
- `GET /businesses` - İşletme listesi
- `GET /services?business_id=:id` - İşletme hizmetleri
- `GET /employees?business_id=:id` - İşletme çalışanları

## API Response Formatı

Tüm API yanıtları şu formatta olmalıdır:

```json
{
  "success": true,
  "data": {
    // Response data
  }
}
```

Hata durumunda:
```json
{
  "success": false,
  "message": "Hata mesajı"
}
```

## Güvenlik

- Şifreler backend'de hash'lenmelidir (bcrypt önerilir)
- JWT token kullanımı önerilir
- API endpoint'leri authentication gerektirmelidir
- HTTPS kullanılmalıdır

## Geliştirme Notları

- Backend API URL'i `lib/config/api_config.dart` dosyasında yapılandırılmalıdır
- Şu anda ödeme sistemi entegre edilmemiştir
- Uygulama modern Material Design 3 kullanmaktadır
- State management için Provider kullanılmıştır

## Lisans

Bu proje özel bir projedir.

## İletişim

Sorularınız için lütfen iletişime geçin.
