// Check if passwords are hashed in the database
const https = require('https');

async function checkPasswords() {
  console.log('🔍 Checking Password Status in Database...\n');
  
  try {
    const result = await makeRequest('/api/users');
    
    if (result.success && result.data) {
      console.log('Users found:', result.data.length);
      console.log('');
      
      result.data.forEach(user => {
        // We can't see the password_hash from this endpoint, but we can see the user structure
        console.log(`User: ${user.username}`);
        console.log(`  - Full Name: ${user.full_name}`);
        console.log(`  - Role: ${user.role}`);
        console.log(`  - Status: ${user.status}`);
        console.log('');
      });
      
      console.log('⚠️  Note: password_hash is hidden in this endpoint for security');
      console.log('📝 You need to check the database directly in Neon console');
      console.log('');
      console.log('Run this query in Neon to check passwords:');
      console.log('SELECT username, LENGTH(password_hash) as hash_length FROM users;');
      
    } else {
      console.log('❌ Failed to get users:', result);
    }
  } catch (error) {
    console.log('❌ Error:', error.message);
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

checkPasswords().catch(console.error);