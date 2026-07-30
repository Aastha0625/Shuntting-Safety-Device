require('dotenv').config();
const { getDashboardSummary } = require('./controllers/dashboardController');
const { listUsers } = require('./controllers/authController');

const req = { user: { id: 'b7371d3c-9195-46ab-82cb-2f9cd7b9b1e9', role: 'super_admin' } };
const res = {
  status: function(code) { console.log('Status:', code); return this; },
  json: function(data) { console.log('JSON:', data); }
};

async function test() {
  try {
    console.log('Testing dashboard:');
    await getDashboardSummary(req, res);
  } catch(e) { console.error('Dash Error:', e); }

  try {
    console.log('Testing users:');
    await listUsers(req, res);
  } catch(e) { console.error('User Error:', e); }
  
  process.exit();
}
test();
