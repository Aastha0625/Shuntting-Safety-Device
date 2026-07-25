const db = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Helper for generating JWT token
const generateToken = (userId, employeeId) => {
  return jwt.sign(
    { id: userId, employeeId }, 
    process.env.JWT_SECRET || 'safeshunt_default_secret_key_change_me', 
    { expiresIn: '30d' }
  );
};

exports.register = async (req, res) => {
  const { fullName, employeeId, designation, password } = req.body;

  try {
    // 1. Check if user already exists
    const userExists = await db.query('SELECT * FROM users WHERE employee_id = $1', [employeeId]);
    if (userExists.rows.length > 0) {
      return res.status(400).json({ message: 'User with this Employee ID already exists' });
    }

    // 2. Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // 3. Insert user into DB
    const newUser = await db.query(
      'INSERT INTO users (full_name, employee_id, designation, password_hash) VALUES ($1, $2, $3, $4) RETURNING id, full_name, employee_id, designation',
      [fullName, employeeId, designation, passwordHash]
    );

    const user = newUser.rows[0];

    // 4. Return success and token
    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: user.id,
        fullName: user.full_name,
        employeeId: user.employee_id,
        designation: user.designation,
      },
      token: generateToken(user.id, user.employee_id)
    });

  } catch (error) {
    console.error('Error in register:', error);
    res.status(500).json({ message: 'Server error during registration' });
  }
};

exports.login = async (req, res) => {
  const { employeeId, password } = req.body;

  try {
    // 1. Find user by employee ID
    const userResult = await db.query('SELECT * FROM users WHERE employee_id = $1', [employeeId]);
    
    if (userResult.rows.length === 0) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const user = userResult.rows[0];

    // 2. Verify password
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // 3. Return user data and token
    res.status(200).json({
      message: 'Login successful',
      user: {
        id: user.id,
        fullName: user.full_name,
        employeeId: user.employee_id,
        designation: user.designation,
      },
      token: generateToken(user.id, user.employee_id)
    });

  } catch (error) {
    console.error('Error in login:', error);
    res.status(500).json({ message: 'Server error during login' });
  }
};
