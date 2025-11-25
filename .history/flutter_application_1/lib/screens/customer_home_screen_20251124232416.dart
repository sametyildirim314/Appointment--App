import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/appointment_service.dart';
import '../models/appointment.dart';
import '../widgets/responsive_wrapper.dart';
import 'welcome_screen.dart';
import 'create_appointment_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _authService = AuthService();
  final _appointmentService = AppointmentService();
  Map<String, dynamic>? _customerData;
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  double _totalPaid = 0;
  int _completedCount = 0;
  int _upcomingCount = 0;
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCustomerData();
    await _loadAppointments();
  }

  Future<void> _loadCustomerData() async {
    final authData = await _authService.loadAuthData();
    if (authData == null || authData['userType'] != 'customer') {
      if (!mounted) return;
      await _logout();
      return;
    }

    setState(() {
      _customerData = authData['userData'] as Map<String, dynamic>;
    });
  }

  Future<void> _loadAppointments() async {
    if (_customerData == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final customerId = _customerData!['id'] as int;
      final appointments = await _appointmentService.getCustomerAppointments(
        customerId,
      );
      final metrics = _calculateMetrics(appointments);

      if (mounted) {
        setState(() {
          _appointments = appointments;
          _isLoading = false;
          _totalPaid = metrics['totalPaid'] as double;
          _completedCount = metrics['completedCount'] as int;
          _upcomingCount = metrics['upcomingCount'] as int;
        });
      }
    } catch (e) {
      print('Error loading appointments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  Map<String, num> _calculateMetrics(List<Appointment> appointments) {
    final now = DateTime.now();
    double totalPaid = 0;
    int completedCount = 0;
    int upcomingCount = 0;

    for (final appointment in appointments) {
      final dateTime = _getAppointmentDateTime(appointment);
      final price = appointment.servicePrice ?? 0;

      if (appointment.status == AppointmentStatus.completed) {
        completedCount++;
        totalPaid += price;
      } else if (appointment.status == AppointmentStatus.confirmed &&
          dateTime.isBefore(now)) {
        totalPaid += price;
      }

      if ((appointment.status == AppointmentStatus.pending ||
              appointment.status == AppointmentStatus.confirmed) &&
          dateTime.isAfter(now)) {
        upcomingCount++;
      }
    }

    return {
      'totalPaid': totalPaid,
      'completedCount': completedCount,
      'upcomingCount': upcomingCount,
    };
  }

  DateTime _getAppointmentDateTime(Appointment appointment) {
    final parts = appointment.appointmentTime.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(
      appointment.appointmentDate.year,
      appointment.appointmentDate.month,
      appointment.appointmentDate.day,
      hour,
      minute,
    );
  }

  String _formatPrice(double value) => _currencyFormatter.format(value);

  String _formatDuration(int minutes) => '$minutes dk';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2639),
      body: Stack(
        children: [
          _buildBackgroundGradients(),
          _buildBlurredDecorations(),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ResponsiveWrapper(
                    child: RefreshIndicator(
                      onRefresh: _loadAppointments,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildWelcomeCard(),
                          const SizedBox(height: 20),
                          _buildCreateAppointmentButton(),
                          const SizedBox(height: 24),
                          _buildSummarySection(),
                          const SizedBox(height: 24),
                          _buildSectionTitle(
                            'Randevularım',
                            _appointments.length,
                          ),
                          const SizedBox(height: 16),
                          if (_appointments.isEmpty)
                            _buildEmptyState()
                          else
                            ..._appointments.map(
                              (apt) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildAppointmentCard(apt),
                              ),
                            ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAppointmentScreen(),
            ),
          );
          if (result == true) {
            _loadAppointments();
          }
        },
        backgroundColor: const Color(0xFF6C7FFE),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Yeni Randevu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBackgroundGradients() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF161C2A),
            Color(0xFF262F45),
            Color(0xFF3D4A66),
          ],
          stops: [0.0, 0.55, 1.0],
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
                  const Color(0xFF7C8AE0).withOpacity(0.28),
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
                  const Color(0xFF6BA6CF).withOpacity(0.22),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoş Geldiniz',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _customerData?['name'] ?? 'Müşteri',
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
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Randevu Yönetimi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hızlı ve kolay randevu sistemi',
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
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip(Icons.schedule, 'Anında Onay'),
              _buildFeatureChip(Icons.notifications, 'Hatırlatma'),
              _buildFeatureChip(Icons.security, 'Güvenli'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAppointmentButton() {
    return _buildGlassCard(
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAppointmentScreen(),
            ),
          );
          if (result == true) {
            _loadAppointments();
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yeni Randevu Oluştur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hizmet seç, tarih belirle, randevunu oluştur',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSummaryCard(
          title: 'Toplam Harcama',
          value: _formatPrice(_totalPaid),
          icon: Icons.payments,
          color: const Color(0xFF6366F1),
          subtitle: 'Tamamlanan + geçmiş',
        ),
        _buildSummaryCard(
          title: 'Tamamlanan',
          value: '$_completedCount',
          icon: Icons.check_circle,
          color: const Color(0xFF10B981),
          subtitle: 'Başarıyla tamamlandı',
        ),
        _buildSummaryCard(
          title: 'Yaklaşan',
          value: '$_upcomingCount',
          icon: Icons.schedule,
          color: const Color(0xFFF59E0B),
          subtitle: 'Bekleyen & onaylı',
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
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
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count kayıt',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'Henüz randevunuz bulunmuyor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni randevu oluşturmak için yukarıdaki butonu veya sağ alttaki artı ikonunu kullanabilirsiniz.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    Color statusColor;
    switch (appointment.status) {
      case AppointmentStatus.pending:
        statusColor = const Color(0xFFF59E0B);
        break;
      case AppointmentStatus.confirmed:
        statusColor = const Color(0xFF10B981);
        break;
      case AppointmentStatus.completed:
        statusColor = const Color(0xFF6366F1);
        break;
      case AppointmentStatus.cancelled:
        statusColor = const Color(0xFFEF4444);
        break;
    }

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  appointment.status.displayName,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.access_time, appointment.appointmentTime),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.business, appointment.businessName ?? 'İşletme'),
          if (appointment.serviceName != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.content_cut,
              appointment.serviceName!,
              isBold: true,
            ),
          ],
          if (appointment.employeeName != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.person, appointment.employeeName!),
          ],
          if (appointment.servicePrice != null ||
              appointment.serviceDuration != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (appointment.servicePrice != null)
                  _buildInfoChip(
                    icon: Icons.payments,
                    label: 'Ücret',
                    value: _formatPrice(appointment.servicePrice!),
                    color: const Color(0xFF6366F1),
                  ),
                if (appointment.serviceDuration != null)
                  _buildInfoChip(
                    icon: Icons.timelapse,
                    label: 'Süre',
                    value: _formatDuration(appointment.serviceDuration!),
                    color: const Color(0xFF8B5CF6),
                  ),
              ],
            ),
          ],
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 18,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      appointment.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withOpacity(0.6)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
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
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }
}
