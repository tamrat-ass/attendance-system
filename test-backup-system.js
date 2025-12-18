// Test script for backup system
// Run with: node test-backup-system.js

const BASE_URL = process.env.VERCEL_URL || 'http://localhost:3000';
const API_KEY = process.env.BACKUP_API_KEY || 'test-key';

async function testBackupSystem() {
  console.log('🧪 Testing Backup System...\n');

  // Test 1: Check backup setup status
  console.log('1️⃣ Testing backup setup status...');
  try {
    const response = await fetch(`${BASE_URL}/api/backup/setup`);
    const result = await response.json();
    
    if (result.success) {
      console.log('✅ Setup status check passed');
      console.log(`   Spreadsheet ID: ${result.spreadsheetId}`);
      console.log(`   Sheets: ${result.sheets?.map(s => s.title).join(', ')}`);
      console.log(`   Is Setup: ${result.isSetup ? 'Yes' : 'No'}`);
    } else {
      console.log('❌ Setup status check failed:', result.message);
    }
  } catch (error) {
    console.log('❌ Setup status check error:', error.message);
  }
  console.log('');

  // Test 2: Setup Google Sheets (if needed)
  console.log('2️⃣ Testing Google Sheets setup...');
  try {
    const response = await fetch(`${BASE_URL}/api/backup/setup`, {
      method: 'POST'
    });
    const result = await response.json();
    
    if (result.success) {
      console.log('✅ Google Sheets setup passed');
      console.log(`   Created/verified sheets: ${result.sheets?.join(', ')}`);
    } else {
      console.log('❌ Google Sheets setup failed:', result.message);
    }
  } catch (error) {
    console.log('❌ Google Sheets setup error:', error.message);
  }
  console.log('');

  // Test 3: Check backup status/logs
  console.log('3️⃣ Testing backup status check...');
  try {
    const response = await fetch(`${BASE_URL}/api/backup?action=status`);
    const result = await response.json();
    
    if (result.success) {
      console.log('✅ Backup status check passed');
      console.log(`   Recent backups: ${result.recentBackups?.length || 0}`);
      if (result.recentBackups?.length > 0) {
        const latest = result.recentBackups[0];
        console.log(`   Latest backup: ${latest.status} (${latest.created_at})`);
        console.log(`   Students: ${latest.students_count}, Attendance: ${latest.attendance_count}`);
      }
    } else {
      console.log('❌ Backup status check failed:', result.message);
    }
  } catch (error) {
    console.log('❌ Backup status check error:', error.message);
  }
  console.log('');

  // Test 4: Manual backup trigger
  console.log('4️⃣ Testing manual backup trigger...');
  try {
    const response = await fetch(`${BASE_URL}/api/backup/manual`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    const result = await response.json();
    
    if (result.success) {
      console.log('✅ Manual backup trigger passed');
      console.log(`   Backup result: ${result.result?.success ? 'Success' : 'Failed'}`);
      if (result.result?.data) {
        console.log(`   Students backed up: ${result.result.data.studentsCount}`);
        console.log(`   Attendance backed up: ${result.result.data.attendanceCount}`);
        console.log(`   Duration: ${result.result.data.duration}`);
      }
    } else {
      console.log('❌ Manual backup trigger failed:', result.message);
    }
  } catch (error) {
    console.log('❌ Manual backup trigger error:', error.message);
  }
  console.log('');

  // Test 5: Direct backup API call
  console.log('5️⃣ Testing direct backup API...');
  try {
    const response = await fetch(`${BASE_URL}/api/backup`, {
      method: 'POST'
    });
    const result = await response.json();
    
    if (result.success) {
      console.log('✅ Direct backup API passed');
      console.log(`   Students backed up: ${result.data?.studentsCount}`);
      console.log(`   Attendance backed up: ${result.data?.attendanceCount}`);
      console.log(`   Duration: ${result.data?.duration}`);
      console.log(`   Timestamp: ${result.data?.timestamp}`);
    } else {
      console.log('❌ Direct backup API failed:', result.message);
    }
  } catch (error) {
    console.log('❌ Direct backup API error:', error.message);
  }
  console.log('');

  console.log('🏁 Backup system testing completed!');
}

// Environment check
function checkEnvironment() {
  console.log('🔧 Environment Check:');
  console.log(`   BASE_URL: ${BASE_URL}`);
  console.log(`   API_KEY: ${API_KEY ? 'Set' : 'Not set'}`);
  console.log(`   NODE_ENV: ${process.env.NODE_ENV || 'development'}`);
  console.log('');

  const requiredEnvVars = [
    'DATABASE_URL',
    'GOOGLE_SPREADSHEET_ID',
    'GOOGLE_SERVICE_ACCOUNT_KEY'
  ];

  const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);
  
  if (missingVars.length > 0) {
    console.log('⚠️  Missing environment variables:');
    missingVars.forEach(varName => {
      console.log(`   - ${varName}`);
    });
    console.log('');
  } else {
    console.log('✅ All required environment variables are set\n');
  }
}

// Run tests
async function main() {
  console.log('🚀 Backup System Test Suite\n');
  
  checkEnvironment();
  await testBackupSystem();
}

main().catch(error => {
  console.error('🚨 Test suite failed:', error);
  process.exit(1);
});