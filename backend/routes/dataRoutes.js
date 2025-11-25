const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const {
  getBusinesses,
  getServices,
  getEmployees,
  getCustomers,
  getAllAppointments,
  getAdminStats,
  getEmployeeSchedule,
  updateBusinessStatus
} = require('../controllers/dataController');

// Public routes
router.get('/businesses', getBusinesses);
router.get('/services', getServices);
router.get('/employees', getEmployees);
router.get('/employee/schedule', getEmployeeSchedule);
router.put('/businesses/:id/status', authenticateToken, updateBusinessStatus);

// Admin routes (authentication required)
router.get('/customers', authenticateToken, getCustomers);
router.get('/appointments/all', authenticateToken, getAllAppointments);
router.get('/admin/stats', authenticateToken, getAdminStats);

module.exports = router;

