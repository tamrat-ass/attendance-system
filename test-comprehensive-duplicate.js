// Comprehensive duplicate validation test
const testComprehensiveDuplicate = async () => {
  const baseUrl = 'https://mk-attendance.vercel.app/api/students';
  
  console.log('🧪 COMPREHENSIVE DUPLICATE VALIDATION TEST');
  console.log('==========================================');

  try {
    // Step 1: Get existing students
    console.log('\n📋 Step 1: Getting existing students...');
    const getResponse = await fetch(`${baseUrl}?limit=5`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    
    const existingData = await getResponse.json();
    console.log('Existing students count:', existingData.data?.length || 0);
    
    if (existingData.data && existingData.data.length > 0) {
      const existingStudent = existingData.data[0];
      console.log('First existing student:', {
        id: existingStudent.id,
        name: existingStudent.full_name,
        phone: existingStudent.phone,
        class: existingStudent.class,
        email: existingStudent.email
      });

      // Step 2: Test exact duplicate
      console.log('\n🔍 Step 2: Testing EXACT duplicate...');
      const exactDuplicate = {
        full_name: existingStudent.full_name,
        phone: existingStudent.phone,
        class: existingStudent.class,
        gender: existingStudent.gender || 'Male',
        email: 'test.exact@gmail.com' // Different email to avoid email conflicts
      };
      
      console.log('Test data:', exactDuplicate);
      
      const exactResponse = await fetch(baseUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(exactDuplicate)
      });
      
      const exactResult = await exactResponse.json();
      console.log('Status:', exactResponse.status);
      console.log('Response:', exactResult);
      
      if (exactResponse.status === 409) {
        console.log('✅ EXACT duplicate validation WORKING!');
      } else {
        console.log('❌ EXACT duplicate validation FAILED!');
      }

      // Step 3: Test name duplicate only
      console.log('\n🔍 Step 3: Testing NAME duplicate only...');
      const nameDuplicate = {
        full_name: existingStudent.full_name,
        phone: '0911111111', // Different phone
        class: 'Test Class',
        gender: 'Male',
        email: 'test.name@gmail.com'
      };
      
      const nameResponse = await fetch(baseUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(nameDuplicate)
      });
      
      const nameResult = await nameResponse.json();
      console.log('Status:', nameResponse.status);
      console.log('Response:', nameResult);
      
      if (nameResponse.status === 409) {
        console.log('✅ NAME duplicate validation WORKING!');
      } else {
        console.log('❌ NAME duplicate validation FAILED!');
      }

      // Step 4: Test phone duplicate only
      console.log('\n🔍 Step 4: Testing PHONE duplicate only...');
      const phoneDuplicate = {
        full_name: 'Different Test Name',
        phone: existingStudent.phone,
        class: 'Test Class',
        gender: 'Male',
        email: 'test.phone@gmail.com'
      };
      
      const phoneResponse = await fetch(baseUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(phoneDuplicate)
      });
      
      const phoneResult = await phoneResponse.json();
      console.log('Status:', phoneResponse.status);
      console.log('Response:', phoneResult);
      
      if (phoneResponse.status === 409) {
        console.log('✅ PHONE duplicate validation WORKING!');
      } else {
        console.log('❌ PHONE duplicate validation FAILED!');
      }

      // Step 5: Test completely new student (should succeed)
      console.log('\n🔍 Step 5: Testing NEW student (should succeed)...');
      const newStudent = {
        full_name: 'Test New Student ' + Date.now(),
        phone: '09' + Math.floor(Math.random() * 100000000).toString().padStart(8, '0'),
        class: 'Test Class',
        gender: 'Male',
        email: `test.new.${Date.now()}@gmail.com`
      };
      
      const newResponse = await fetch(baseUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newStudent)
      });
      
      const newResult = await newResponse.json();
      console.log('Status:', newResponse.status);
      console.log('Response:', newResult);
      
      if (newResponse.status === 200) {
        console.log('✅ NEW student creation WORKING!');
        console.log('🆔 New student ID:', newResult.student_id);
      } else {
        console.log('❌ NEW student creation FAILED!');
      }

    } else {
      console.log('❌ No existing students found to test with');
    }

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
  
  console.log('\n==========================================');
  console.log('🏁 COMPREHENSIVE TEST COMPLETE');
};

// Run the comprehensive test
testComprehensiveDuplicate();