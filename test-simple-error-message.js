// Test the updated simple error messages
const testSimpleErrorMessage = async () => {
  const baseUrl = 'https://mk-attendance.vercel.app/api/students';
  
  console.log('🧪 TESTING SIMPLE ERROR MESSAGES');
  console.log('=================================');

  try {
    // Get existing student
    const getResponse = await fetch(`${baseUrl}?limit=1`);
    const getData = await getResponse.json();
    
    if (!getData.data || getData.data.length === 0) {
      console.log('❌ No existing students found');
      return;
    }
    
    const existing = getData.data[0];
    console.log('📋 Testing with existing student:', existing.full_name, '|', existing.phone);

    // Test duplicate name
    console.log('\n🧪 Test 1: Duplicate Name');
    const nameTest = {
      full_name: existing.full_name,
      phone: '0911111111',
      class: 'Test Class',
      gender: 'Male',
      email: 'test@gmail.com'
    };
    
    const nameResponse = await fetch(baseUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(nameTest)
    });
    
    const nameResult = await nameResponse.json();
    console.log('Status:', nameResponse.status);
    console.log('Message:', nameResult.message);
    
    if (nameResult.message === 'Student already exists') {
      console.log('✅ SIMPLE ERROR MESSAGE WORKING!');
    } else {
      console.log('❌ Error message not updated yet:', nameResult.message);
    }

    // Test duplicate phone
    console.log('\n🧪 Test 2: Duplicate Phone');
    const phoneTest = {
      full_name: 'Different Name',
      phone: existing.phone,
      class: 'Test Class',
      gender: 'Male',
      email: 'test2@gmail.com'
    };
    
    const phoneResponse = await fetch(baseUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(phoneTest)
    });
    
    const phoneResult = await phoneResponse.json();
    console.log('Status:', phoneResponse.status);
    console.log('Message:', phoneResult.message);
    
    if (phoneResult.message === 'Student already exists') {
      console.log('✅ SIMPLE ERROR MESSAGE WORKING!');
    } else {
      console.log('❌ Error message not updated yet:', phoneResult.message);
    }

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
  
  console.log('\n=================================');
  console.log('🏁 SIMPLE ERROR MESSAGE TEST COMPLETE');
};

// Run the test
testSimpleErrorMessage();