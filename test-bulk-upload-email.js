// Test script for bulk upload with email functionality
// Run this with: node test-bulk-upload-email.js

const testStudents = [
  {
    full_name: "Test Student 1",
    phone: "0912345678",
    gender: "Male",
    class: "Grade 10-A",
    email: "test1@gmail.com"
  },
  {
    full_name: "Test Student 2", 
    phone: "0923456789",
    gender: "Female",
    class: "Grade 10-B",
    email: "test2@gmail.com"
  }
];

async function testBulkUploadWithEmail() {
  try {
    console.log('🧪 Testing bulk upload with email...');
    
    const response = await fetch('http://localhost:3000/api/students/bulk-with-email', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ students: testStudents })
    });

    const result = await response.json();
    
    console.log('📊 Response Status:', response.status);
    console.log('📊 Response Data:', JSON.stringify(result, null, 2));
    
    if (response.ok) {
      console.log('✅ Test passed! Bulk upload with email works.');
      console.log(`📧 Emails sent: ${result.summary?.emailsSent || 0}`);
      console.log(`❌ Emails failed: ${result.summary?.emailsFailed || 0}`);
    } else {
      console.log('❌ Test failed:', result.message);
    }
    
  } catch (error) {
    console.error('🚨 Test error:', error.message);
  }
}

async function testBulkUploadWithoutEmail() {
  try {
    console.log('🧪 Testing bulk upload without email...');
    
    const response = await fetch('http://localhost:3000/api/students/bulk', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ students: testStudents })
    });

    const result = await response.json();
    
    console.log('📊 Response Status:', response.status);
    console.log('📊 Response Data:', JSON.stringify(result, null, 2));
    
    if (response.ok) {
      console.log('✅ Test passed! Regular bulk upload works.');
    } else {
      console.log('❌ Test failed:', result.message);
    }
    
  } catch (error) {
    console.error('🚨 Test error:', error.message);
  }
}

// Run tests
console.log('🚀 Starting bulk upload tests...\n');

// Test both endpoints
testBulkUploadWithEmail()
  .then(() => {
    console.log('\n' + '='.repeat(50) + '\n');
    return testBulkUploadWithoutEmail();
  })
  .then(() => {
    console.log('\n✅ All tests completed!');
  })
  .catch(error => {
    console.error('\n🚨 Test suite failed:', error);
  });