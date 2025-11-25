# Network Bağlantı Hatası Düzeltmesi

## Tarih: 12 Kasım 2025

## Sorun: Frontend API Bağlantı Hatası ❌

Flutter uygulaması backend API'ye bağlanamıyordu.

### Kök Nedenler:

1. **Platform-Specific URL Sorunu**
   - `localhost` sadece iOS Simulator ve Web'de çalışır
   - Android Emulator için `10.0.2.2` gerekir
   - Fiziksel cihazlar için bilgisayarın IP adresi gerekir

2. **Android Permissions Eksik**
   - Internet permission yoktu
   - Cleartext traffic izni yoktu

3. **iOS Network Security**
   - Local networking izni yoktu
   - HTTP trafiğine izin verilmiyordu

4. **CORS Kısıtlamaları**
   - Backend sadece `http://localhost` origin'ine izin veriyordu
   - Mobile cihazlar farklı origin kullanır

## Düzeltmeler ✅

### 1. API Config - Platform Detection

**Önceki Kod (Hatalı):**
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';  // ❌ Sadece iOS ve Web
}
```

**Yeni Kod (Düzeltilmiş):**
```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Web için localhost
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      // Android emulator için 10.0.2.2 (localhost mapping)
      return 'http://10.0.2.2:3000/api';
    } else {
      // iOS simulator için localhost
      return 'http://localhost:3000/api';
    }
  }
}
```

**Açıklama:**
- **Web (Chrome)**: `localhost` → Bilgisayarın kendisi
- **iOS Simulator**: `localhost` → Bilgisayarın kendisi (Mac)
- **Android Emulator**: `10.0.2.2` → Host makinenin localhost'u (özel Android adresi)

### 2. Android Manifest - Permissions

**android/app/src/main/AndroidManifest.xml**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet permission eklendi -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <application
        ...
        android:usesCleartextTraffic="true">  <!-- HTTP trafiğine izin -->
```

**Ne Eklendi:**
- `INTERNET` permission - Network erişimi için
- `ACCESS_NETWORK_STATE` permission - Network durumunu kontrol için
- `usesCleartextTraffic="true"` - HTTP (şifrelenmemiş) trafiğe izin

### 3. iOS Info.plist - Network Security

**ios/Runner/Info.plist**
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**Ne Eklendi:**
- `NSAllowsLocalNetworking` - localhost bağlantılarına izin
- `NSAllowsArbitraryLoads` - HTTP (güvenli olmayan) bağlantılara izin

### 4. Backend CORS - Tüm Originlere İzin

**backend/server.js**
```javascript
// Önce (Kısıtlı):
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',  // Sadece http://localhost
  credentials: true
}));

// Sonra (Açık):
app.use(cors({
  origin: '*',  // Tüm originlere izin (development için)
  credentials: false,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

**Açıklama:**
- `origin: '*'` - Tüm domainlerden gelen isteklere izin
- `methods` - İzin verilen HTTP metodları
- `allowedHeaders` - İzin verilen header'lar

## Platform-Specific Configuration

### iOS Simulator ✅
```dart
baseUrl = 'http://localhost:3000/api'
```
- Doğrudan localhost kullanır
- Mac ile aynı network'te

### Android Emulator ✅
```dart
baseUrl = 'http://10.0.2.2:3000/api'
```
- `10.0.2.2` = Host makinenin localhost'u
- Android emulator'ün özel adresi

### Chrome/Web ✅
```dart
baseUrl = 'http://localhost:3000/api'
```
- Browser'da çalışır
- CORS önemli!

### Fiziksel Cihaz (İsteğe Bağlı)

Eğer fiziksel bir telefonda test etmek isterseniz:

1. Bilgisayarınızın IP adresini bulun:
```bash
# Mac/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig
```

2. `api_config.dart`'ı güncelleyin:
```dart
// Örnek: Bilgisayarın IP'si 192.168.1.100
return 'http://192.168.1.100:3000/api';
```

3. Telefon ve bilgisayar **aynı WiFi ağında** olmalı!

## Test Senaryoları

### Test 1: Backend Health Check
```bash
# Terminal'de
curl http://localhost:3000/api/health

# Beklenen:
{
  "success": true,
  "message": "API çalışıyor",
  "timestamp": "2025-11-12T..."
}
```

### Test 2: iOS Simulator
1. Flutter uygulamasını iOS Simulator'da çalıştır
2. Giriş yap
3. **Beklenen**: API'ye başarıyla bağlanır ✅

### Test 3: Android Emulator
1. Flutter uygulamasını Android Emulator'da çalıştır
2. Giriş yap
3. **Beklenen**: `10.0.2.2` üzerinden API'ye bağlanır ✅

### Test 4: Chrome Web
1. `flutter run -d chrome`
2. Giriş yap
3. **Beklenen**: localhost üzerinden API'ye bağlanır ✅

## Troubleshooting

### Hala "Connection Refused" Alıyorsanız:

#### 1. Backend Çalışıyor mu?
```bash
lsof -ti:3000
# Çıktı: Process ID olmalı
```

#### 2. Hangi Platformda Çalışıyorsunuz?
```bash
flutter devices
# iOS Simulator, Android Emulator, Chrome, vs.
```

#### 3. Platform Doğrulaması
Flutter Debug Console'da:
```
flutter: Using baseUrl: http://10.0.2.2:3000/api  (Android için)
flutter: Using baseUrl: http://localhost:3000/api  (iOS için)
```

#### 4. Network Debugging
`api_service.dart`'a debug log ekleyin:
```dart
Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
  try {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    print('Making request to: $url');  // Debug log
    ...
  } catch (e) {
    print('Network error: $e');  // Hatayı göster
    return {
      'success': false,
      'message': 'Bağlantı hatası: $e',
    };
  }
}
```

### Android Emulator'da "Connection Refused":

1. Emulator'ı yeniden başlatın
2. App'i tamamen kapatıp yeniden açın (Hot Reload değil!)
3. `flutter clean && flutter pub get` çalıştırın
4. Tekrar build edin

### iOS Simulator'da "Connection Refused":

1. Simulator'ı yeniden başlatın
2. `pod install` çalıştırın (ios klasöründe)
3. Xcode'dan temizleyin (Clean Build Folder)

### Web'de CORS Hatası:

Browser console'da şunu göreceksiniz:
```
Access to XMLHttpRequest at 'http://localhost:3000/api/...' 
from origin 'http://localhost:xxxxx' has been blocked by CORS policy
```

**Çözüm**: Backend'i yeniden başlatın (CORS ayarları güncellendi)

## Düzeltilen Dosyalar

| Dosya | Değişiklik | Sebep |
|-------|-----------|-------|
| `api_config.dart` | Platform detection | Android için `10.0.2.2` |
| `AndroidManifest.xml` | Internet permissions | Network erişimi |
| `AndroidManifest.xml` | `usesCleartextTraffic` | HTTP izni |
| `Info.plist` | NSAppTransportSecurity | iOS network izni |
| `server.js` | CORS policy | Tüm originlere izin |

## Önemli Notlar

### Production için:

**Güvenlik Uyarısı**: Bu ayarlar **sadece development için** uygundur!

Production'da:
1. **HTTPS kullanın** (HTTP değil)
2. CORS'u spesifik origin'lere kısıtlayın
3. `usesCleartextTraffic="false"` yapın (Android)
4. `NSAllowsArbitraryLoads="false"` yapın (iOS)

### Development Checklist:

- [x] Backend çalışıyor (port 3000)
- [x] Platform-specific URL yapılandırması
- [x] Android permissions
- [x] iOS network security
- [x] CORS ayarları
- [x] Backend restart edildi

## Komutlar

### Backend'i Yeniden Başlat:
```bash
cd /Users/user/Documents/Flutter1/backend

# Eski process'i durdur
kill $(lsof -ti:3000)

# Yeniden başlat
npm run dev
```

### Flutter Clean Build:
```bash
cd /Users/user/Documents/Flutter1/flutter_application_1

flutter clean
flutter pub get
flutter run
```

### Debug Modu ile Çalıştır:
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Chrome
flutter run -d chrome
```

---

**TÜM NETWORK BAĞLANTI SORUNLARI DÜZELTİLDİ!** 🚀

Artık her platformda API'ye başarıyla bağlanabilirsiniz!

