// Debug attendance display issue - check what data is being returned
const https = require('https');

async function debugAttendanceDisplay() {
  console.log('🔍 DEBUGGING ATTENDANCE DISPLAY ISSUE');
  console.log('='.repeat(50));
  
  const today = new Date().toISOString().split('T')[0];
  console.log(`📅 Testing date: ${today}\n`);

  // Test 1: Check what attendance data exists for today
  console.log('=== TEST 1: Check Today\'s Attendance Data ===');
  try {
    const todayResult = await makeRequest('GET', `/api/attendance?date=${today}`);
    console.log('✅ API Response:', {
      success: todayResult.success,
      count: todayResult.count,
      message: todayResult.message
    });
    
    if (todayResult.data && todayResult.data.length > 0) {
      console.log('\n📊 Attendance Records Found:');
      todayResult.data.forEach((record, index) => {
        console.log(`${index + 1}. Student ID: ${record.student_id}`);
        console.log(`   Name: ${record.student_name}`);
        console.log(`   Status: ${record.status}`);
        console.log(`   Class: ${record.class_name}`);
        console.log(`   Date: ${record.date}`);
        console.log(`   Notes: ${record.notes || 'None'}`);
        console.log('   ---');
      });
    } else {
      console.log('❌ No attendance records found for today');
      console.log('💡 This means the mobile app won\'t show any status');
    }
  } catch (error) {
    console.log('❌ Error loading today\'s attendance:', error.message);
  }

  // Test 2: Check all attendance data (recent)
  console.log('\n=== TEST 2: Check Recent Attendance Data ===');
  try {
    const allResult = await makeRequest('GET', '/api/attendance');
    console.log('✅ Total Records:', allResult.count);
    
    if (allResult.data && allResult.data.length > 0) {
      console.log('\n📊 Recent Records (last 5):');
      allResult.data.slice(0, 5).forEach((record, index) => {
        console.log(`${index + 1}. Student: ${record.student_name} (ID: ${record.student_id})`);
        console.log(`   Status: ${record.status}`);
        console.log(`   Date: ${record.date}`);
        console.log(`   Class: ${record.class_name}`);
        console.log('   ---');
      });
      
      // Check date formats
      const uniqueDates = [...new Set(allResult.data.map(r => r.date))];
      console.log('\n📅 Date formats in database:');
      uniqueDates.slice(0, 5).forEach(date => {
        console.log(`   - ${date}`);
      });
    }
  } catch (error) {
    console.log('❌ Error loading all attendance:', error.message);
  }

  // Test 3: Check students data
  console.log('\n=== TEST 3: Check Students Data ===');
  try {
    const studentsResult = await makeRequest('GET', '/api/students?limit=5');
    console.log('✅ Students API Response:', {
      success: studentsResult.success,
      count: studentsResult.count
    });
    
    if (studentsResult.data && studentsResult.data.length > 0) {
      console.log('\n👥 Sample Students:');
      studentsResult.data.forEach((student, index) => {
        console.log(`${index + 1}. ID: ${student.id}, Name: ${student.full_name}, Class: ${student.class}`);
      });
    }
  } catch (error) {
    console.log('❌ Error loading students:', error.message);
  }

  // Test 4: Test specific class attendance
  console.log('\n=== TEST 4: Check Class-Specific Attendance ===');
  try {
    const classResult = await makeRequest('GET', '/api/attendance?class=Grade%201');
    console.log('✅ Grade 1 Attendance:', {
      success: classResult.success,
      count: classResult.count
    });
    
    if (classResult.count > 0) {
      console.log('📊 Grade 1 has attendance records');
    } else {
      console.log('❌ No attendance records for Grade 1');
    }
  } catch (error) {
    console.log('❌ Error loading class attendance:', error.message);
  }

  console.log('\n' + '='.repeat(50));
  console.log('🎯 DIAGNOSIS SUMMARY');
  console.log('='.repeat(50));
  console.log('If no attendance records are found for today:');
  console.log('1. ✅ API is working correctly');
  console.log('2. ❌ No attendance has been marked for today yet');
  console.log('3. 💡 Mobile app will show students without status (grey)');
  console.log('4. 🔧 Solution: Mark some attendance first, then check display');
}

function makeRequest(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'mk-attendance.vercel.app',
      port: 443,
      path: path,
      method: method,
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
          reject(new Error('Invalid JSON response: ' + responseData));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

debugAttendanceDisplay().catch(console.error);