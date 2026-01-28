// Test current validation with detailed logging
const testCurrentValidation = async () => {
  const baseUrl = 'https://mk-attendance.vercel.app/api/students';
  
  // Test with a unique name first to ensure API is working
  const uniqueStudent = {
    full_name: `Test Student ${Date.now()}`,
    phone: `0912${String(Date.now()).slice(-6)}`,
    class: 'አስተባባሪ',
    gender: 'Male',
    email: `test${Date.now()}@gmail.com`
  };

  console.log('🧪 Testing with unique student first...');
  console.log('📤 Unique student data:', uniqueStudent);

  try {
    // First, create a unique student (should succeed)
    const response1 = await fetch(baseUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(uniqueStudent)
    });

    const result1 = await response1.json();
    console.log('\n✅ Unique student creation:');
    console.log('Status:', response1.status);
    console.log('Response:', result1);

    if (response1.status === 200 || response1.status === 201) {
      console.log('✅ Unique student created successfully');
      
      // Now try to create the same student again (should fail with 409)
      console.log('\n🔍 Attempting to create duplicate (should fail):');
      const response2 = await fetch(baseUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(uniqueStudent)
      });

      const result2 = await response2.json();
      console.log('Status:', response2.status);
      console.log('Response:', result2);

      if (response2.status === 409) {
        console.log('✅ DUPLICATE VALIDATION WORKING CORRECTLY!');
        console.log('🚫 Error type:', result2.error);
        console.log('🚫 Error message:', result2.message);
      } else {
        console.log('❌ DUPLICATE VALIDATION FAILED!');
        console.log('🚨 Duplicate student was created!');
      }

      // Test with same name, different phone
      console.log('\n🔍 Testing same name, different phone:');
      const sameNameTest = {
        ...uniqueStudent,
        phone: `0913${String(Date.now()).slice(-6)}`,
        email: `different${Date.now()}@gmail.com`
      };

      const response3 = await fetch(baseUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(sameNameTest)
      });

      const result3 = await response3.json();
      console.log('Status:', response3.status);
      console.log('Response:', result3);

      if (response3.status === 409) {
        console.log('✅ Name duplicate validation working!');
        console.log('🚫 Error type:', result3.error);
      } else {
        console.log('❌ Name duplicate validation failed!');
      }

      // Test with different name, same phone
      console.log('\n🔍 Testing different name, same phone:');
      const samePhoneTest = {
        ...uniqueStudent,
        full_name: `Different Name ${Date.now()}`,
        email: `another${Date.now()}@gmail.com`
      };

      const response4 = await fetch(baseUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(samePhoneTest)
      });

      const result4 = await response4.json();
      console.log('Status:', response4.status);
      console.log('Response:', result4);

      if (response4.status === 409) {
        console.log('✅ Phone duplicate validation working!');
        console.log('🚫 Error type:', result4.error);
      } else {
        console.log('❌ Phone duplicate validation failed!');
      }

    } else {
      console.log('❌ Failed to create unique student:', result1.message);
    }

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
};

// Run the test
testCurrentValidation();