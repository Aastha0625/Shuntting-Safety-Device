const express = require('express');
const router = express.Router();
const yardController = require('../controllers/yardController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

// All yard routes require authentication
router.use(verifyToken);

// @route   GET /api/yards
// @desc    List yards (filtered by role: Yard Admin sees only assigned yards)
// @access  Private (all authenticated users)
router.get('/', yardController.listYards);

// @route   GET /api/yards/:id
// @desc    Get single yard details
// @access  Private (all authenticated users, Yard Admin restricted to assigned yards)
router.get('/:id', yardController.getYard);

// @route   POST /api/yards
// @desc    Create a new yard
// @access  Private (Super Admin only)
router.post('/', requireRole('super_admin'), yardController.createYard);

// @route   PUT /api/yards/:id
// @desc    Update a yard
// @access  Private (Super Admin only)
router.put('/:id', requireRole('super_admin'), yardController.updateYard);

// @route   POST /api/yards/assign
// @desc    Assign a yard to a Yard Administrator user
// @access  Private (Super Admin only)
router.post('/assign', requireRole('super_admin'), yardController.assignYardToUser);

// @route   DELETE /api/yards/assign
// @desc    Remove yard assignment from a user
// @access  Private (Super Admin only)
router.delete('/assign', requireRole('super_admin'), yardController.removeYardAssignment);

module.exports = router;
