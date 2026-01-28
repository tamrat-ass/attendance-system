// Test script to verify attendance calculation logic
const testAttendanceCalculation = () => {
  console.log('Testing Attendance Calculation Logic\n');
  
  // Sample attendance data
  const attendanceRecords = [
    { status: 'present' },
    { status: 'present' },
    { status: 'late' },
    { status: 'permission' },
    { status: 'absent' },
    { status: 'present' },
    { status: 'late' },
    { status: 'absent' },
    { status: 'present' },
    { status: 'permission' }
  ];
  
  const totalRecords = attendanceRecords.length;
  const presentCount = attendanceRecords.filter(r => r.status === 'present').length;
  const lateCount = attendanceRecords.filter(r => r.status === 'late').length;
  const permissionCount = attendanceRecords.filter(r => r.status === 'permission').length;
  const absentCount = attendanceRecords.filter(r => r.status === 'absent').length;
  
  // Correct calculation (present + permission only)
  const correctAttendanceRate = Math.round(((presentCount + permissionCount) * 100.0) / totalRecords * 100) / 100;
  
  // Old incorrect calculation (present only)
  const oldAttendanceRate = Math.round((presentCount * 100.0) / totalRecords * 100) / 100;
  
  // Wrong calculation that included late (present + late + permission)
  const wrongAttendanceRate = Math.round(((presentCount + lateCount + permissionCount) * 100.0) / totalRecords * 100) / 100;
  
  console.log('Sample Data:');
  console.log(`Total Records: ${totalRecords}`);
  console.log(`Present: ${presentCount}`);
  console.log(`Late: ${lateCount}`);
  console.log(`Permission: ${permissionCount}`);
  console.log(`Absent: ${absentCount}`);
  console.log('');
  
  console.log('Calculation Results:');
  console.log(`✅ CORRECT Method (Present + Permission): ${correctAttendanceRate}%`);
  console.log(`❌ Old Method (Present Only): ${oldAttendanceRate}%`);
  console.log(`❌ Wrong Method (Present + Late + Permission): ${wrongAttendanceRate}%`);
  console.log('');
  
  console.log('✅ REQUIREMENT EXPLANATION:');
  console.log('- Permission counts as attendance (student has valid excuse)');
  console.log('- Present counts as attendance (student was there)');
  console.log('- Late does NOT count as attendance (student was late)');
  console.log('- Absent does NOT count as attendance (student missed class)');
  console.log('');
  console.log('✅ CORRECT FORMULA: Attendance % = (Present + Permission) / Total × 100');
};

// Test with API endpoint
const testAPIEndpoint = async () => {
  try {
    console.log('\nTesting API Endpoint...');
    
    // Get current date for testing
    const today = new Date().toISOString().split('T')[0];
    const lastWeek = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    
    const response = await fetch(`http://localhost:3000/api/admin/reports?type=summary&start_date=${lastWeek}&end_date=${today}`);
    const data = await response.json();
    
    if (data.success) {
      console.log('API Response Success!');
      console.log('Overall Stats:', data.data.overall);
      console.log('Classes:', data.data.classes?.slice(0, 2)); // Show first 2 classes
    } else {
      console.log('API Error:', data.message);
    }
  } catch (error) {
    console.log('API Test Error:', error.message);
    console.log('Note: Make sure the development server is running');
  }
};

// Run tests
testAttendanceCalculation();

// Uncomment to test API (requires server running)
// testAPIEndpoint();