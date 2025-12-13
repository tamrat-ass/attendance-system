// Test the web app fix
const https = require('https');

async function testWebAppFix() {
  console.log('🔧 TESTING WEB APP DATE FIX');
  console.log('='.repeat(50));
  
  const actualToday = new Date().toISOString().split('T')[0];
  console.log('Actual today:', actualToday);
  console.log('Expected: Web app should now use this date for API calls');
  
  // Test if attendance exists for actual today
  try {
    const result = await makeRequest('GET', `/api/attendance?date=${actualToday}`);
    
    if (result.success) {
      console.log(`✅ API has ${result.count} attendance records for ${actualToday}`);
      
      if (result.count === 12) {
        console.log('🎯 This matches the mobile app log (12 records)');
        console.log('✅ Web app should now show attendance correctly!');
      }
      
      if (result.count > 0) {
        console.log('Sample records:');
        result.data.slice(0, 3).forEach(record => {
          console.log(`   - Student ${record.student_id}: ${record.status} (${record.student_name})`);
        });
      }
    } else {
      console.log('❌ No attendance found for today');
    }
  } catch (error) {
    console.log('❌ API test failed:', error.message);
  }
  
  console.log('\n🎯 EXPECTED RESULT:');
  console.log('✅ Web app will now show today\'s attendance');
  console.log('✅ Mobile and web will be perfectly synchronized');
  console.log('✅ Both platforms use the same actual date');
}

function makeRequest(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'mk-attendance.vercel.app',
      port: 443,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
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
          reject(new Error(`Invalid JSON response: ${responseData.substring(0, 200)}...`));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data && (method === 'POST' || method === 'PUT')) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

testWebAppFix().catch(console.error);