const express = require('express');
const router = express.Router();
const { registerDevice, getDevices, issueDevice, returnDevice, assignLine } = require('../controllers/deviceController');
const { verifyToken: protect } = require('../middleware/authMiddleware');

router.route('/')
  .get(protect, getDevices)
  .post(protect, registerDevice);

router.post('/issue', protect, issueDevice);
router.post('/return', protect, returnDevice);
router.put('/:id/assign-line', protect, assignLine);

module.exports = router;
