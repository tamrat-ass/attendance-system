// Detailed test to understand the exact duplicate validation behavior
const testDetailedDuplicate = async () => {
  const baseUrl = 'https://mk-attendance.vercel.app/api/students';
  
  console.log('🔍 DETAILED DUPLICATE VALIDATION ANALYSIS');
  console.log('==========================================');

  try {
    // Get existing students first
    const getResponse = await fetch(`${baseUrl}?limit=3`);
    const getData = await getResponse.json();
    
    if (!getData.data || getData.data.length === 0) {
      console.log('❌ No existing students found');
      return;
    }
    
    const existing = getData.data[0];
    console.log('📋 Testing with existing student:');
    console.log('  ID:', existing.id);
    console.log('  Name:', existing.full_name);
    console.log('  Phone:', existing.phone);
    console.log('  Class:', existing.class);
    console.log('  Email:', existing.email);

    // Test scenarios
    const testCases = [
      {
        name: 'EXACT DUPLICATE (same name + phone)',
        data: {
          full_name: existing.full_name,
          phone: existing.phone,
          class: 'Different Class',
          gender: 'Male',
          email: 'test1@gmail.com'
        }
      },
      {
        name: 'NAME ONLY DUPLICATE',
        data: {
          full_name: existing.full_name,
          phone: '0922222222',
          class: 'Different Class',
          gender: 'Male',
          email: 'test2@gmail.com'
        }
      },
      {
        name: 'PHONE ONLY DUPLICATE',
        data: {
          full_name: 'Completely Different Name',
          phone: existing.phone,
          class: 'Different Class',
          gender: 'Male',
          email: 'test3@gmail.com'
        }
      },
      {
        name: 'NO DUPLICATE (new student)',
        data: {
          full_name: 'Brand New Student ' + Date.now(),
          phone: '09' + Math.floor(Math.random() * 100000000).toString().padStart(8, '0'),
          class: 'Test Class',
          gender: 'Male',
          email: `new${Date.now()}@gmail.com`
        }
      }
    ];

    for (let i = 0; i < testCases.length; i++) {
      const testCase = testCases[i];
      console.log(`\n🧪 Test ${i + 1}: ${testCase.name}`);
      console.log('Data:', JSON.stringify(testCase.data, null, 2));
      
      const response = await fetch(baseUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(testCase.data)
      });
      
      const result = await response.json();
      console.log('Status:', response.status);
      console.log('Response:', JSON.stringify(result, null, 2));
      
      // Analyze result
      if (response.status === 409) {
        console.log('✅ DUPLICATE DETECTED');
        console.log('Error type:', result.error);
        if (result.existingStudent) {
          console.log('Existing student ID:', result.existingStudent.id);
        }
      } else if (response.status === 200) {
        console.log('✅ STUDENT CREATED');
        console.log('New student ID:', result.student_id);
      } else {
        console.log('❌ UNEXPECTED RESPONSE');
      }
      
      // Wait a bit between requests
      await new Promise(resolve => setTimeout(resolve, 1000));
    }

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
  
  console.log('\n==========================================');
  console.log('🏁 DETAILED ANALYSIS COMPLETE');
};

// Run the detailed test
testDetailedDuplicate();