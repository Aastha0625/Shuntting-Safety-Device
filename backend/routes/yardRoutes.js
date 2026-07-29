const express = require('express');
const router = express.Router();
const { createYard, getYards, addYardLine, getYardLines } = require('../controllers/yardController');
const { verifyToken: protect } = require('../middleware/authMiddleware');

router.route('/')
  .get(protect, getYards)
  .post(protect, createYard);

router.route('/:yardId/lines')
  .get(protect, getYardLines)
  .post(protect, addYardLine);

module.exports = router;
