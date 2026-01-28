// Test script to verify duplicate validation with existing student
const testDuplicateValidation = async () => {
  const baseUrl = 'https://mk-attendance.vercel.app/api/students';
  
  // Test with existing student data from database
  const existingStudent = {
    full_name: 'ታምራት አሳፋ',
    phone: '0937383844',
    class: 'Grade 10',
    gender: 'Male',
    email: 'tamrat.asafa@gmail.com'
  };

  console.log('🧪 Testing duplicate validation with existing student...');
  console.log('📤 Existing student data:', existingStudent);

  try {
    // Attempt to add the existing student - should fail with duplicate error
    console.log('\n🔍 Attempting to add existing student (should fail):');
    const response = await fetch(baseUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(existingStudent)
    });

    const result = await response.json();
    console.log('Status:', response.status);
    console.log('Response:', result);

    if (response.status === 409) {
      console.log('✅ DUPLICATE VALIDATION WORKING!');
      console.log('🚫 Error message:', result.message);
      console.log('📋 Error type:', result.error);
      if (result.existingStudent) {
        console.log('👤 Existing student details:', result.existingStudent);
      }
    } else if (response.status === 200 || response.status === 201) {
      console.log('❌ DUPLICATE VALIDATION FAILED!');
      console.log('🚨 Student was added again despite existing in database!');
      console.log('🆔 New student ID:', result.student_id);
    } else {
      console.log('⚠️ Unexpected response:', result.message);
    }

    // Test with same name but different phone
    console.log('\n🔍 Testing same name, different phone:');
    const sameNameDifferentPhone = {
      ...existingStudent,
      phone: '0987654321'
    };

    const response2 = await fetch(baseUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(sameNameDifferentPhone)
    });

    const result2 = await response2.json();
    console.log('Status:', response2.status);
    console.log('Response:', result2);

    if (response2.status === 409) {
      console.log('✅ Name duplicate validation working!');
    } else {
      console.log('❌ Name duplicate validation failed!');
    }

    // Test with different name but same phone
    console.log('\n🔍 Testing different name, same phone:');
    const differentNameSamePhone = {
      ...existingStudent,
      full_name: 'Different Student Name'
    };

    const response3 = await fetch(baseUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(differentNameSamePhone)
    });

    const result3 = await response3.json();
    console.log('Status:', response3.status);
    console.log('Response:', result3);

    if (response3.status === 409) {
      console.log('✅ Phone duplicate validation working!');
    } else {
      console.log('❌ Phone duplicate validation failed!');
    }

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
};

// Run the test
testDuplicateValidation();