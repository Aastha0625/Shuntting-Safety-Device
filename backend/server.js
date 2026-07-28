const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const reportRoutes = require('./routes/reportRoutes');
const yardRoutes = require('./routes/yardRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json()); // Allows parsing of JSON request bodies
app.use('/uploads', express.static('uploads')); // Serve uploaded files

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/yards', yardRoutes);

// Base route for testing
app.get('/', (req, res) => {
  res.send('SafeShunt Backend API is running');
});

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
