import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/appointment_service.dart';
import '../models/appointment.dart';
import '../models/service.dart';
import '../models/employee.dart';
import '../services/business_service.dart';
import '../widgets/responsive_wrapper.dart';
import 'welcome_screen.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  final _authService = AuthService();
  final _appointmentService = AppointmentService();
  final _businessService = BusinessService();
  Map<String, dynamic>? _businessData;
  List<Appointment> _appointments = [];
  List<Service> _services = [];
  List<Employee> _employees = [];
  bool _isLoading = true;
  bool _isServicesLoading = false;
  bool _isEmployeesLoading = false;
  bool _isUpdatingHours = false;
  String _selectedFilter =
      'all'; // all, pending, confirmed, completed, cancelled
  double _totalRevenue = 0;
  double _todayRevenue = 0;
  int _todayCount = 0;
  int _pendingCount = 0;
  int _confirmedCount = 0;
  int _completedCount = 0;
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
  );
  final Set<int> _entityActionLoading = {};
  final Set<int> _serviceActionLoading = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadBusinessData();
    await Future.wait([_loadAppointments(), _loadServices(), _loadEmployees()]);
  }

  Future<void> _loadBusinessData() async {
    final authData = await _authService.loadAuthData();
    if (authData == null || authData['userType'] != 'business') {
      if (!mounted) return;
      await _logout();
      return;
    }

    setState(() {
      _businessData = authData['userData'] as Map<String, dynamic>;
    });
  }

  Future<void> _loadAppointments() async {
    if (_businessData == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final businessId = _businessData!['id'] as int;
      final appointments = await _appointmentService.getBusinessAppointments(
        businessId,
      );
      final metrics = _calculateMetrics(appointments);
      if (mounted) {
        setState(() {
          _appointments = appointments;
          _isLoading = false;
          _totalRevenue = metrics['totalRevenue'] as double;
          _todayRevenue = metrics['todayRevenue'] as double;
          _todayCount = metrics['todayCount'] as int;
          _pendingCount = metrics['pendingCount'] as int;
          _confirmedCount = metrics['confirmedCount'] as int;
          _completedCount = metrics['completedCount'] as int;
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

  Future<void> _loadServices() async {
    if (_businessData == null) {
      return;
    }

    setState(() {
      _isServicesLoading = true;
    });

    try {
      final services = await _businessService.getMyServices();
      if (mounted) {
        setState(() {
          _services = services;
        });
      }
    } catch (e) {
      print('Error loading services: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hizmetler yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isServicesLoading = false;
        });
      }
    }
  }

  Future<void> _loadEmployees() async {
    if (_businessData == null) {
      return;
    }

    setState(() {
      _isEmployeesLoading = true;
    });

    try {
      final employees = await _businessService.getMyEmployees();
      if (mounted) {
        setState(() {
          _employees = employees;
        });
      }
    } catch (e) {
      print('Error loading employees: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çalışanlar yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEmployeesLoading = false;
        });
      }
    }
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([_loadAppointments(), _loadServices(), _loadEmployees()]);
  }

  Future<void> _handleServiceSubmit({
    int? serviceId,
    required String name,
    String? description,
    required int duration,
    required double price,
    required bool isActive,
  }) async {
    try {
      Service? result;
      if (serviceId == null) {
        result = await _businessService.createService(
          name: name,
          description: description,
          duration: duration,
          price: price,
          isActive: isActive,
        );
      } else {
        result = await _businessService.updateService(
          serviceId,
          name: name,
          description: description,
          duration: duration,
          price: price,
          isActive: isActive,
        );
      }

      if (!mounted) return;

      if (result != null) {
        await _loadServices();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              serviceId == null
                  ? 'Hizmet başarıyla oluşturuldu'
                  : 'Hizmet güncellendi',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hizmet kaydedilemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hizmet kaydedilirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleServiceStatus(Service service, bool isActive) async {
    if (service.id == null) return;

    setState(() {
      _entityActionLoading.add(service.id!);
    });

    try {
      final updated = await _businessService.updateService(
        service.id!,
        isActive: isActive,
      );
      if (!mounted) return;

      if (updated != null) {
        setState(() {
          _services = _services
              .map((item) => item.id == service.id ? updated : item)
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Durum değiştirilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted && service.id != null) {
        setState(() {
          _entityActionLoading.remove(service.id!);
        });
      }
    }
  }

  Future<void> _handleEmployeeSubmit({
    int? employeeId,
    required String name,
    required String email,
    required String phone,
    String? specialization,
    required bool isActive,
  }) async {
    try {
      Employee? result;
      if (employeeId == null) {
        result = await _businessService.createEmployee(
          name: name,
          email: email,
          phone: phone,
          specialization: specialization,
          isActive: isActive,
        );
      } else {
        result = await _businessService.updateEmployee(
          employeeId,
          name: name,
          email: email,
          phone: phone,
          specialization: specialization,
          isActive: isActive,
        );
      }

      if (!mounted) return;

      if (result != null) {
        await _loadEmployees();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              employeeId == null
                  ? 'Çalışan başarıyla eklendi'
                  : 'Çalışan güncellendi',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çalışan kaydedilemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çalışan kaydedilirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleEmployeeStatus(Employee employee, bool isActive) async {
    if (employee.id == null) return;

    setState(() {
      _entityActionLoading.add(employee.id!);
    });

    try {
      final updated = await _businessService.updateEmployee(
        employee.id!,
        isActive: isActive,
      );
      if (!mounted) return;

      if (updated != null) {
        setState(() {
          _employees = _employees
              .map((item) => item.id == employee.id ? updated : item)
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Durum değiştirilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted && employee.id != null) {
        setState(() {
          _entityActionLoading.remove(employee.id!);
        });
      }
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    if (employee.id == null) return;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Çalışanı sil'),
            content: Text(
              '"${employee.name}" çalışanını silmek istediğinize emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    setState(() {
      _entityActionLoading.add(employee.id!);
    });

    try {
      final success = await _businessService.deleteEmployee(employee.id!);
      if (!mounted) return;

      if (success) {
        await _loadEmployees();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çalışan silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çalışan silinemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çalışan silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted && employee.id != null) {
        setState(() {
          _entityActionLoading.remove(employee.id!);
        });
      }
    }
  }

  Future<void> _showEmployeeForm({Employee? employee}) async {
    final nameController = TextEditingController(text: employee?.name ?? '');
    final emailController = TextEditingController(text: employee?.email ?? '');
    final phoneController = TextEditingController(text: employee?.phone ?? '');
    final specializationController = TextEditingController(
      text: employee?.specialization ?? '',
    );
    bool isActive = employee?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee == null ? 'Yeni Çalışan' : 'Çalışanı Düzenle',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Ad Soyad',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ad soyad zorunludur';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-posta',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'E-posta zorunludur';
                              }
                              if (!value.contains('@')) {
                                return 'Geçerli bir e-posta giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Telefon',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Telefon zorunludur';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: specializationController,
                            decoration: const InputDecoration(
                              labelText: 'Uzmanlık (opsiyonel)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SwitchListTile(
                            value: isActive,
                            onChanged: (value) {
                              setModalState(() {
                                isActive = value;
                              });
                            },
                            title: const Text('Çalışan aktif'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState?.validate() != true) {
                                  return;
                                }
                                final specialization = specializationController
                                    .text
                                    .trim();
                                Navigator.pop(context);
                                _handleEmployeeSubmit(
                                  employeeId: employee?.id,
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  specialization: specialization.isEmpty
                                      ? null
                                      : specialization,
                                  isActive: isActive,
                                );
                              },
                              child: Text(
                                employee == null
                                    ? 'Çalışanı Ekle'
                                    : 'Çalışanı Güncelle',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteService(Service service) async {
    if (service.id == null) return;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hizmeti sil'),
            content: Text(
              '"${service.serviceName}" hizmetini silmek istediğinize emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    setState(() {
      _serviceActionLoading.add(service.id!);
    });

    try {
      final success = await _businessService.deleteService(service.id!);
      if (!mounted) return;

      if (success) {
        await _loadServices();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hizmet silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hizmet silinemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hizmet silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted && service.id != null) {
        setState(() {
          _serviceActionLoading.remove(service.id!);
        });
      }
    }
  }

  Future<void> _showServiceForm({Service? service}) async {
    final nameController = TextEditingController(
      text: service?.serviceName ?? '',
    );
    final descriptionController = TextEditingController(
      text: service?.description ?? '',
    );
    final durationController = TextEditingController(
      text: service != null ? service.duration.toString() : '',
    );
    final priceController = TextEditingController(
      text: service != null ? service.price.toStringAsFixed(2) : '',
    );
    bool isActive = service?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service == null ? 'Yeni Hizmet' : 'Hizmeti Düzenle',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Hizmet Adı',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Hizmet adı zorunludur';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: descriptionController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Açıklama (opsiyonel)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: durationController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Süre (dk)',
                                    border: OutlineInputBorder(),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Süre zorunludur';
                                    }
                                    final duration = int.tryParse(value);
                                    if (duration == null || duration <= 0) {
                                      return 'Geçerli bir süre giriniz';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Ücret (₺)',
                                    border: OutlineInputBorder(),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.,]'),
                                    ),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ücret zorunludur';
                                    }
                                    final parsed = double.tryParse(
                                      value.replaceAll(',', '.'),
                                    );
                                    if (parsed == null || parsed < 0) {
                                      return 'Geçerli bir ücret giriniz';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SwitchListTile(
                            value: isActive,
                            onChanged: (value) {
                              setModalState(() {
                                isActive = value;
                              });
                            },
                            title: const Text('Hizmet aktif'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState?.validate() != true) {
                                  return;
                                }
                                final duration = int.parse(
                                  durationController.text.trim(),
                                );
                                final price = double.parse(
                                  priceController.text
                                      .replaceAll(',', '.')
                                      .trim(),
                                );
                                final description = descriptionController.text
                                    .trim();
                                Navigator.pop(context);
                                _handleServiceSubmit(
                                  serviceId: service?.id,
                                  name: nameController.text.trim(),
                                  description: description.isEmpty
                                      ? null
                                      : description,
                                  duration: duration,
                                  price: price,
                                  isActive: isActive,
                                );
                              },
                              child: Text(
                                service == null
                                    ? 'Hizmeti Oluştur'
                                    : 'Hizmeti Güncelle',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showWorkingHoursSheet() async {
    if (_businessData == null) return;

    TimeOfDay opening =
        _timeOfDayFromString(_businessData!['opening_time'] as String?) ??
        const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay closing =
        _timeOfDayFromString(_businessData!['closing_time'] as String?) ??
        const TimeOfDay(hour: 18, minute: 0);
    String? errorText;

    final result = await showModalBottomSheet<Map<String, TimeOfDay>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Çalışma Saatlerini Güncelle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildHoursPickerTile(
                    label: 'Açılış Saati',
                    time: opening,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: opening,
                      );
                      if (picked != null) {
                        setModalState(() {
                          opening = picked;
                          errorText = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildHoursPickerTile(
                    label: 'Kapanış Saati',
                    time: closing,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: closing,
                      );
                      if (picked != null) {
                        setModalState(() {
                          closing = picked;
                          errorText = null;
                        });
                      }
                    },
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(errorText!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_minutesFromTimeOfDay(closing) <=
                            _minutesFromTimeOfDay(opening)) {
                          setModalState(() {
                            errorText =
                                'Kapanış saati açılış saatinden sonra olmalıdır';
                          });
                          return;
                        }
                        Navigator.pop<Map<String, TimeOfDay>>(context, {
                          'opening': opening,
                          'closing': closing,
                        });
                      },
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result != null &&
        result['opening'] != null &&
        result['closing'] != null) {
      await _updateBusinessHours(result['opening']!, result['closing']!);
    }
  }

  Future<void> _updateBusinessHours(
    TimeOfDay opening,
    TimeOfDay closing,
  ) async {
    setState(() {
      _isUpdatingHours = true;
    });

    try {
      final updatedBusiness = await _businessService.updateBusinessHours(
        openingTime: _timeOfDayToApiString(opening),
        closingTime: _timeOfDayToApiString(closing),
      );

      if (!mounted) return;

      if (updatedBusiness != null) {
        final businessMap = updatedBusiness.toJson();
        setState(() {
          _businessData = businessMap;
        });
        await _authService.updateStoredBusinessData(businessMap);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çalışma saatleri güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çalışma saatleri güncellenemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saatler güncellenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingHours = false;
        });
      }
    }
  }

  TimeOfDay? _timeOfDayFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _timeOfDayToLabel(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _timeOfDayToApiString(TimeOfDay time) {
    final label = _timeOfDayToLabel(time);
    return '$label:00';
  }

  int _minutesFromTimeOfDay(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  Future<void> _updateAppointmentStatus(
    int appointmentId,
    AppointmentStatus newStatus,
  ) async {
    try {
      final result = await _appointmentService.updateAppointmentStatus(
        appointmentId,
        newStatus,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Randevu durumu güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAppointments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Güncelleme başarısız'),
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
    }
  }

  Map<String, num> _calculateMetrics(List<Appointment> appointments) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    double totalRevenue = 0;
    double todayRevenue = 0;
    int todayCount = 0;
    int pendingCount = 0;
    int confirmedCount = 0;
    int completedCount = 0;

    for (final appointment in appointments) {
      final price = appointment.servicePrice ?? 0;
      final dateTime = _getAppointmentDateTime(appointment);
      final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

      switch (appointment.status) {
        case AppointmentStatus.pending:
          pendingCount++;
          break;
        case AppointmentStatus.confirmed:
          confirmedCount++;
          totalRevenue += price;
          if (dateOnly == todayDate) {
            todayRevenue += price;
            todayCount++;
          }
          break;
        case AppointmentStatus.completed:
          completedCount++;
          totalRevenue += price;
          if (dateOnly == todayDate) {
            todayRevenue += price;
            todayCount++;
          }
          break;
        case AppointmentStatus.cancelled:
          break;
      }
    }

    return {
      'totalRevenue': totalRevenue,
      'todayRevenue': todayRevenue,
      'todayCount': todayCount,
      'pendingCount': pendingCount,
      'confirmedCount': confirmedCount,
      'completedCount': completedCount,
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

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '-';
    final parts = time.split(':');
    if (parts.length < 2) {
      return time;
    }
    return '${parts[0]}:${parts[1]}';
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

  List<Appointment> get _filteredAppointments {
    if (_selectedFilter == 'all') {
      return _appointments;
    }
    return _appointments.where((apt) {
      switch (_selectedFilter) {
        case 'pending':
          return apt.status == AppointmentStatus.pending;
        case 'confirmed':
          return apt.status == AppointmentStatus.confirmed;
        case 'completed':
          return apt.status == AppointmentStatus.completed;
        case 'cancelled':
          return apt.status == AppointmentStatus.cancelled;
        default:
          return true;
      }
    }).toList();
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ResponsiveWrapper(
                    child: RefreshIndicator(
                      onRefresh: _refreshDashboard,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 24),
                            _buildWelcomeCard(),

                            const SizedBox(height: 20),
                            _buildStatsSection(),
                            const SizedBox(height: 20),
                            _buildRevenueHighlight(),
                            const SizedBox(height: 20),
                            _buildWorkingHoursCard(),
                            const SizedBox(height: 20),
                            _buildServiceManagementSection(),
                            const SizedBox(height: 20),
                            _buildEmployeeManagementSection(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Randevular', _filteredAppointments.length),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip('all', 'Tümü'),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('pending', 'Beklemede'),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('confirmed', 'Onaylı'),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('completed', 'Tamamlandı'),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('cancelled', 'İptal'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_filteredAppointments.isEmpty)
                              _buildEmptyState()
                            else
                              ..._filteredAppointments.map((apt) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildAppointmentCard(apt),
                              )).toList(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
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
            const Color(0xFF1E3A8A),
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
                  const Color(0xFF3B82F6).withOpacity(0.3),
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
                  const Color(0xFF6366F1).withOpacity(0.2),
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
                'İşletme Yönetimi',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _businessData?['business_name'] ?? 'İşletme',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              if (_businessData?['city'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.white.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    Text(
                      '${_businessData!['city']}${_businessData!['district'] != null ? ', ${_businessData!['district']}' : ''}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
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
                    colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.storefront, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İşletme Paneli',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Randevularını yönet, gelirini takip et',
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

  Widget _buildStatsSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStatCard(
          label: 'Toplam Randevu',
          value: '${_appointments.length}',
          color: const Color(0xFF3B82F6),
          icon: Icons.calendar_today,
          subtitle: 'Tüm kayıtlar',
        ),
        _buildStatCard(
          label: 'Beklemede',
          value: '$_pendingCount',
          color: const Color(0xFFF59E0B),
          icon: Icons.pending_actions,
          subtitle: 'Yanıt bekliyor',
        ),
        _buildStatCard(
          label: 'Onaylı',
          value: '$_confirmedCount',
          color: const Color(0xFF10B981),
          icon: Icons.verified,
          subtitle: 'Planlanan hizmet',
        ),
        _buildStatCard(
          label: 'Tamamlanan',
          value: '$_completedCount',
          color: const Color(0xFF6366F1),
          icon: Icons.done_all,
          subtitle: 'Hizmeti verilen',
        ),
        _buildStatCard(
          label: 'Bugün',
          value: '$_todayCount',
          color: const Color(0xFF8B5CF6),
          icon: Icons.today,
          subtitle: _todayRevenue > 0
              ? 'Gelir: ${_formatPrice(_todayRevenue)}'
              : 'Gelir: -',
        ),
      ],
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
            Icon(Icons.calendar_today, size: 64, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 20),
            const Text(
              'Randevu bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
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

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
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
              label,
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

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueHighlight() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam Gelir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatPrice(_totalRevenue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.today, size: 16, color: Colors.white.withOpacity(0.8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _todayRevenue > 0
                        ? 'Bugün (${_todayCount} randevu): ${_formatPrice(_todayRevenue)}'
                        : 'Bugün henüz gelir yok',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    Color statusColor;
    switch (appointment.status) {
      case AppointmentStatus.pending:
        statusColor = Colors.orange;
        break;
      case AppointmentStatus.confirmed:
        statusColor = Colors.green;
        break;
      case AppointmentStatus.completed:
        statusColor = Colors.blue;
        break;
      case AppointmentStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          _buildInfoRow(Icons.person, appointment.customerName ?? 'Müşteri', isBold: true),
            if (appointment.serviceName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.content_cut,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.serviceName!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (appointment.serviceName != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.content_cut, appointment.serviceName!, isBold: true),
            ],
            if (appointment.employeeName != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.person_outline, appointment.employeeName!),
            ],
            if (appointment.customerPhone != null &&
                appointment.customerPhone!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone, appointment.customerPhone!),
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
                      value: '${appointment.serviceDuration} dk',
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
                    Icon(Icons.note_alt_outlined,
                        size: 18, color: Colors.white.withOpacity(0.7)),
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
            const SizedBox(height: 16),
            // Durum güncelleme butonları
            if (appointment.status == AppointmentStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _updateAppointmentStatus(
                          appointment.id!,
                          AppointmentStatus.confirmed,
                        );
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Onayla'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _updateAppointmentStatus(
                          appointment.id!,
                          AppointmentStatus.cancelled,
                        );
                      },
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('İptal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (appointment.status == AppointmentStatus.confirmed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _updateAppointmentStatus(
                      appointment.id!,
                      AppointmentStatus.completed,
                    );
                  },
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Tamamlandı Olarak İşaretle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
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

  Widget _buildWorkingHoursCard() {
    if (_businessData == null) {
      return const SizedBox.shrink();
    }

    final opening = _formatTime(_businessData!['opening_time'] as String?);
    final closing = _formatTime(_businessData!['closing_time'] as String?);
    final city = _businessData!['city'] as String?;
    final district = _businessData!['district'] as String?;

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Çalışma Saatleri',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$opening - $closing',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _isUpdatingHours ? null : _showWorkingHoursSheet,
                icon: Icon(Icons.edit, size: 18, color: Colors.white.withOpacity(0.8)),
                tooltip: 'Düzenle',
              ),
            ],
          ),
          if (_isUpdatingHours) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
          ],
          if ((city != null && city.isNotEmpty) ||
              (district != null && district.isNotEmpty)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [
                      if (district != null && district.isNotEmpty) district,
                      if (city != null && city.isNotEmpty) city,
                    ].join(', '),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceManagementSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Hizmet Yönetimi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showServiceForm(),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  'Hizmet Ekle',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isServicesLoading)
            const Center(child: CircularProgressIndicator())
          else if (_services.isEmpty)
            _buildServiceEmptyState()
          else
            Column(
              children: _services
                  .map((service) => _buildServiceCard(service))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    final isBusy =
        service.id != null && _entityActionLoading.contains(service.id!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.serviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: service.isActive
                        ? const Color(0xFF10B981).withOpacity(0.2)
                        : const Color(0xFFF59E0B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: service.isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: service.isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        service.isActive ? 'Aktif' : 'Pasif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: service.isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.payments,
                  label: 'Ücret',
                  value: _formatPrice(service.price),
                  color: const Color(0xFF6366F1),
                ),
                _buildInfoChip(
                  icon: Icons.timelapse,
                  label: 'Süre',
                  value: '${service.duration} dk',
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),
            if (service.description != null &&
                service.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  service.description!.trim(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBusy
                        ? null
                        : () => _showServiceForm(service: service),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : () => _deleteService(service),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Sil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (isBusy) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceEmptyState() {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.design_services, size: 64, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 20),
            const Text(
              'Henüz tanımlı hizmet yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hizmet ekleyerek müşterilerinize sunabilirsiniz',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeManagementSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Çalışan Yönetimi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _showEmployeeForm,
                icon: const Icon(Icons.person_add_alt_1, size: 18, color: Colors.white),
                label: const Text(
                  'Çalışan Ekle',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEmployeesLoading)
            const Center(child: CircularProgressIndicator())
          else if (_employees.isEmpty)
            _buildEmployeeEmptyState()
          else
            Column(
              children: _employees
                  .map((employee) => _buildEmployeeCard(employee))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    final isBusy =
        employee.id != null && _entityActionLoading.contains(employee.id!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      employee.name.isNotEmpty
                          ? employee.name[0].toUpperCase()
                          : 'E',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (employee.specialization != null &&
                          employee.specialization!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          employee.specialization!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: employee.isActive
                        ? const Color(0xFF10B981).withOpacity(0.2)
                        : const Color(0xFFF59E0B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: employee.isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: employee.isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        employee.isActive ? 'Aktif' : 'Pasif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: employee.isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (employee.email != null && employee.email!.isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.email_outlined,
                    label: 'E-posta',
                    value: employee.email!,
                    color: const Color(0xFF6366F1),
                  ),
                if (employee.phone != null && employee.phone!.isNotEmpty)
                  _buildInfoChip(
                    icon: Icons.phone,
                    label: 'Telefon',
                    value: employee.phone!,
                    color: const Color(0xFF10B981),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBusy
                        ? null
                        : () => _showEmployeeForm(employee: employee),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : () => _deleteEmployee(employee),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Sil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (isBusy) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeEmptyState() {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 20),
            const Text(
              'Henüz çalışan eklenmemiş',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ekip oluşturup aktif/pasif durumu yönetebilirsiniz',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursPickerTile({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeOfDayToLabel(time),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.schedule, color: Colors.deepPurple),
          ],
        ),
      ),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
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
                  color: color.withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: color.withOpacity(0.95),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

