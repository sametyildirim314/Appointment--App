const pool = require('../config/database');

// Randevu oluştur
const createAppointment = async (req, res) => {
  try {
    const { customer_id, business_id, employee_id, service_id, appointment_date, appointment_time, notes } = req.body;

    if (!customer_id || !business_id || !service_id || !appointment_date || !appointment_time) {
      return res.status(400).json({
        success: false,
        message: 'Zorunlu alanlar eksik'
      });
    }

    // Aynı saatte başka randevu var mı kontrol et
    const [existing] = await pool.execute(
      `SELECT id FROM appointments 
       WHERE business_id = ? AND employee_id = ? AND appointment_date = ? AND appointment_time = ? 
       AND status != 'cancelled'`,
      [business_id, employee_id || null, appointment_date, appointment_time]
    );

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Bu saatte zaten bir randevu var'
      });
    }

    const [result] = await pool.execute(
      `INSERT INTO appointments (customer_id, business_id, employee_id, service_id, appointment_date, appointment_time, notes, status) 
       VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')`,
      [customer_id, business_id, employee_id || null, service_id, appointment_date, appointment_time, notes || null]
    );

    const [newAppointment] = await pool.execute(
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
       WHERE a.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      data: {
        appointment: newAppointment[0]
      }
    });
  } catch (error) {
    console.error('Create appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Randevu güncelle
const updateAppointment = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, notes, appointment_date, appointment_time, employee_id } = req.body;

    const updateFields = [];
    const updateValues = [];

    if (status) {
      updateFields.push('status = ?');
      updateValues.push(status);
    }
    if (notes !== undefined) {
      updateFields.push('notes = ?');
      updateValues.push(notes);
    }
    if (appointment_date) {
      updateFields.push('appointment_date = ?');
      updateValues.push(appointment_date);
    }
    if (appointment_time) {
      updateFields.push('appointment_time = ?');
      updateValues.push(appointment_time);
    }
    if (employee_id !== undefined) {
      updateFields.push('employee_id = ?');
      updateValues.push(employee_id);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Güncellenecek alan yok'
      });
    }

    updateFields.push('updated_at = NOW()');
    updateValues.push(id);

    await pool.execute(
      `UPDATE appointments SET ${updateFields.join(', ')} WHERE id = ?`,
      updateValues
    );

    const [updated] = await pool.execute(
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
       WHERE a.id = ?`,
      [id]
    );

    res.json({
      success: true,
      data: {
        appointment: updated[0]
      }
    });
  } catch (error) {
    console.error('Update appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Müşteri randevularını getir
const getCustomerAppointments = async (req, res) => {
  try {
    const { id } = req.params;

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
       WHERE a.customer_id = ?
       ORDER BY a.appointment_date DESC, a.appointment_time DESC`,
      [id]
    );

    res.json({
      success: true,
      data: {
        appointments: appointments
      }
    });
  } catch (error) {
    console.error('Get customer appointments error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// İşletme randevularını getir
const getBusinessAppointments = async (req, res) => {
  try {
    const { id } = req.params;

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
       WHERE a.business_id = ?
       ORDER BY a.appointment_date DESC, a.appointment_time DESC`,
      [id]
    );

    res.json({
      success: true,
      data: {
        appointments: appointments
      }
    });
  } catch (error) {
    console.error('Get business appointments error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

module.exports = {
  createAppointment,
  updateAppointment,
  getCustomerAppointments,
  getBusinessAppointments
};

