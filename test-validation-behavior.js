// Test to understand the exact validation behavior
const testValidationBehavior = async () => {
  const baseUrl = 'https://mk-attendance.vercel.app/api/students';
  
  // Create a completely unique student first
  const timestamp = Date.now();
  const uniqueStudent = {
    full_name: `Validation Test ${timestamp}`,
    phone: `0911${String(timestamp).slice(-6)}`,
    class: 'አስተባባሪ',
    gender: 'Male',
    email: `validation${timestamp}@gmail.com`
  };

  console.log('🧪 Step 1: Creating unique student...');
  console.log('📤 Student data:', uniqueStudent);

  try {
    // Step 1: Create unique student
    const response1 = await fetch(baseUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(uniqueStudent)
    });

    const result1 = await response1.json();
    console.log('✅ Step 1 Result:', response1.status, result1.message);

    if (response1.status !== 200 && response1.status !== 201) {
      console.log('❌ Failed to create unique student');
      return;
    }

    // Step 2: Test exact duplicate (same name + same phone)
    console.log('\n🧪 Step 2: Testing exact duplicate (same name + same phone)...');
    const response2 = await fetch(baseUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(uniqueStudent)
    });

    const result2 = await response2.json();
    console.log('📊 Step 2 Result:', response2.status);
    console.log('📊 Error type:', result2.error);
    console.log('📊 Message:', result2.message);

    // Step 3: Test same name, different phone
    console.log('\n🧪 Step 3: Testing same name, different phone...');
    const sameNameTest = {
      ...uniqueStudent,
      phone: `0912${String(timestamp).slice(-6)}`,
      email: `samename${timestamp}@gmail.com`
    };

    const response3 = await fetch(baseUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(sameNameTest)
    });

    const result3 = await response3.json();
    console.log('📊 Step 3 Result:', response3.status);
    console.log('📊 Error type:', result3.error);
    console.log('📊 Message:', result3.message);

    if (response3.status === 409) {
      console.log('✅ Name validation working!');
    } else {
      console.log('❌ Name validation NOT working - student created with ID:', result3.student_id);
    }

    // Step 4: Test different name, same phone as original
    console.log('\n🧪 Step 4: Testing different name, same phone as original...');
    const samePhoneTest = {
      ...uniqueStudent,
      full_name: `Different Name ${timestamp}`,
      email: `samephone${timestamp}@gmail.com`
    };

    const response4 = await fetch(baseUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(samePhoneTest)
    });

    const result4 = await response4.json();
    console.log('📊 Step 4 Result:', response4.status);
    console.log('📊 Error type:', result4.error);
    console.log('📊 Message:', result4.message);

    if (response4.status === 409) {
      console.log('✅ Phone validation working!');
    } else {
      console.log('❌ Phone validation NOT working - student created with ID:', result4.student_id);
    }

    // Summary
    console.log('\n📋 VALIDATION SUMMARY:');
    console.log('- Exact duplicate (name + phone):', response2.status === 409 ? '✅ BLOCKED' : '❌ ALLOWED');
    console.log('- Same name, different phone:', response3.status === 409 ? '✅ BLOCKED' : '❌ ALLOWED');
    console.log('- Different name, same phone:', response4.status === 409 ? '✅ BLOCKED' : '❌ ALLOWED');

    if (response2.status === 409 && response3.status !== 409 && response4.status !== 409) {
      console.log('\n🔍 DIAGNOSIS: API only validates exact duplicates (name AND phone together)');
      console.log('🔧 NEEDED: Separate validation for name OR phone duplicates');
    } else if (response2.status === 409 && response3.status === 409 && response4.status === 409) {
      console.log('\n✅ DIAGNOSIS: All validation working correctly!');
    } else {
      console.log('\n⚠️ DIAGNOSIS: Unexpected validation behavior');
    }

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
};

testValidationBehavior();