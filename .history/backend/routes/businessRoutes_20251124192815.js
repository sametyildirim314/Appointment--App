const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const {
  getBusinessServices,
  createService,
  updateService,
  deleteService,
  updateBusinessHours,
  getBusinessEmployees,
  createEmployee,
  updateEmployee,
  deleteEmployee
} = require('../controllers/businessController');

router.use(authenticateToken);

router.get('/services', getBusinessServices);
router.post('/services', createService);
router.put('/services/:id', updateService);
router.delete('/services/:id', deleteService);
router.get('/employees', getBusinessEmployees);
router.post('/employees', createEmployee);
router.put('/employees/:id', updateEmployee);
router.delete('/employees/:id', deleteEmployee);
router.put('/hours', updateBusinessHours);

module.exports = router;


