const express = require('express');
const router = express.Router();
const {
  customerLogin,
  customerRegister,
  businessLogin,
  businessRegister,
  adminLogin
} = require('../controllers/authController');

// Müşteri routes
router.post('/customer/login', customerLogin);
router.post('/customer/register', customerRegister);

// İşletme routes
router.post('/business/login', businessLogin);
router.post('/business/register', businessRegister);

// Admin routes
router.post('/admin/login', adminLogin);

module.exports = router;

