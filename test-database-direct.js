// Test database connection directly
const https = require('https');

async function testDatabase() {
  console.log('🔍 Testing Database Connection...\n');
  
  try {
    // Test a simple endpoint that should show us what's in the database
    const result = await makeRequest('/api/users');
    console.log('Users endpoint result:', JSON.stringify(result, null, 2));
  } catch (error) {
    console.log('❌ Database test failed:', error.message);
  }
}

function makeRequest(path) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'mk-attendance.vercel.app',
      port: 443,
      path: path,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const result = JSON.parse(responseData);
          resolve(result);
        } catch (e) {
          resolve({ raw: responseData, status: res.statusCode });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.end();
  });
}

// Run the test
testDatabase().catch(console.error);