const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');

router.get('/generate/pdf', reportController.generatePDF);
router.get('/generate/excel', reportController.generateExcel);

module.exports = router;
