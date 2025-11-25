import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../models/business.dart';
import '../models/service.dart';
import '../models/employee.dart';
import '../models/appointment.dart';

class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _appointmentService = AppointmentService();
  final _authService = AuthService();
  final _notesController = TextEditingController();

  List<Business> _businesses = [];
  List<Service> _services = [];
  List<Employee> _employees = [];
  List<Map<String, dynamic>> _employeeSchedule = [];

  Business? _selectedBusiness;
  Set<int> _selectedServiceIds = {}; // Seçili hizmet ID'leri
  List<Service> _selectedServices = []; // Seçili hizmetler (görüntüleme için)
  Employee? _selectedEmployee;
  DateTime? _selectedDate;
  String? _selectedTime;

  bool _isLoading = false;
  bool _isLoadingBusinesses = true;
  bool _isLoadingServices = false;
  bool _isLoadingEmployees = false;

  final List<String> _timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinesses() async {
    try {
      final businesses = await _appointmentService.getBusinesses();
      setState(() {
        _businesses = businesses;
        _isLoadingBusinesses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBusinesses = false;
      });
    }
  }

  Future<void> _loadServices(int businessId) async {
    if (businessId <= 0) {
      print('Invalid business_id: $businessId');
      return;
    }

        setState(() {
          _isLoadingServices = true;
          _services = [];
          _selectedServiceIds.clear();
          _selectedServices = [];
        });

    try {
      print('Loading services for business_id: $businessId');
      final services = await _appointmentService.getServices(businessId);
      print('Loaded ${services.length} services');
      
      // Debug: Her hizmeti yazdır
      for (var service in services) {
        print('  - ${service.serviceName}: ${service.price} ₺ (${service.duration} dk)');
      }
      
      if (mounted) {
        setState(() {
          _services = services;
          _isLoadingServices = false;
        });
        
        if (services.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu işletme için hizmet bulunamadı'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error loading services: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoadingServices = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hizmetler yüklenirken hata: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadEmployees(int businessId) async {
    setState(() {
      _isLoadingEmployees = true;
      _employees = [];
      _selectedEmployee = null;
      _employeeSchedule = [];
    });

    try {
      final employees = await _appointmentService.getEmployees(businessId);
      if (mounted) {
        setState(() {
          _employees = employees;
          _isLoadingEmployees = false;
        });
      }
    } catch (e) {
      print('Error loading employees: $e');
      if (mounted) {
        setState(() {
          _isLoadingEmployees = false;
        });
      }
    }
  }

  Future<void> _loadEmployeeSchedule(int employeeId) async {
    try {
      print('Loading schedule for employee_id: $employeeId');
      final schedule = await _appointmentService.getEmployeeSchedule(employeeId);
      print('Loaded ${schedule.length} schedule entries');
      if (mounted) {
        setState(() {
          _employeeSchedule = schedule;
        });
      }
    } catch (e) {
      print('Error loading employee schedule: $e');
    }
  }

  Future<void> _createAppointment() async {
    if (_selectedBusiness == null ||
        _selectedServices.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir hizmet seçin ve tüm alanları doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authData = await _authService.loadAuthData();
    if (authData == null || authData['userType'] != 'customer') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oturum bilgisi bulunamadı'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final customerId = (authData['userData'] as Map<String, dynamic>)['id']
          as int;

      // Seçili hizmetleri ID'lerden al
      final selectedServicesList = _services.where((s) => _selectedServiceIds.contains(s.id)).toList();
      
      if (selectedServicesList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen en az bir hizmet seçin'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Her seçilen hizmet için ayrı randevu oluştur
      int successCount = 0;
      int failCount = 0;
      String? lastError;

      for (var service in selectedServicesList) {
        final appointment = Appointment(
          customerId: customerId,
          businessId: _selectedBusiness!.id!,
          employeeId: _selectedEmployee?.id,
          serviceId: service.id!,
          appointmentDate: _selectedDate!,
          appointmentTime: _selectedTime!,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        final result = await _appointmentService.createAppointment(appointment);

        if (result['success'] == true) {
          successCount++;
        } else {
          failCount++;
          lastError = result['message'] ?? 'Randevu oluşturulamadı';
        }
      }

      if (!mounted) return;

      if (successCount > 0) {
        String message;
        if (successCount == _selectedServices.length) {
          message = '$successCount randevu başarıyla oluşturuldu!';
        } else {
          message = '$successCount randevu oluşturuldu, $failCount randevu başarısız oldu.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: successCount == _selectedServices.length 
                ? Colors.green 
                : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lastError ?? 'Randevular oluşturulamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Randevu'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // İşletme seçimi
            _buildSectionTitle('İşletme Seçin'),
            _isLoadingBusinesses
                ? const Center(child: CircularProgressIndicator())
                : _buildBusinessDropdown(),
            const SizedBox(height: 24),

            // Hizmet seçimi
            if (_selectedBusiness != null) ...[
              _buildSectionTitle('Hizmet Seçin'),
              _isLoadingServices
                  ? const Center(child: CircularProgressIndicator())
                  : _buildServiceGrid(),
              const SizedBox(height: 16),
              // Toplam fiyat gösterimi
              if (_selectedServices.isNotEmpty) _buildTotalPrice(),
              const SizedBox(height: 24),
            ],

            // Çalışan seçimi
            if (_selectedBusiness != null) ...[
              _buildSectionTitle('Çalışan Seçin (Opsiyonel)'),
              _isLoadingEmployees
                  ? const Center(child: CircularProgressIndicator())
                  : _buildEmployeeDropdown(),
              const SizedBox(height: 16),
              // Çalışan takvimi
              if (_selectedEmployee != null) ...[
                _buildEmployeeSchedule(),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 24),
            ],

            // Tarih seçimi
            _buildSectionTitle('Tarih Seçin'),
            _buildDateSelector(),
            const SizedBox(height: 24),

            // Saat seçimi
            if (_selectedDate != null) ...[
              _buildSectionTitle('Saat Seçin'),
              _buildTimeGrid(),
              const SizedBox(height: 24),
            ],

            // Notlar
            _buildSectionTitle('Notlar (Opsiyonel)'),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Randevu ile ilgili notlarınız...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Randevu oluştur butonu
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Randevu Oluştur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBusinessDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Business>(
          isExpanded: true,
          hint: const Text('İşletme seçiniz'),
          value: _selectedBusiness,
          items: _businesses.map((business) {
            return DropdownMenuItem<Business>(
              value: business,
              child: Text(business.businessName),
            );
          }).toList(),
          onChanged: (Business? business) {
            setState(() {
              _selectedBusiness = business;
              _selectedServiceIds.clear();
              _selectedServices = [];
              _selectedEmployee = null;
              _services = [];
              _employees = [];
            });
            if (business != null && business.id != null) {
              print('Business selected: ${business.businessName} (id: ${business.id})');
              _loadServices(business.id!);
              _loadEmployees(business.id!);
            } else {
              print('Business is null or has no id');
            }
          },
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    print('Building service grid with ${_services.length} services');
    
    if (_isLoadingServices) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Bu işletme için hizmet bulunamadı. Lütfen başka bir işletme seçin.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _services.map((service) {
        final serviceId = service.id!;
        final isSelected = _selectedServiceIds.contains(serviceId);
        
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 48) / 2 - 6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                print('TAPPED: ${service.serviceName}, ID: $serviceId, Currently selected: $isSelected');
                
                setState(() {
                  if (isSelected) {
                    _selectedServiceIds.remove(serviceId);
                    _selectedServices.removeWhere((s) => s.id == serviceId);
                    print('REMOVED: ${service.serviceName}');
                  } else {
                    _selectedServiceIds.add(serviceId);
                    _selectedServices.add(service);
                    print('ADDED: ${service.serviceName}');
                  }
                  print('Total selected: ${_selectedServices.length}');
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          service.serviceName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (service.duration > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${service.duration} dk',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${service.price.toStringAsFixed(0)} ₺',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.deepPurple.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmployeeDropdown() {
    if (_employees.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Çalışan seçimi opsiyoneldir',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Employee>(
          isExpanded: true,
          hint: const Text('Çalışan seçiniz (Opsiyonel)'),
          value: _selectedEmployee,
          items: _employees.map((employee) {
            return DropdownMenuItem<Employee>(
              value: employee,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 15,
                    child: Icon(Icons.person, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(employee.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (Employee? employee) {
            setState(() {
              _selectedEmployee = employee;
              _employeeSchedule = [];
            });
            if (employee != null) {
              _loadEmployeeSchedule(employee.id!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTotalPrice() {
    // Seçili hizmetleri güncelle (ID'lerden)
    _selectedServices = _services.where((s) => _selectedServiceIds.contains(s.id)).toList();
    
    final totalPrice = _selectedServices.fold<double>(
      0.0,
      (sum, service) => sum + service.price,
    );
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt, color: Colors.deepPurple.shade700, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seçilen Hizmetler (${_selectedServices.length})',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${totalPrice.toStringAsFixed(2)} ₺',
                        style: TextStyle(
                          color: Colors.deepPurple.shade700,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Toplam',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (_selectedServices.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ..._selectedServices.map((service) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service.serviceName,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '${service.price.toStringAsFixed(2)} ₺',
                      style: TextStyle(
                        color: Colors.deepPurple.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmployeeSchedule() {
    if (_employeeSchedule.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Bu çalışan için çalışma takvimi tanımlanmamış',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final dayNames = ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.green.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                '${_selectedEmployee?.name} - Çalışma Saatleri',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._employeeSchedule.map((schedule) {
            final dayOfWeek = schedule['day_of_week'] as int;
            final startTime = schedule['start_time'] as String;
            final endTime = schedule['end_time'] as String;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      dayNames[dayOfWeek],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '$startTime - $endTime',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.deepPurple,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _selectedTime = null;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.deepPurple),
                const SizedBox(width: 15),
                Text(
                  _selectedDate == null
                      ? 'Tarih seçiniz'
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate == null
                        ? Colors.grey
                        : Colors.black87,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _timeSlots.length,
      itemBuilder: (context, index) {
        final time = _timeSlots[index];
        final isSelected = _selectedTime == time;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedTime = time;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.deepPurple
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

