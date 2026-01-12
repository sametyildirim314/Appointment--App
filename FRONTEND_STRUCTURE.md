# 🎨 Frontend Yapısı - Detaylı Dokümantasyon

## 📁 Klasör Yapısı

```
flutter_application_1/
├── lib/
│   ├── main.dart                    # Uygulama giriş noktası
│   ├── config/
│   │   └── api_config.dart          # API endpoint yapılandırması
│   ├── models/
│   │   ├── admin.dart               # Admin model sınıfı
│   │   ├── appointment.dart          # Randevu model sınıfı
│   │   ├── business.dart            # İşletme model sınıfı
│   │   ├── customer.dart             # Müşteri model sınıfı
│   │   ├── employee.dart             # Çalışan model sınıfı
│   │   └── service.dart              # Hizmet model sınıfı
│   ├── screens/
│   │   ├── welcome_screen.dart       # Hoş geldiniz ekranı
│   │   ├── customer_login_screen.dart
│   │   ├── customer_register_screen.dart
│   │   ├── customer_home_screen.dart
│   │   ├── business_login_screen.dart
│   │   ├── business_register_screen.dart
│   │   ├── business_home_screen.dart
│   │   ├── admin_login_screen.dart
│   │   ├── admin_home_screen.dart
│   │   └── create_appointment_screen.dart
│   ├── services/
│   │   ├── api_service.dart          # HTTP istekleri servisi
│   │   ├── auth_service.dart         # Kimlik doğrulama servisi
│   │   ├── appointment_service.dart  # Randevu işlemleri servisi
│   │   ├── business_service.dart     # İşletme işlemleri servisi
│   │   └── admin_service.dart        # Admin işlemleri servisi
│   ├── widgets/
│   │   └── responsive_wrapper.dart  # Responsive widget'lar
│   └── utils/                        # Yardımcı fonksiyonlar
├── pubspec.yaml                      # Flutter bağımlılıkları
└── README.md
```

---

## 🏛️ Mimari Yapı

### MVVM (Model-View-ViewModel) Benzeri Yapı

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│                      (Screens/Views)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Welcome    │  │   Customer   │  │   Business   │ │
│  │   Screen    │  │   Screens    │  │   Screens    │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
└─────────┼─────────────────┼──────────────────┼─────────┘
          │                 │                  │
          ▼                 ▼                  ▼
┌─────────────────────────────────────────────────────────┐
│                    SERVICE LAYER                        │
│              (Business Logic & API Calls)               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ AuthService  │  │Appointment  │  │  Business    │ │
│  │              │  │  Service    │  │  Service     │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
└─────────┼─────────────────┼──────────────────┼─────────┘
          │                 │                  │
          ▼                 ▼                  ▼
┌─────────────────────────────────────────────────────────┐
│                    DATA LAYER                           │
│  ┌────────────────────────────────────────────────────┐ │
│  │         ApiService (HTTP Client)                  │ │
│  │  • Singleton pattern                             │ │
│  │  • Token management                              │ │
│  │  • Error handling                                │ │
│  │  • Request/Response interceptors                  │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────┐
│                    MODEL LAYER                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Customer   │  │ Appointment  │  │  Business   │ │
│  │   Model      │  │    Model     │  │   Model     │ │
│  │              │  │              │  │             │ │
│  │ fromJson()   │  │ fromJson()   │  │ fromJson()  │ │
│  │ toJson()     │  │ toJson()     │  │ toJson()    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────┐
│              LOCAL STORAGE LAYER                         │
│  ┌────────────────────────────────────────────────────┐ │
│  │      SharedPreferences (Token & User Data)        │ │
│  │  • JWT token storage                             │ │
│  │  • User data persistence                         │ │
│  │  • Session management                             │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Uygulama Akış Diyagramı

### Authentication Flow

```
┌─────────────┐
│   App Start │
│  (main.dart)│
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│      AuthWrapper                    │
│  • SharedPreferences kontrolü      │
│  • Token doğrulama                  │
│  • User type kontrolü               │
└──────┬──────────────────────────────┘
       │
       ├─ Token VAR ──────────┐
       │                      │
       │                      ▼
       │              ┌─────────────────┐
       │              │  User Type?      │
       │              └──────┬───────────┘
       │                     │
       │        ┌────────────┼────────────┐
       │        │            │            │
       │        ▼            ▼            ▼
       │  ┌──────────┐ ┌──────────┐ ┌──────────┐
       │  │ Customer │ │ Business │ │  Admin   │
       │  │  Home    │ │  Home    │ │  Home    │
       │  └──────────┘ └──────────┘ └──────────┘
       │
       └─ Token YOK ──────────┐
                              │
                              ▼
                    ┌─────────────────┐
                    │ Welcome Screen  │
                    │  (Login/Register)│
                    └─────────────────┘
```

### API Request Flow

```
┌─────────────┐
│   Screen    │
│  (Widget)   │
└──────┬──────┘
       │
       │ 1. User Action (Button Click, etc.)
       ▼
┌─────────────────────────────────────┐
│      Service Layer                   │
│  (authService, appointmentService)  │
│  • Business logic                    │
│  • Data transformation               │
└──────┬───────────────────────────────┘
       │
       │ 2. Service Method Call
       ▼
┌─────────────────────────────────────┐
│      ApiService                      │
│  • Token ekleme                      │
│  • Header hazırlama                  │
│  • HTTP request                      │
└──────┬───────────────────────────────┘
       │
       │ 3. HTTP Request
       ▼
┌─────────────────────────────────────┐
│      Backend API                     │
│  (Node.js/Express)                   │
└──────┬───────────────────────────────┘
       │
       │ 4. Response
       ▼
┌─────────────────────────────────────┐
│      ApiService                      │
│  • Response parsing                  │
│  • Error handling                    │
└──────┬───────────────────────────────┘
       │
       │ 5. Processed Data
       ▼
┌─────────────────────────────────────┐
│      Service Layer                   │
│  • Model conversion                  │
│  • Business logic                    │
└──────┬───────────────────────────────┘
       │
       │ 6. Model Object
       ▼
┌─────────────────────────────────────┐
│      Screen                          │
│  • setState()                        │
│  • UI update                         │
└─────────────────────────────────────┘
```

---

## 📱 Ekran Yapısı ve Navigasyon

### Ekran Hiyerarşisi

```
WelcomeScreen (Ana Giriş)
│
├── CustomerLoginScreen
│   └── CustomerRegisterScreen
│       └── CustomerHomeScreen
│           ├── CreateAppointmentScreen
│           └── (Randevu Detayları)
│
├── BusinessLoginScreen
│   └── BusinessRegisterScreen
│       └── BusinessHomeScreen
│           ├── (Çalışan Yönetimi)
│           ├── (Hizmet Yönetimi)
│           └── (Randevu Yönetimi)
│
└── AdminLoginScreen
    └── AdminHomeScreen
        ├── (Tüm İşletmeler)
        ├── (Tüm Müşteriler)
        └── (Tüm Randevular)
```

### Ekran Detayları

| Ekran | Amaç | Özellikler |
|-------|------|------------|
| `WelcomeScreen` | Ana giriş ekranı | • Müşteri/İşletme seçimi<br>• Modern glassmorphism tasarım<br>• Responsive layout |
| `CustomerLoginScreen` | Müşteri girişi | • Email/Password formu<br>• Kayıt sayfasına yönlendirme<br>• Premium UI tasarımı |
| `CustomerRegisterScreen` | Müşteri kaydı | • Form validasyonu<br>• API entegrasyonu<br>• Otomatik login |
| `CustomerHomeScreen` | Müşteri dashboard | • Randevu listesi<br>• Yeni randevu oluşturma<br>• Randevu durumu takibi<br>• "Süre Doldu" gösterimi |
| `BusinessLoginScreen` | İşletme girişi | • Email/Password formu<br>• Kayıt sayfasına yönlendirme |
| `BusinessRegisterScreen` | İşletme kaydı | • Detaylı form (şehir, ilçe, adres)<br>• İşletme bilgileri |
| `BusinessHomeScreen` | İşletme dashboard | • Çalışan yönetimi<br>• Hizmet yönetimi<br>• Randevu yönetimi<br>• Çalışan saat durumu (dolu/boş) |
| `AdminLoginScreen` | Admin girişi | • Username/Password formu |
| `AdminHomeScreen` | Admin dashboard | • Sistem istatistikleri<br>• Tüm randevular<br>• İşletme/müşteri listesi |
| `CreateAppointmentScreen` | Randevu oluşturma | • İşletme seçimi<br>• Çalışan seçimi<br>• Tarih/saat seçimi<br>• Dolu saatlerin kırmızı gösterimi |

---

## 🎨 UI/UX Tasarım Prensipleri

### Design System

#### Renk Paleti

```dart
// Primary Colors
Color(0xFF6366F1)  // Indigo (Primary)
Color(0xFF8B5CF6)  // Purple
Color(0xFF10B981)  // Green (Success)
Color(0xFFF59E0B)   // Amber (Warning)
Color(0xFFEF4444)   // Red (Error/Danger)
Color(0xFF6B7280)   // Gray (Neutral)

// Background Gradients
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1E293B),  // Dark slate
    Color(0xFF0F172A),  // Darker slate
  ],
)

// Glassmorphism
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
  ),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: child,
  ),
)
```

#### Typography

- **Headings**: Bold, 24-32px
- **Body**: Regular, 14-16px
- **Captions**: Regular, 12px
- **Font Family**: System default (Roboto on Android, SF Pro on iOS)

#### Spacing

- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **XLarge**: 32px
- **XXLarge**: 48px

#### Border Radius

- **Small**: 8px
- **Medium**: 12px
- **Large**: 20px
- **XLarge**: 24px

### Responsive Design

```dart
// ResponsiveWrapper kullanımı
ResponsiveWrapper(
  maxWidth: 1200,
  padding: EdgeInsets.all(24),
  child: Content(),
)

// MediaQuery ile breakpoint kontrolü
final bool isMobile = MediaQuery.of(context).size.width < 900;
final bool isTablet = MediaQuery.of(context).size.width >= 900 && 
                     MediaQuery.of(context).size.width < 1200;
final bool isDesktop = MediaQuery.of(context).size.width >= 1200;
```

---

## 🔧 Servis Katmanı Detayları

### 1. ApiService (Singleton Pattern)

```dart
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  String? _userType;

  // Token yönetimi
  void setToken(String? token, String? userType) {
    _token = token;
    _userType = userType;
  }

  // Header hazırlama
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // HTTP metodları
  Future<Map<String, dynamic>> get(String endpoint) async { ... }
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async { ... }
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async { ... }
  Future<Map<String, dynamic>> delete(String endpoint) async { ... }
}
```

**Özellikler:**
- Singleton pattern (tek instance)
- Otomatik token ekleme
- Timeout yönetimi (30 saniye)
- Hata yakalama ve işleme
- JSON encoding/decoding

### 2. AuthService

```dart
class AuthService {
  // Login metodları
  Future<Map<String, dynamic>> customerLogin(String email, String password)
  Future<Map<String, dynamic>> businessLogin(String email, String password)
  Future<Map<String, dynamic>> adminLogin(String username, String password)

  // Register metodları
  Future<Map<String, dynamic>> customerRegister(...)
  Future<Map<String, dynamic>> businessRegister(...)

  // Session yönetimi
  Future<void> _saveAuthData(...)
  Future<Map<String, dynamic>?> loadAuthData()
  Future<void> logout()
  Future<bool> isLoggedIn()
}
```

**Özellikler:**
- SharedPreferences ile local storage
- Token expiry kontrolü (5 dakika)
- Otomatik session uzatma
- User type yönetimi

### 3. AppointmentService

```dart
class AppointmentService {
  // Randevu işlemleri
  Future<List<Appointment>> getCustomerAppointments(int customerId)
  Future<List<Appointment>> getBusinessAppointments(int businessId)
  Future<Map<String, dynamic>> createAppointment(...)
  Future<Map<String, dynamic>> updateAppointment(int id, ...)
  Future<Map<String, dynamic>> cancelAppointment(int id)
}
```

### 4. BusinessService

```dart
class BusinessService {
  // İşletme verileri
  Future<List<Business>> getAllBusinesses()
  Future<Business?> getBusinessById(int id)
  Future<List<Employee>> getBusinessEmployees(int businessId)
  Future<List<Service>> getBusinessServices(int businessId)
  Future<List<Map<String, dynamic>>> getEmployeeSchedule(int employeeId, DateTime date)
}
```

---

## 📦 Model Sınıfları

### Appointment Model

```dart
class Appointment {
  final int? id;
  final int customerId;
  final int businessId;
  final int? employeeId;
  final int serviceId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final String? notes;
  
  // İlişkili veriler
  final String? customerName;
  final String? businessName;
  final String? employeeName;
  final String? serviceName;
  final double? servicePrice;
  final int? serviceDuration;

  // JSON serialization
  factory Appointment.fromJson(Map<String, dynamic> json)
  Map<String, dynamic> toJson()
}

enum AppointmentStatus {
  pending,      // Beklemede
  confirmed,    // Onaylandı
  completed,    // Tamamlandı
  cancelled;    // İptal Edildi
}
```

**Özellikler:**
- Type-safe enum kullanımı
- JSON serialization/deserialization
- İlişkili veri desteği (JOIN sonuçları)
- Null safety

### Diğer Modeller

- **Customer**: Müşteri bilgileri
- **Business**: İşletme bilgileri
- **Employee**: Çalışan bilgileri
- **Service**: Hizmet bilgileri
- **Admin**: Admin bilgileri

Tüm modeller:
- `fromJson()` factory constructor
- `toJson()` method
- Null safety desteği

---

## 🎯 Önemli Özellikler

### 1. Süre Dolmuş Randevu Gösterimi

```dart
// customer_home_screen.dart ve business_home_screen.dart içinde
final now = DateTime.now();
final appointmentDateOnly = DateTime(
  appointment.appointmentDate.year,
  appointment.appointmentDate.month,
  appointment.appointmentDate.day,
);
final todayDateOnly = DateTime(now.year, now.month, now.day);

final isExpired = appointment.status == AppointmentStatus.pending &&
    appointmentDateOnly.isBefore(todayDateOnly);

if (isExpired) {
  statusColor = Colors.grey;
  statusText = 'Süre Doldu';
  statusIcon = Icons.schedule;
}
```

**Mantık:**
- Sadece `pending` durumundaki randevular kontrol edilir
- Tarih karşılaştırması sadece tarih kısmıyla yapılır (saat göz ardı edilir)
- Bugünden önceki tarihler "Süre Doldu" olarak işaretlenir

### 2. Çalışan Dolu/Boş Saat Gösterimi

```dart
// create_appointment_screen.dart içinde
final busyTimes = _employeeSchedule
    .where((schedule) {
      final scheduleDate = DateTime.parse(schedule['appointment_date']);
      final selectedDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final status = schedule['status']?.toString().toLowerCase() ?? '';
      return scheduleDate.isAtSameMomentAs(selectedDate) &&
          (status == 'confirmed' || status == 'completed');
    })
    .map((schedule) {
      final time = schedule['appointment_time']?.toString() ?? '';
      if (time.length >= 5) {
        return time.substring(0, 5); // "10:00:00" -> "10:00"
      }
      return time;
    })
    .toSet();

// UI'da gösterim
Container(
  decoration: BoxDecoration(
    color: isBusy
        ? const Color(0xFFEF4444).withOpacity(0.15) // Kırmızı (DOLU)
        : isSelected
            ? const Color(0xFF6366F1) // Mor (Seçili)
            : Colors.white.withOpacity(0.05), // Açık (BOŞ)
    border: Border.all(
      color: isBusy
          ? const Color(0xFFEF4444).withOpacity(0.4)
          : Colors.white.withOpacity(0.1),
    ),
  ),
  child: Column(
    children: [
      Text(time),
      if (isBusy)
        Text('DOLU', style: TextStyle(color: Colors.red)),
    ],
  ),
)
```

**Mantık:**
- Sadece `confirmed` ve `completed` durumundaki randevular "dolu" sayılır
- Seçilen tarih ve çalışana göre filtreleme yapılır
- Saat formatı "HH:MM" olarak normalize edilir
- Kırmızı = Dolu, Yeşil/Beyaz = Boş

### 3. Responsive Design

```dart
// ResponsiveWrapper widget'ı
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
```

**Kullanım:**
- Desktop'ta içerik maksimum genişlikle ortalanır
- Mobilde tam genişlik kullanılır
- Breakpoint: 900px (mobil/desktop ayrımı)

### 4. Glassmorphism Tasarım

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
  ),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: child,
  ),
)
```

**Özellikler:**
- Yarı saydam arka plan
- Blur efekti
- İnce border
- Modern, premium görünüm

---

## 📚 Flutter Paketleri

### Core Dependencies

| Paket | Versiyon | Amaç |
|-------|----------|------|
| `flutter` | SDK | Flutter framework |
| `http` | ^1.1.0 | HTTP istekleri |
| `shared_preferences` | ^2.2.2 | Local storage (token, user data) |
| `intl` | ^0.20.2 | Tarih/saat formatlama |
| `provider` | ^6.1.1 | State management |
| `flutter_form_builder` | ^10.2.0 | Form yönetimi |
| `form_builder_validators` | ^11.2.0 | Form validasyonu |
| `cupertino_icons` | ^1.0.8 | iOS ikonları |

### Development Dependencies

| Paket | Versiyon | Amaç |
|-------|----------|------|
| `flutter_test` | SDK | Unit testler |
| `flutter_lints` | ^6.0.0 | Lint kuralları |

---

## 🔒 Güvenlik Özellikleri

### 1. Token Yönetimi

- JWT token'lar `SharedPreferences`'ta saklanır
- Her API isteğinde `Authorization: Bearer {token}` header'ı eklenir
- Token expiry kontrolü (5 dakika)
- Otomatik logout (token geçersizse)

### 2. Input Validation

```dart
// Form validasyonu örneği
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan zorunludur';
    }
    if (!value.contains('@')) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  },
)
```

### 3. Error Handling

```dart
try {
  final response = await _apiService.post(endpoint, data);
  if (response['success'] == true) {
    // Başarılı işlem
  } else {
    // Hata mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'])),
    );
  }
} catch (e) {
  // Genel hata yakalama
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Bir hata oluştu: $e')),
  );
}
```

### 4. Secure Storage

- Şifreler hiçbir zaman local'de saklanmaz
- Sadece token ve user data saklanır
- Logout'ta tüm veriler temizlenir

---

## 🚀 Çalıştırma Komutları

```bash
# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır (Chrome)
flutter run -d chrome

# Uygulamayı çalıştır (iOS Simulator)
flutter run -d ios

# Uygulamayı çalıştır (Android Emulator)
flutter run -d android

# Build (Web)
flutter build web

# Build (iOS)
flutter build ios

# Build (Android)
flutter build apk
```

---

## 📊 Proje İstatistikleri

- **Toplam Ekran Sayısı**: 10
- **Model Sınıfı**: 6
- **Servis Sınıfı**: 5
- **Widget Sayısı**: 1 (ResponsiveWrapper)
- **API Endpoint Entegrasyonu**: 20+

---

## 🎨 UI Bileşenleri

### Premium Design Elements

1. **Gradient Backgrounds**
   - Dark slate gradients
   - Modern, profesyonel görünüm

2. **Glassmorphism Cards**
   - Yarı saydam paneller
   - Blur efektleri
   - İnce border'lar

3. **Modern CTA Buttons**
   - Gradient arka planlar
   - Hover efektleri
   - Smooth animasyonlar

4. **Status Badges**
   - Renk kodlu durumlar
   - İkon desteği
   - Responsive boyutlandırma

5. **Responsive Grids**
   - Mobil: 1 sütun
   - Tablet: 2 sütun
   - Desktop: 3-4 sütun

---

## 🔍 Önemli Notlar

1. **State Management**: Şu anda `setState()` kullanılıyor. Büyük projeler için `Provider` veya `Bloc` önerilir.

2. **Error Handling**: Tüm API çağrıları try-catch ile korunmalı.

3. **Loading States**: Async işlemlerde loading indicator gösterilmeli.

4. **Offline Support**: Şu anda yok. `flutter_offline` paketi eklenebilir.

5. **Image Caching**: Eğer resimler kullanılırsa `cached_network_image` paketi önerilir.

6. **Localization**: Şu anda sadece Türkçe. `flutter_localizations` eklenebilir.

---

## 📝 Kod Örnekleri

### 1. API Service Kullanımı

```dart
final apiService = ApiService();
apiService.setToken(token, 'customer');

final response = await apiService.get('/appointments/customer/1');
if (response['success'] == true) {
  final appointments = (response['data'] as List)
      .map((json) => Appointment.fromJson(json))
      .toList();
}
```

### 2. Auth Service Kullanımı

```dart
final authService = AuthService();

// Login
final result = await authService.customerLogin(email, password);
if (result['success'] == true) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => CustomerHomeScreen()),
  );
}

// Logout
await authService.logout();
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => WelcomeScreen()),
);
```

### 3. Model Kullanımı

```dart
// JSON'dan model oluşturma
final json = {
  'id': 1,
  'customer_id': 1,
  'appointment_date': '2024-01-15',
  'status': 'pending',
};
final appointment = Appointment.fromJson(json);

// Model'den JSON'a çevirme
final json = appointment.toJson();
```

---

**Son Güncelleme**: 2024
**Versiyon**: 1.0.0
**Flutter SDK**: ^3.9.2
