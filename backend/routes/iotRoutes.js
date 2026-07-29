const express = require('express');
const router = express.Router();
const { ingestTelemetry } = require('../controllers/iotController');

// Using basic route without JWT protection since hardware devices usually use API keys or TLS auth
router.post('/telemetry', ingestTelemetry);

module.exports = router;
