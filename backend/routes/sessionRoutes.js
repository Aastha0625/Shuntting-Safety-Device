const express = require('express');
const router = express.Router();
const { getSessions } = require('../controllers/sessionController');
const { verifyToken: protect } = require('../middleware/authMiddleware');

router.get('/', protect, getSessions);

module.exports = router;
