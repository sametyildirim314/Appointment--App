const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const {
  createAppointment,
  updateAppointment,
  getCustomerAppointments,
  getBusinessAppointments
} = require('../controllers/appointmentController');

// Tüm randevu route'ları authentication gerektirir
router.use(authenticateToken);

router.post('/create', createAppointment);
router.put('/update/:id', updateAppointment);
router.get('/customer/:id', getCustomerAppointments);
router.get('/business/:id', getBusinessAppointments);

module.exports = router;

