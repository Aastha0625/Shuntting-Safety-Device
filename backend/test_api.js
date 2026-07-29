const axios = require('axios');

async function testBackend() {
  try {
    console.log('Testing IoT Telemetry Ingestion...');
    
    // Simulate a device pinging the IoT endpoint
    const res = await axios.post('http://localhost:5000/api/iot/telemetry', {
      device_id: '802f0a82-20c1-4b13-8889-4089ccf8e329', // We will just test if it returns a 500 (since device might not exist, but let's see how the DB responds. Actually, foreign key constraint will fail if device doesn't exist).
      distance: 3.5, // Less than 5m to trigger hazard
      battery: 85,
      speed: 2.1
    });

    console.log('IoT Response:', res.data);
  } catch (error) {
    if (error.response) {
       console.log('IoT Test Error Response:', error.response.data);
       // We expect a 500 foreign key error if device_id doesn't exist, which proves the route is wired up!
    } else {
       console.error('Test Error:', error.message);
    }
  }
}

testBackend();
