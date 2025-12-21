// Test user creation with can_update_student permission
async function testUserCreation() {
    try {
        console.log('🧪 Testing user creation with can_update_student...');
        
        // Test data for creating a new user
        const testUserData = {
            username: 'test_user_' + Date.now(),
            email: 'test' + Date.now() + '@example.com',
            full_name: 'Test User',
            password: 'password123',
            role: 'user',
            status: 'active',
            can_manage_students: true,
            can_add_student: true,
            can_update_student: true,  // This should now work!
            can_upload_students: false,
            can_delete_student: false,
            can_mark_attendance: true,
            can_view_reports: false,
            can_export_data: false,
            can_manage_users: false,
            can_delete_user: false,
            can_manage_passwords: false
        };
        
        console.log('📝 Sending user data:', testUserData);
        
        const response = await fetch('https://mk-attendance.vercel.app/api/admin/users', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(testUserData)
        });
        
        const data = await response.json();
        
        console.log('📊 Response Status:', response.status);
        console.log('📊 Response Data:', JSON.stringify(data, null, 2));
        
        if (response.ok && data.success) {
            console.log('✅ SUCCESS! User created successfully');
            console.log('👤 New user ID:', data.data?.id);
            
            // Verify the user was created with correct permissions
            console.log('\n🔍 Verifying user was created correctly...');
            const verifyResponse = await fetch('https://mk-attendance.vercel.app/api/admin/users');
            const verifyData = await verifyResponse.json();
            
            if (verifyData.success) {
                const newUser = verifyData.data.find(user => user.username === testUserData.username);
                if (newUser) {
                    console.log('✅ User found in database');
                    console.log('🔍 can_update_student value:', newUser.can_update_student);
                    console.log('🔍 All permissions:', {
                        can_manage_students: newUser.can_manage_students,
                        can_add_student: newUser.can_add_student,
                        can_update_student: newUser.can_update_student,
                        can_upload_students: newUser.can_upload_students,
                        can_delete_student: newUser.can_delete_student
                    });
                } else {
                    console.log('❌ User not found in database');
                }
            }
        } else {
            console.log('❌ FAILED! User creation failed');
            console.log('Error message:', data.message);
        }
        
    } catch (error) {
        console.log('❌ Network Error:', error.message);
    }
}

// Run the test
testUserCreation();