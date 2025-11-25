const pool = require('../config/database');

// Tüm işletmeleri getir
const getBusinesses = async (req, res) => {
  try {
    const { include_inactive } = req.query;

    const query = include_inactive === '1'
        ? `SELECT id, business_name, owner_name, email, phone, address, city, district, 
                 description, opening_time, closing_time, is_active, created_at, updated_at
            FROM businesses 
            ORDER BY business_name`
        : `SELECT id, business_name, owner_name, email, phone, address, city, district, 
                 description, opening_time, closing_time, is_active, created_at, updated_at
            FROM businesses 
            WHERE is_active = 1
            ORDER BY business_name`;

    const [businesses] = await pool.execute(query);

    res.json({
      success: true,
      data: {
        businesses: businesses
      }
    });
  } catch (error) {
    console.error('Get businesses error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// İşletme hizmetlerini getir
const getServices = async (req, res) => {
  try {
    const { business_id } = req.query;

    if (!business_id) {
      return res.status(400).json({
        success: false,
        message: 'business_id gerekli'
      });
    }

    const [services] = await pool.execute(
      `SELECT id, business_id, service_name, description, duration, price, is_active, created_at, updated_at
       FROM services 
       WHERE business_id = ? AND (is_active = 1 OR is_active IS NULL)
       ORDER BY service_name`,
      [business_id]
    );

    res.json({
      success: true,
      data: {
        services: services
      }
    });
  } catch (error) {
    console.error('Get services error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// İşletme çalışanlarını getir
const getEmployees = async (req, res) => {
  try {
    const { business_id } = req.query;

    if (!business_id) {
      return res.status(400).json({
        success: false,
        message: 'business_id gerekli'
      });
    }

    const [employees] = await pool.execute(
      `SELECT id, business_id, name, email, phone, specialization, is_active, created_at, updated_at
       FROM employees 
       WHERE business_id = ? AND (is_active = 1 OR is_active IS NULL)
       ORDER BY name`,
      [business_id]
    );

    res.json({
      success: true,
      data: {
        employees: employees
      }
    });
  } catch (error) {
    console.error('Get employees error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Tüm müşterileri getir (Admin için)
const getCustomers = async (req, res) => {
  try {
    const [customers] = await pool.execute(
      `SELECT id, name, email, phone, created_at, updated_at
       FROM customers 
       ORDER BY created_at DESC`
    );

    res.json({
      success: true,
      data: {
        customers: customers
      }
    });
  } catch (error) {
    console.error('Get customers error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Tüm randevuları getir (Admin için)
const getAllAppointments = async (req, res) => {
  try {
    const [appointments] = await pool.execute(
      `SELECT a.*, 
              c.name as customer_name,
              c.phone as customer_phone,
              b.business_name,
              e.name as employee_name,
              s.service_name,
              s.price as service_price,
              s.duration as service_duration
       FROM appointments a
       LEFT JOIN customers c ON a.customer_id = c.id
       LEFT JOIN businesses b ON a.business_id = b.id
       LEFT JOIN employees e ON a.employee_id = e.id
       LEFT JOIN services s ON a.service_id = s.id
       ORDER BY a.appointment_date DESC, a.appointment_time DESC
       LIMIT 100`
    );

    res.json({
      success: true,
      data: {
        appointments: appointments
      }
    });
  } catch (error) {
    console.error('Get all appointments error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Admin istatistikleri
const getAdminStats = async (req, res) => {
  try {
    // Toplam işletme sayısı
    const [businessCount] = await pool.execute(
      'SELECT COUNT(*) as count FROM businesses WHERE is_active = 1'
    );

    // Toplam müşteri sayısı
    const [customerCount] = await pool.execute(
      'SELECT COUNT(*) as count FROM customers'
    );

    // Toplam randevu sayısı
    const [appointmentCount] = await pool.execute(
      'SELECT COUNT(*) as count FROM appointments'
    );

    // Bugünkü randevular
    const [todayAppointments] = await pool.execute(
      `SELECT COUNT(*) as count FROM appointments 
       WHERE appointment_date = CURDATE()`
    );

    // Bekleyen randevular
    const [pendingAppointments] = await pool.execute(
      `SELECT COUNT(*) as count FROM appointments 
       WHERE status = 'pending'`
    );

    res.json({
      success: true,
      data: {
        totalBusinesses: businessCount[0].count,
        totalCustomers: customerCount[0].count,
        totalAppointments: appointmentCount[0].count,
        todayAppointments: todayAppointments[0].count,
        pendingAppointments: pendingAppointments[0].count
      }
    });
  } catch (error) {
    console.error('Get admin stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Çalışan çalışma saatlerini getir
const getEmployeeSchedule = async (req, res) => {
  try {
    const { employee_id } = req.query;

    if (!employee_id) {
      return res.status(400).json({
        success: false,
        message: 'employee_id gerekli'
      });
    }

    const [schedules] = await pool.execute(
      `SELECT es.*, e.name as employee_name
       FROM employee_schedules es
       JOIN employees e ON es.employee_id = e.id
       WHERE es.employee_id = ? AND es.is_available = 1
       ORDER BY es.day_of_week`,
      [employee_id]
    );

    res.json({
      success: true,
      data: {
        schedules: schedules
      }
    });
  } catch (error) {
    console.error('Get employee schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Admin - işletme durumunu güncelle
const updateBusinessStatus = async (req, res) => {
  try {
    if (!req.user || req.user.type !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Bu işlem için yetkiniz yok'
      });
    }

    const { id } = req.params;
    const { is_active } = req.body;

    if (typeof is_active === 'undefined') {
      return res.status(400).json({
        success: false,
        message: 'is_active alanı gerekli'
      });
    }

    const isActiveValue = is_active ? 1 : 0;

    const [result] = await pool.execute(
      `UPDATE businesses 
       SET is_active = ?, updated_at = NOW()
       WHERE id = ?`,
      [isActiveValue, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'İşletme bulunamadı'
      });
    }

    const [businessRows] = await pool.execute(
      `SELECT id, business_name, owner_name, email, phone, address, city, district, 
              description, opening_time, closing_time, is_active, created_at, updated_at
       FROM businesses
       WHERE id = ?`,
      [id]
    );

    res.json({
      success: true,
      data: {
        business: businessRows[0]
      }
    });
  } catch (error) {
    console.error('Update business status error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

module.exports = {
  getBusinesses,
  getServices,
  getEmployees,
  getCustomers,
  getAllAppointments,
  getAdminStats,
  getEmployeeSchedule,
  updateBusinessStatus
};

