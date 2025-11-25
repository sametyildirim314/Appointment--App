const pool = require('../config/database');
const bcrypt = require('bcryptjs');
const { generateToken } = require('../middleware/auth');

// Müşteri girişi
const customerLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'E-posta ve şifre gerekli'
      });
    }

    const [rows] = await pool.execute(
      'SELECT * FROM customers WHERE email = ?',
      [email]
    );

    if (rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'E-posta veya şifre hatalı'
      });
    }

    const customer = rows[0];
    const isValidPassword = await bcrypt.compare(password, customer.password);

    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: 'E-posta veya şifre hatalı'
      });
    }

    // Şifreyi response'dan çıkar
    delete customer.password;

    const token = generateToken({
      id: customer.id,
      email: customer.email,
      type: 'customer'
    });

    res.json({
      success: true,
      data: {
        customer: customer,
        token: token
      }
    });
  } catch (error) {
    console.error('Customer login error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Müşteri kaydı
const customerRegister = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    if (!name || !email || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Tüm alanlar gerekli'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Şifre en az 6 karakter olmalı'
      });
    }

    // E-posta kontrolü
    const [existing] = await pool.execute(
      'SELECT id FROM customers WHERE email = ?',
      [email]
    );

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Bu e-posta adresi zaten kullanılıyor'
      });
    }

    // Şifreyi hashle
    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await pool.execute(
      'INSERT INTO customers (name, email, phone, password) VALUES (?, ?, ?, ?)',
      [name, email, phone, hashedPassword]
    );

    const [newCustomer] = await pool.execute(
      'SELECT id, name, email, phone, created_at, updated_at FROM customers WHERE id = ?',
      [result.insertId]
    );

    const token = generateToken({
      id: newCustomer[0].id,
      email: newCustomer[0].email,
      type: 'customer'
    });

    res.status(201).json({
      success: true,
      data: {
        customer: newCustomer[0],
        token: token
      }
    });
  } catch (error) {
    console.error('Customer register error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// İşletme girişi
const businessLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'E-posta ve şifre gerekli'
      });
    }

    const [rows] = await pool.execute(
      'SELECT * FROM businesses WHERE email = ?',
      [email]
    );

    if (rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'E-posta veya şifre hatalı'
      });
    }

    const business = rows[0];
    const isValidPassword = await bcrypt.compare(password, business.password);

    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: 'E-posta veya şifre hatalı'
      });
    }

    delete business.password;

    const token = generateToken({
      id: business.id,
      email: business.email,
      type: 'business'
    });

    res.json({
      success: true,
      data: {
        business: business,
        token: token
      }
    });
  } catch (error) {
    console.error('Business login error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// İşletme kaydı
const businessRegister = async (req, res) => {
  try {
    const {
      business_name,
      owner_name,
      email,
      phone,
      password,
      address,
      city,
      district
    } = req.body;

    if (!business_name || !owner_name || !email || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Zorunlu alanlar eksik'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Şifre en az 6 karakter olmalı'
      });
    }

    // E-posta kontrolü
    const [existing] = await pool.execute(
      'SELECT id FROM businesses WHERE email = ?',
      [email]
    );

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Bu e-posta adresi zaten kullanılıyor'
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await pool.execute(
      `INSERT INTO businesses (business_name, owner_name, email, phone, password, address, city, district) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [business_name, owner_name, email, phone, hashedPassword, address || null, city || null, district || null]
    );

    const [newBusiness] = await pool.execute(
      `SELECT id, business_name, owner_name, email, phone, address, city, district, 
              opening_time, closing_time, is_active, created_at, updated_at 
       FROM businesses WHERE id = ?`,
      [result.insertId]
    );

    const token = generateToken({
      id: newBusiness[0].id,
      email: newBusiness[0].email,
      type: 'business'
    });

    res.status(201).json({
      success: true,
      data: {
        business: newBusiness[0],
        token: token
      }
    });
  } catch (error) {
    console.error('Business register error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

// Admin girişi
const adminLogin = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Kullanıcı adı ve şifre gerekli'
      });
    }

    const [rows] = await pool.execute(
      'SELECT * FROM admins WHERE username = ?',
      [username]
    );

    if (rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Kullanıcı adı veya şifre hatalı'
      });
    }

    const admin = rows[0];
    const isValidPassword = await bcrypt.compare(password, admin.password);

    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: 'Kullanıcı adı veya şifre hatalı'
      });
    }

    delete admin.password;

    const token = generateToken({
      id: admin.id,
      username: admin.username,
      type: 'admin'
    });

    res.json({
      success: true,
      data: {
        admin: admin,
        token: token
      }
    });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası'
    });
  }
};

module.exports = {
  customerLogin,
  customerRegister,
  businessLogin,
  businessRegister,
  adminLogin
};

