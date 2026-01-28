// Test to check which version of the API is actually deployed
const testApiVersion = async () => {
  const baseUrl = 'https://mk-attendance.vercel.app/api/students';
  
  console.log('🔍 Testing API Version and Duplicate Logic');
  console.log('==========================================');

  try {
    // Test 1: Try to create a student with invalid phone (should fail validation)
    console.log('\n📋 Test 1: Invalid phone validation...');
    const invalidPhoneTest = {
      full_name: 'Test Invalid Phone',
      phone: '123456789', // Invalid phone (not starting with 09)
      class: 'Test Class',
      gender: 'Male',
      email: 'test.invalid@gmail.com'
    };
    
    const invalidResponse = await fetch(baseUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(invalidPhoneTest)
    });
    
    const invalidResult = await invalidResponse.json();
    console.log('Status:', invalidResponse.status);
    console.log('Response:', invalidResult);
    
    if (invalidResponse.status === 400 && invalidResult.message.includes('09')) {
      console.log('✅ Phone validation working - API is updated');
    } else {
      console.log('❌ Phone validation not working - API might be old version');
    }

    // Test 2: Try to create a student with invalid email (should fail validation)
    console.log('\n📋 Test 2: Invalid email validation...');
    const invalidEmailTest = {
      full_name: 'Test Invalid Email',
      phone: '0911111111',
      class: 'Test Class',
      gender: 'Male',
      email: 'test@yahoo.com' // Invalid email (not @gmail.com)
    };
    
    const emailResponse = await fetch(baseUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(invalidEmailTest)
    });
    
    const emailResult = await emailResponse.json();
    console.log('Status:', emailResponse.status);
    console.log('Response:', emailResult);
    
    if (emailResponse.status === 400 && emailResult.message.includes('gmail.com')) {
      console.log('✅ Email validation working - API is updated');
    } else {
      console.log('❌ Email validation not working - API might be old version');
    }

    // Test 3: Check if the API returns version info in console logs
    console.log('\n📋 Test 3: Testing duplicate with existing student to check logs...');
    
    // First get an existing student
    const getResponse = await fetch(`${baseUrl}?limit=1`);
    const getData = await getResponse.json();
    
    if (getData.data && getData.data.length > 0) {
      const existing = getData.data[0];
      console.log('Found existing student:', existing.full_name, existing.phone);
      
      // Try to create duplicate
      const duplicateTest = {
        full_name: existing.full_name,
        phone: existing.phone,
        class: 'Test Class',
        gender: 'Male',
        email: 'test.duplicate.check@gmail.com'
      };
      
      const dupResponse = await fetch(baseUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(duplicateTest)
      });
      
      const dupResult = await dupResponse.json();
      console.log('Duplicate test status:', dupResponse.status);
      console.log('Duplicate test response:', dupResult);
      
      if (dupResponse.status === 409) {
        console.log('✅ Duplicate validation working!');
        if (dupResult.error === 'DUPLICATE_NAME' || dupResult.error === 'DUPLICATE_PHONE') {
          console.log('✅ Enhanced duplicate validation (v2026010113) is active!');
        }
      } else {
        console.log('❌ Duplicate validation not working - old API version deployed?');
      }
    }

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
  
  console.log('\n==========================================');
  console.log('🏁 API VERSION TEST COMPLETE');
};

// Run the test
testApiVersion();