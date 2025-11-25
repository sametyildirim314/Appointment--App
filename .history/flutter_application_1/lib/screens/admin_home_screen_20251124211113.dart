import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../services/api_service.dart';
import '../models/customer.dart';
import '../models/business.dart';
import '../models/appointment.dart';
import '../widgets/responsive_wrapper.dart';
import 'welcome_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _authService = AuthService();
  final _adminService = AdminService();
  final _apiService = ApiService(); // API service instance ekle
  final _businessSearchController = TextEditingController();
  final _customerSearchController = TextEditingController();
  final Set<int> _businessStatusLoading = {};
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  
  Map<String, dynamic>? _adminData;
  Map<String, dynamic> _stats = {};
  List<Customer> _customers = [];
  List<Business> _businesses = [];
  List<Appointment> _appointments = [];
  String _businessSearchQuery = '';
  String _customerSearchQuery = '';
  
  int _selectedIndex = 0;
  bool _isLoadingStats = true;
  bool _isLoadingBusinesses = false;
  bool _isLoadingCustomers = false;
  bool _isLoadingAppointments = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _businessSearchController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _loadAdminData();
    // Token yüklendikten sonra stats'ı çek
    await Future.delayed(Duration(milliseconds: 100)); // Token'ın set edilmesi için kısa bekleme
    await _loadStats();
  }

  Future<void> _loadAdminData() async {
    final authData = await _authService.loadAuthData();
    if (authData != null && authData['userType'] == 'admin') {
      final token = authData['token'] as String?;
      if (token != null) {
        // Token'ı API service'e set et
        _apiService.setToken(token, 'admin');
        print('Admin token set: ${token.substring(0, 20)}...');
      }
      
      if (mounted) {
        setState(() {
          _adminData = authData['userData'] as Map<String, dynamic>;
        });
      }
    } else {
      if (!mounted) return;
      await _logout();
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _adminService.getAdminStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _loadCustomers({bool force = false}) async {
    if (!force && _customers.isNotEmpty) return; // Already loaded
    
    setState(() {
      _isLoadingCustomers = true;
    });

    try {
      final customers = await _adminService.getCustomers();
      if (mounted) {
        setState(() {
          _customers = customers;
        });
      }
    } catch (e) {
      print('Error loading customers: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCustomers = false;
        });
      }
    }
  }

  Future<void> _loadBusinesses({bool force = false}) async {
    if (!force && _businesses.isNotEmpty) return; // Already loaded
    
    setState(() {
      _isLoadingBusinesses = true;
    });

    try {
      final businesses = await _adminService.getBusinesses();
      if (mounted) {
        setState(() {
          _businesses = businesses;
        });
      }
    } catch (e) {
      print('Error loading businesses: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBusinesses = false;
        });
      }
    }
  }

  Future<void> _loadAppointments({bool force = false}) async {
    if (!force && _appointments.isNotEmpty) return; // Already loaded
    
    setState(() {
      _isLoadingAppointments = true;
    });

    try {
      final appointments = await _adminService.getAllAppointments();
      if (mounted) {
        setState(() {
          _appointments = appointments;
        });
      }
    } catch (e) {
      print('Error loading appointments: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAppointments = false;
        });
      }
    }
  }

  Future<void> _toggleBusinessStatus(Business business, bool value) async {
    if (business.id == null) return;

    setState(() {
      _businessStatusLoading.add(business.id!);
    });

    final previousValue = business.isActive;
    final updatedBusiness =
        await _adminService.updateBusinessStatus(business.id!, value);

    if (!mounted) {
      return;
    }

    setState(() {
      _businessStatusLoading.remove(business.id!);
      if (updatedBusiness != null) {
        final index =
            _businesses.indexWhere((element) => element.id == business.id);
        if (index != -1) {
          _businesses[index] = updatedBusiness;
        }
      } else {
        final index =
            _businesses.indexWhere((element) => element.id == business.id);
        if (index != -1) {
          _businesses[index] =
              _businesses[index].copyWith(isActive: previousValue);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'İşletme durumu güncellenemedi',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    });
  }

  void _showBusinessDetails(Business business) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade100,
                      child:
                          Icon(Icons.business, color: Colors.blue.shade700, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            business.businessName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            business.ownerName,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow(Icons.email, business.email),
                _buildDetailRow(Icons.phone, business.phone),
                if (business.address != null && business.address!.isNotEmpty)
                  _buildDetailRow(Icons.location_on,
                      '${business.address}${business.city != null ? ', ${business.city}' : ''}${business.district != null ? ', ${business.district}' : ''}'),
                if (business.description != null &&
                    business.description!.isNotEmpty)
                  _buildDetailRow(Icons.info_outline, business.description!),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      business.isActive ? Icons.check_circle : Icons.cancel,
                      color: business.isActive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      business.isActive ? 'Aktif' : 'Pasif',
                      style: TextStyle(
                        color: business.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _toggleBusinessStatus(business, !business.isActive);
                        },
                        icon: Icon(
                          business.isActive ? Icons.pause_circle : Icons.play_circle,
                        ),
                        label: Text(
                          business.isActive
                              ? 'Pasif Hale Getir'
                              : 'Aktif Hale Getir',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: business.isActive
                              ? Colors.orange.shade600
                              : Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
      onChanged: onChanged,
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          _buildBackgroundGradients(),
          _buildBlurredDecorations(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
                _buildBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradients() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
            const Color(0xFF7F1D1D),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildBlurredDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFEF4444).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFDC2626).withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Paneli',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _adminData?['full_name'] ?? 'Admin',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: _logout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFFEF4444),
        unselectedItemColor: Colors.white.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'İşletmeler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Müşteriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Randevular',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingStats && _selectedIndex == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = _buildDashboard();
        break;
      case 1:
        _loadBusinesses();
        body = _buildBusinesses();
        break;
      case 2:
        _loadCustomers();
        body = _buildCustomers();
        break;
      case 3:
        _loadAppointments();
        body = _buildAppointments();
        break;
      default:
        body = _buildDashboard();
    }
    
    return ResponsiveWrapper(child: body);
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard(
                'Toplam İşletme',
                '${_stats['totalBusinesses'] ?? 0}',
                const Color(0xFF3B82F6),
                Icons.business,
              ),
              _buildStatCard(
                'Toplam Müşteri',
                '${_stats['totalCustomers'] ?? 0}',
                const Color(0xFF10B981),
                Icons.people,
              ),
              _buildStatCard(
                'Bugünkü Randevular',
                '${_stats['todayAppointments'] ?? 0}',
                const Color(0xFFF59E0B),
                Icons.calendar_today,
              ),
              _buildStatCard(
                'Bekleyen Randevular',
                '${_stats['pendingAppointments'] ?? 0}',
                const Color(0xFF8B5CF6),
                Icons.pending,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Hızlı İşlemler'),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildQuickActionCard(
                'İşletme Ekle',
                Icons.add_business,
                const Color(0xFF3B82F6),
              ),
              _buildQuickActionCard(
                'Müşteri Listesi',
                Icons.people_outline,
                const Color(0xFF10B981),
              ),
              _buildQuickActionCard(
                'Randevu Yönetimi',
                Icons.calendar_view_day,
                const Color(0xFFF59E0B),
              ),
              _buildQuickActionCard(
                'Raporlar',
                Icons.assessment,
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yönetim Paneli',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sistem yönetimi ve izleme',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildBusinesses() {
    if (_isLoadingBusinesses && _businesses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredBusinesses = _businesses.where((business) {
      if (_businessSearchQuery.isEmpty) return true;
      final query = _businessSearchQuery.toLowerCase();
      return business.businessName.toLowerCase().contains(query) ||
          business.ownerName.toLowerCase().contains(query) ||
          business.email.toLowerCase().contains(query) ||
          (business.city ?? '').toLowerCase().contains(query);
    }).toList();

    return RefreshIndicator(
      onRefresh: () => _loadBusinesses(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
          children: [
          _buildSearchField(
            controller: _businessSearchController,
            hintText: 'İşletme, sahip veya şehir ara',
            onChanged: (value) {
              setState(() {
                _businessSearchQuery = value;
              });
            },
          ),
          if (_isLoadingBusinesses && _businesses.isNotEmpty) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 16),
          if (filteredBusinesses.isEmpty)
            _buildEmptyState(
              icon: Icons.business,
              message: _businessSearchQuery.isEmpty
                  ? 'Henüz işletme yok'
                  : 'Aramanıza uygun işletme bulunamadı',
            )
          else
            ...filteredBusinesses.map((business) {
              final isActive = business.isActive;
              final statusColor =
                  isActive ? Colors.green : Colors.redAccent;
              final isLoading = _businessStatusLoading.contains(business.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _showBusinessDetails(business),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
      padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 26,
              backgroundColor: Colors.blue.shade100,
                              child:
                                  Icon(Icons.business, color: Colors.blue.shade700),
            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    business.businessName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    business.ownerName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    business.email,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (business.city != null ||
                                      business.district != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              [
                                                if (business.district != null &&
                                                    business.district!.isNotEmpty)
                                                  business.district!,
                                                if (business.city != null &&
                                                    business.city!.isNotEmpty)
                                                  business.city!,
                                              ].join(', '),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Switch.adaptive(
                                  value: isActive,
                                  onChanged: isLoading
                                      ? null
                                      : (value) =>
                                          _toggleBusinessStatus(business, value),
                                  activeColor: Colors.green,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isActive
                                            ? Icons.check_circle
                                            : Icons.pause_circle_filled,
                                        size: 14,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isActive ? 'Aktif' : 'Pasif',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isLoading) ...[
                                  const SizedBox(height: 8),
                                  const SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        );
            }),
        ],
      ),
    );
  }

  Widget _buildCustomers() {
    if (_isLoadingCustomers && _customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredCustomers = _customers.where((customer) {
      if (_customerSearchQuery.isEmpty) return true;
      final query = _customerSearchQuery.toLowerCase();
      return customer.name.toLowerCase().contains(query) ||
          customer.email.toLowerCase().contains(query) ||
          customer.phone.toLowerCase().contains(query);
    }).toList();

    return RefreshIndicator(
      onRefresh: () => _loadCustomers(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
          children: [
          _buildSearchField(
            controller: _customerSearchController,
            hintText: 'Müşteri adı veya e-posta ara',
            onChanged: (value) {
              setState(() {
                _customerSearchQuery = value;
              });
            },
          ),
          if (_isLoadingCustomers && _customers.isNotEmpty) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 16),
          if (filteredCustomers.isEmpty)
            _buildEmptyState(
              icon: Icons.people,
              message: _customerSearchQuery.isEmpty
                  ? 'Henüz müşteri yok'
                  : 'Aramanıza uygun müşteri bulunamadı',
            )
          else
            ...filteredCustomers.map((customer) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.person, color: Colors.green.shade700),
            ),
            title: Text(customer.name),
            subtitle: Text('${customer.email}\n${customer.phone}'),
            isThreeLine: true,
          ),
        );
            }),
        ],
      ),
    );
  }

  String _formatPrice(double value) => _currencyFormatter.format(value);

  Widget _buildAppointments() {
    if (_isLoadingAppointments && _appointments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_appointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today,
        message: 'Henüz randevu yok',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAppointments(force: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor:
                    _getStatusColor(appointment.status).withOpacity(0.2),
                child: Icon(
                  Icons.calendar_month,
                  color: _getStatusColor(appointment.status),
                ),
            ),
            title: Text(appointment.businessName ?? 'İşletme'),
            subtitle: Text(
                '${appointment.customerName ?? 'Müşteri'}'
                '${appointment.customerPhone != null ? '\n${appointment.customerPhone}' : ''}\n'
                '${appointment.serviceName ?? 'Hizmet'}\n'
                '${appointment.appointmentDate.toString().split(' ')[0]} ${appointment.appointmentTime}'
                '${appointment.servicePrice != null ? '\nÜcret: ${_formatPrice(appointment.servicePrice!)}' : ''}',
            ),
            isThreeLine: true,
            trailing: Chip(
              label: Text(
                appointment.status.displayName,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: _getStatusColor(appointment.status),
            ),
          ),
        );
      },
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    final width = (MediaQuery.of(context).size.width - 64) / 2;
    return SizedBox(
      width: width > 200 ? 200 : width,
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        switch (title) {
          case 'İşletme Ekle':
            setState(() {
              _selectedIndex = 1;
            });
            _loadBusinesses(force: true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'İşletme listesi açıldı. Yeni kayıt için işletme sahibine kayıt ekranını kullanmasını iletebilirsiniz.',
                ),
              ),
            );
            break;
          case 'Müşteri Listesi':
            setState(() {
              _selectedIndex = 2;
            });
            _loadCustomers(force: true);
            break;
          case 'Randevu Yönetimi':
            setState(() {
              _selectedIndex = 3;
            });
            _loadAppointments(force: true);
            break;
          case 'Raporlar':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Raporlar yakında eklenecek!'),
              ),
            );
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

