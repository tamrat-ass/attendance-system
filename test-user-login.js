// Test login with newly created user
async function testUserLogin() {
    try {
        console.log('🔐 Testing login with newly created user...');
        
        // First, let's get the latest user from the database
        console.log('👥 Getting users from database...');
        const usersResponse = await fetch('https://mk-attendance.vercel.app/api/admin/users');
        const usersData = await usersResponse.json();
        
        if (usersData.success && usersData.data.length > 0) {
            // Find the most recent test user
            const testUser = usersData.data.find(user => user.username.startsWith('test_user_'));
            
            if (testUser) {
                console.log('👤 Found test user:', testUser.username);
                console.log('📧 Email:', testUser.email);
                console.log('🔍 Status:', testUser.status);
                console.log('🔍 Role:', testUser.role);
                
                // Try to login with this user
                console.log('\n🔐 Attempting login...');
                const loginResponse = await fetch('https://mk-attendance.vercel.app/api/auth/login', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        username: testUser.username,
                        password: 'password123'  // This was the password we used when creating
                    })
                });
                
                const loginData = await loginResponse.json();
                
                console.log('📊 Login Response Status:', loginResponse.status);
                console.log('📊 Login Response:', JSON.stringify(loginData, null, 2));
                
                if (loginResponse.ok && loginData.success) {
                    console.log('✅ LOGIN SUCCESSFUL!');
                    console.log('👤 Logged in user:', loginData.user.username);
                    console.log('🔍 User permissions:', {
                        can_manage_students: loginData.user.can_manage_students,
                        can_add_student: loginData.user.can_add_student,
                        can_update_student: loginData.user.can_update_student,
                        can_mark_attendance: loginData.user.can_mark_attendance
                    });
                } else {
                    console.log('❌ LOGIN FAILED!');
                    console.log('Error:', loginData.message);
                    
                    // Let's check what might be wrong
                    if (loginData.message && loginData.message.includes('password')) {
                        console.log('🔍 Password issue detected');
                    } else if (loginData.message && loginData.message.includes('username')) {
                        console.log('🔍 Username issue detected');
                    } else if (loginData.message && loginData.message.includes('inactive')) {
                        console.log('🔍 User status issue - user might be inactive');
                    }
                }
            } else {
                console.log('❌ No test user found in database');
            }
        } else {
            console.log('❌ Failed to get users from database');
        }
        
    } catch (error) {
        console.log('❌ Network Error:', error.message);
    }
}

// Run the test
testUserLogin();