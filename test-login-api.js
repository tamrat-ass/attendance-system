// Test the login API to diagnose the issue
const https = require('https');

async function testLoginAPI() {
  console.log('🔍 Testing Login API...\n');
  
  const testCredentials = [
    { username: 'admin', password: 'password123' },
    { username: 'manager', password: 'manager123' },
    { username: 'user1', password: 'user123' }
  ];

  for (const creds of testCredentials) {
    console.log(`Testing: ${creds.username} / ${creds.password}`);
    
    try {
      const result = await makeLoginRequest(creds.username, creds.password);
      console.log(`✅ ${creds.username}: ${result.success ? 'SUCCESS' : 'FAILED'}`);
      if (!result.success) {
        console.log(`   Error: ${result.message}`);
      }
    } catch (error) {
      console.log(`❌ ${creds.username}: NETWORK ERROR - ${error.message}`);
    }
    console.log('');
  }
}

function makeLoginRequest(username, password) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({ username, password });
    
    const options = {
      hostname: 'mk-attendance.vercel.app',
      port: 443,
      path: '/api/auth/login',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
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
          reject(new Error('Invalid JSON response'));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(data);
    req.end();
  });
}

// Run the test
testLoginAPI().catch(console.error);