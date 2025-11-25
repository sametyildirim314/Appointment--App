const pool = require('../config/database');

const ensureBusinessUser = (req, res) => {
  if (!req.user || req.user.type !== 'business') {
    res.status(403).json({
      success: false,
      message: 'Bu işlem için işletme girişi yapmalısınız'
    });
    return null;
  }
  return req.user.id;
};

const normalizeBoolean = (value, defaultValue = true) => {
  if (typeof value === 'undefined' || value === null) {
    return defaultValue ? 1 : 0;
  }
  if (typeof value === 'boolean') {
    return value ? 1 : 0;
  }
  if (typeof value === 'number') {
    return value !== 0 ? 1 : 0;
  }
  if (typeof value === 'string') {
    const val = value.toLowerCase();
    return ['1', 'true', 'yes', 'aktif', 'active'].includes(val) ? 1 : 0;
  }
  return defaultValue ? 1 : 0;
};

const normalizeTimeValue = (value) => {
  if (!value || typeof value !== 'string') {
    return null;
  }

  const parts = value.split(':');
  if (parts.length < 2) {
    return null;
  }

  const hour = parts[0].padStart(2, '0');
  const minute = parts[1].padStart(2, '0');
  const second = parts.length > 2 ? parts[2].padStart(2, '0') : '00';
  return `${hour}:${minute}:${second}`;
};

const getBusinessServices = async (req, res) => {
const getBusinessEmployees = async (req, res) => {
  try {
    const businessId = ensureBusinessUser(req, res);
    if (!businessId) return;

    const [employees] = await pool.execute(
      `SELECT id, business_id, name, email, phone, specialization, is_active, created_at, updated_at
       FROM employees
       WHERE business_id = ?
       ORDER BY name`,
      [businessId]
    );

    res.json({
      success: true,
      data: { employees }
    });
  } catch (error) {
    console.error('Get business employees error:', error);
    res.status(500).json({
      success: false,
      message: 'Çalışanlar alınırken bir hata oluştu'
    });
  }
};

const createEmployee = async (req, res) => {
  try {
    const businessId = ensureBusinessUser(req, res);
    if (!businessId) return;

    const { name, email, phone, specialization, is_active } = req.body;

    if (!name || !email || !phone) {
      return res.status(400).json({
        success: false,
        message: 'name, email ve phone alanları zorunludur'
      });
    }

    const [result] = await pool.execute(
      `INSERT INTO employees (business_id, name, email, phone, specialization, is_active)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        businessId,
        name.trim(),
        email.trim(),
        phone.trim(),
        specialization || null,
        normalizeBoolean(is_active)
      ]
    );

    const [employeeRows] = await pool.execute(
      `SELECT id, business_id, name, email, phone, specialization, is_active, created_at, updated_at
       FROM employees
       WHERE id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      data: { employee: employeeRows[0] }
    });
  } catch (error) {
    console.error('Create employee error:', error);
    res.status(500).json({
      success: false,
      message: 'Çalışan oluşturulurken bir hata oluştu'
    });
  }
};

const updateEmployee = async (req, res) => {
  try {
    const businessId = ensureBusinessUser(req, res);
    if (!businessId) return;

    const employeeId = parseInt(req.params.id, 10);
    if (Number.isNaN(employeeId)) {
      return res.status(400).json({
        success: false,
        message: 'Geçersiz çalışan ID'
      });
    }

    const [existing] = await pool.execute(
      'SELECT business_id FROM employees WHERE id = ?',
      [employeeId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Çalışan bulunamadı'
      });
    }

    if (existing[0].business_id !== businessId) {
      return res.status(403).json({
        success: false,
        message: 'Bu çalışan üzerinde işlem yapma yetkiniz yok'
      });
    }

    const { name, email, phone, specialization, is_active } = req.body;
    const updates = [];
    const values = [];

    if (typeof name !== 'undefined') {
      if (!name.trim()) {
        return res.status(400).json({
          success: false,
          message: 'İsim boş olamaz'
        });
      }
      updates.push('name = ?');
      values.push(name.trim());
    }

    if (typeof email !== 'undefined') {
      if (!email.trim()) {
        return res.status(400).json({
          success: false,
          message: 'E-posta boş olamaz'
        });
      }
      updates.push('email = ?');
      values.push(email.trim());
    }

    if (typeof phone !== 'undefined') {
      if (!phone.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Telefon boş olamaz'
        });
      }
      updates.push('phone = ?');
      values.push(phone.trim());
    }

    if (typeof specialization !== 'undefined') {
      updates.push('specialization = ?');
      values.push(specialization || null);
    }

    if (typeof is_active !== 'undefined') {
      updates.push('is_active = ?');
      values.push(normalizeBoolean(is_active));
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Güncellenecek alan bulunamadı'
      });
    }

    updates.push('updated_at = NOW()');
    const query = `UPDATE employees SET ${updates.join(', ')} WHERE id = ? AND business_id = ?`;
    values.push(employeeId, businessId);

    await pool.execute(query, values);

    const [employeeRows] = await pool.execute(
      `SELECT id, business_id, name, email, phone, specialization, is_active, created_at, updated_at
       FROM employees
       WHERE id = ?`,
      [employeeId]
    );

    res.json({
      success: true,
      data: { employee: employeeRows[0] }
    });
  } catch (error) {
    console.error('Update employee error:', error);
    res.status(500).json({
      success: false,
      message: 'Çalışan güncellenirken bir hata oluştu'
    });
  }
};

const deleteEmployee = async (req, res) => {
  try {
    const businessId = ensureBusinessUser(req, res);
    if (!businessId) return;

    const employeeId = parseInt(req.params.id, 10);
    if (Number.isNaN(employeeId)) {
      return res.status(400).json({
        success: false,
        message: 'Geçersiz çalışan ID'
      });
    }

    const [result] = await pool.execute(
      'DELETE FROM employees WHERE id = ? AND business_id = ?',
      [employeeId, businessId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Çalışan bulunamadı veya silme yetkiniz yok'
      });
    }

    res.json({
      success: true,
      message: 'Çalışan başarıyla silindi'
    });
  } catch (error) {
    console.error('Delete employee error:', error);
    res.status(500).json({
      success: false,
      message: 'Çalışan silinirken bir hata oluştu'
    });
  }
};
  try {
    const businessId = ensureBusinessUser(req, res);
    if (!businessId) return;

    const [services] = await pool.execute(
      `SELECT id, business_id, service_name, description, duration, price, is_active, created_at, updated_at
       FROM services
       WHERE business_id = ?
       ORDER BY service_name`,
      [businessId]
    );

    res.json({
      success: true,
      data: { services }
    });
  } catch (error) {
    console.error('Get business services error:', error);
    res.status(500).json({
      success: false,
      message: 'Hizmetler alınırken bir hata oluştu'
    });
  }
};

const createService = async (req, res) => {
  try {
    const businessId = ensureBusinessUser(req, res);
    if (!businessId) return;

    const { service_name, description, duration, price, is_active } = req.body;

    if (!service_name || typeof duration === 'undefined' || typeof price === 'undefined') {
      return res.status(400).json({
        success: false,
        message: 'service_name, duration ve price alanları zorunludur'
      });
    }

    const durationValue = parseInt(duration, 10);
    const priceValue = parseFloat(price);

    if (Number.isNaN(durationValue) || durationValue <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Süre değeri geçerli bir sayı olmalıdır'
      });
    }

    if (Number.isNaN(priceValue) || priceValue < 0) {
      return res.status(400).json({
        success: false,
        message: 'Ücret geçerli bir sayı olmalıdır'
      });
    }

    const [result] = await pool.execute(
      `INSERT INTO services (business_id, service_name, description, duration, price, is_active)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        businessId,
        service_name.trim(),
        description || null,
        durationValue,
        priceValue,
        normalizeBoolean(is_active)
      ]
    );

    const [serviceRows] = await pool.execute(
      `SELECT id, business_id, service_name, description, duration, price, is_active, created_at, updated_at
       FROM services
       WHERE id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      data: { service: serviceRows[0] }
    });
  } catch (error) {
    console.error('Create service error:', error);
    res.status(500).json({
      success: false,
      message: 'Hizmet oluşturulurken bir hata oluştu'
    });
  }
};

const updateService = async (req, res) => {
  try {
    const businessId = ensureBusinessUser(req, res);
    if (!businessId) return;

    const serviceId = parseInt(req.params.id, 10);
    if (Number.isNaN(serviceId)) {
      return res.status(400).json({
        success: false,
        message: 'Geçersiz hizmet ID'
      });
    }

    const [existing] = await pool.execute(
      'SELECT business_id FROM services WHERE id = ?',
      [serviceId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Hizmet bulunamadı'
      });
    }

    if (existing[0].business_id !== businessId) {
      return res.status(403).json({
        success: false,
        message: 'Bu hizmet üzerinde işlem yapma yetkiniz yok'
      });
    }

    const { service_name, description, duration, price, is_active } = req.body;
    const updates = [];
    const values = [];

    if (typeof service_name !== 'undefined') {
      updates.push('service_name = ?');
      values.push(service_name.trim());
    }

    if (typeof description !== 'undefined') {
      updates.push('description = ?');
      values.push(description || null);
    }

    if (typeof duration !== 'undefined') {
      const durationValue = parseInt(duration, 10);
      if (Number.isNaN(durationValue) || durationValue <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Süre değeri geçerli bir sayı olmalıdır'
        });
      }
      updates.push('duration = ?');
      values.push(durationValue);
    }

    if (typeof price !== 'undefined') {
      const priceValue = parseFloat(price);
      if (Number.isNaN(priceValue) || priceValue < 0) {
        return res.status(400).json({
          success: false,
          message: 'Ücret geçerli bir sayı olmalıdır'
        });
      }
      updates.push('price = ?');
      values.push(priceValue);
    }

    if (typeof is_active !== 'undefined') {
      updates.push('is_active = ?');
      values.push(normalizeBoolean(is_active));
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Güncellenecek alan bulunamadı'
      });
    }

    updates.push('updated_at = NOW()');

    const query = `UPDATE services SET ${updates.join(', ')} WHERE id = ? AND business_id = ?`;
    values.push(serviceId, businessId);

    await pool.execute(query, values);

    const [serviceRows] = await pool.execute(
      `SELECT id, business_id, service_name, description, duration, price, is_active, created_at, updated_at
       FROM services
       WHERE id = ?`,
      [serviceId]
    );

    res.json({
      success: true,
      data: { service: serviceRows[0] }
    });
  } catch (error) {
    console.error('Update service error:', error);
    res.status(500).json({
      success: false,
      message: 'Hizmet güncellenirken bir hata oluştu'
    });
  }
};

const deleteService = async (req, res) => {
  try {
    const businessId = ensureBusinessUser(req, res);
    if (!businessId) return;

    const serviceId = parseInt(req.params.id, 10);
    if (Number.isNaN(serviceId)) {
      return res.status(400).json({
        success: false,
        message: 'Geçersiz hizmet ID'
      });
    }

    const [result] = await pool.execute(
      'DELETE FROM services WHERE id = ? AND business_id = ?',
      [serviceId, businessId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Hizmet bulunamadı veya silme yetkiniz yok'
      });
    }

    res.json({
      success: true,
      message: 'Hizmet başarıyla silindi'
    });
  } catch (error) {
    console.error('Delete service error:', error);
    res.status(500).json({
      success: false,
      message: 'Hizmet silinirken bir hata oluştu'
    });
  }
};

const updateBusinessHours = async (req, res) => {
  try {
    const businessId = ensureBusinessUser(req, res);
    if (!businessId) return;

    const { opening_time, closing_time } = req.body;

    if (!opening_time || !closing_time) {
      return res.status(400).json({
        success: false,
        message: 'opening_time ve closing_time alanları zorunludur'
      });
    }

    const normalizedOpening = normalizeTimeValue(opening_time);
    const normalizedClosing = normalizeTimeValue(closing_time);

    if (!normalizedOpening || !normalizedClosing) {
      return res.status(400).json({
        success: false,
        message: 'Saat formatı HH:mm veya HH:mm:ss olmalıdır'
      });
    }

    const [result] = await pool.execute(
      `UPDATE businesses
       SET opening_time = ?, closing_time = ?, updated_at = NOW()
       WHERE id = ?`,
      [normalizedOpening, normalizedClosing, businessId]
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
      [businessId]
    );

    res.json({
      success: true,
      data: { business: businessRows[0] }
    });
  } catch (error) {
    console.error('Update business hours error:', error);
    res.status(500).json({
      success: false,
      message: 'Çalışma saatleri güncellenirken bir hata oluştu'
    });
  }
};

module.exports = {
  getBusinessServices,
  createService,
  updateService,
  deleteService,
  updateBusinessHours,
  getBusinessEmployees,
  createEmployee,
  updateEmployee,
  deleteEmployee
};


