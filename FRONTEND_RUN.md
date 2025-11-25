# Flutter Uygulamasını Çalıştırma

## Hızlı Başlangıç

### 1. Flutter Klasörüne Gidin
```bash
cd flutter_application_1
```

### 2. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 3. Uygulamayı Çalıştırın

**iOS Simulator için:**
```bash
flutter run
```

**Android Emulator için:**
```bash
flutter run
```

**Belirli bir cihaz için:**
```bash
flutter devices  # Mevcut cihazları listeler
flutter run -d <device_id>
```

**Web için:**
```bash
flutter run -d chrome
```

## Uygulama Yapısı

### Ana Ekranlar

1. **Welcome Screen (Hoş Geldin Ekranı)**
   - Mor gradient arka plan
   - 3 giriş seçeneği:
     - Müşteri Girişi (mor buton)
     - İşletme Girişi (mavi buton)
     - Admin Girişi (kırmızı buton)

2. **Müşteri Ekranları**
   - **Login**: E-posta ve şifre ile giriş
   - **Register**: Ad, e-posta, telefon, şifre ile kayıt
   - **Home**: Randevu listesi ve yeni randevu oluşturma
   - **Create Appointment**: İşletme, hizmet, çalışan, tarih, saat seçimi

3. **İşletme Ekranları**
   - **Login**: E-posta ve şifre ile giriş
   - **Register**: İşletme bilgileri ile kayıt
   - **Home**: Dashboard, istatistikler, randevu yönetimi
   - Randevu filtreleme (Tümü, Beklemede, Onaylı, Tamamlandı, İptal)
   - Randevu durumu güncelleme (Onayla, İptal, Tamamlandı)

4. **Admin Ekranları**
   - **Login**: Kullanıcı adı ve şifre ile giriş
   - **Home**: Dashboard, istatistikler, yönetim paneli

## UI Özellikleri

### Renk Şeması
- **Müşteri**: Deep Purple (Mor tonları)
- **İşletme**: Blue (Mavi tonları)
- **Admin**: Red (Kırmızı tonları)

### Tasarım Özellikleri
- ✅ Modern Material Design 3
- ✅ Gradient arka planlar
- ✅ Yuvarlatılmış köşeler
- ✅ Responsive tasarım
- ✅ Smooth animasyonlar
- ✅ Kullanıcı dostu arayüz

## Önemli Notlar

### Backend Bağlantısı
Uygulama `http://localhost:3000/api` adresindeki backend'e bağlanır.

Backend çalışmıyorsa:
- API hataları göreceksiniz
- Giriş/kayıt işlemleri çalışmayacak
- Veri çekme işlemleri başarısız olacak

### Backend'i Başlatmak İçin
```bash
cd ../backend
npm install
cp .env.example .env
# .env dosyasını düzenleyin
npm run dev
```

## Test Kullanıcıları

Backend'de test için kullanıcı oluşturmanız gerekiyor:

1. **Müşteri**: Kayıt ekranından yeni hesap oluşturun
2. **İşletme**: İşletme kayıt ekranından yeni işletme oluşturun
3. **Admin**: Veritabanında varsayılan admin var (username: admin, şifre: admin123 - production'da değiştirin)

## Sorun Giderme

### "Connection refused" Hatası
- Backend sunucusunun çalıştığından emin olun
- `api_config.dart` dosyasındaki URL'i kontrol edin

### "Package not found" Hatası
```bash
flutter clean
flutter pub get
```

### iOS Build Hatası
```bash
cd ios
pod install
cd ..
flutter run
```

### Android Build Hatası
- Android Studio'da SDK'yı güncelleyin
- Gradle sync yapın

## Hot Reload

Kod değişikliklerini anında görmek için:
- Terminal'de `r` tuşuna basın (hot reload)
- `R` tuşuna basın (hot restart)

## Build

### Android APK
```bash
flutter build apk
```

### iOS IPA
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

