// Check what class the existing student is in and test with correct Ethiopian classes
const checkExistingStudent = async () => {
  const baseUrl = 'https://mk-attendance.vercel.app/api/students';
  
  try {
    console.log('🔍 Checking existing students...');
    
    // Get all students to see the existing data
    const response = await fetch(`${baseUrl}?search=ታምራት አሳፋ`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      }
    });

    const result = await response.json();
    console.log('Status:', response.status);
    console.log('Students found:', result.data);

    if (result.data && result.data.length > 0) {
      const student = result.data[0];
      console.log('\n📋 Existing student details:');
      console.log('ID:', student.id);
      console.log('Name:', student.full_name);
      console.log('Phone:', student.phone);
      console.log('Class:', student.class);
      console.log('Gender:', student.gender);
      console.log('Email:', student.email);
      
      // Test with the actual Ethiopian class names from your system
      const ethiopianClasses = [
        'አስተባባሪ',
        'ዋና ማእከል',
        'ምዕራፍ ማስተባበሪያ',
        'ምዕራብ ማስተባበሪያ',
        'ሰሜን ማስተባበሪያ',
        'ልዩ ልዩ',
        'ደቡብ ማስተባበሪያ',
        'አዲስ አበባ ማእከል'
      ];
      
      // Test with the first Ethiopian class
      console.log('\n🧪 Testing duplicate validation with Ethiopian class name...');
      const testStudent = {
        full_name: 'ታምራት አሳፋ',
        phone: '0937383844',
        class: 'አስተባባሪ', // Use actual Ethiopian class name
        gender: 'Male',
        email: 'test.duplicate@gmail.com'
      };
      
      console.log('Test data:', testStudent);
      
      const duplicateResponse = await fetch(baseUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(testStudent)
      });

      const duplicateResult = await duplicateResponse.json();
      console.log('\nDuplicate test status:', duplicateResponse.status);
      console.log('Duplicate test response:', duplicateResult);
      
      if (duplicateResponse.status === 409) {
        console.log('✅ Duplicate validation is working with Ethiopian class!');
      } else {
        console.log('❌ Duplicate validation is NOT working with Ethiopian class!');
        
        // Try with exact same name and phone but different email
        console.log('\n🔍 Testing with exact same name and phone...');
        const exactTest = {
          full_name: 'ታምራት አሳፋ',
          phone: '0937383844',
          class: student.class, // Use exact class from database
          gender: 'Male',
          email: 'different.email@gmail.com'
        };
        
        const exactResponse = await fetch(baseUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(exactTest)
        });

        const exactResult = await exactResponse.json();
        console.log('Exact test status:', exactResponse.status);
        console.log('Exact test response:', exactResult);
      }
    } else {
      console.log('No students found with that name');
    }

  } catch (error) {
    console.error('❌ Test failed:', error);
  }
};

// Run the check
checkExistingStudent();