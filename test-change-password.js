// Test change password functionality
async function testChangePassword() {
    try {
        console.log('🔧 Testing change password functionality...');
        
        // First, let's create a test user to change password for
        const timestamp = Date.now();
        const testUser = {
            username: `pwtest_${timestamp}`,
            email: `pwtest${timestamp}@example.com`,
            full_name: 'Password Test User',
            password: 'oldpassword123',
            role: 'user',
            status: 'active',
            can_manage_students: true,
            can_add_student: true,
            can_update_student: true,
            can_upload_students: false,
            can_delete_student: false,
            can_mark_attendance: true,
            can_view_reports: false,
            can_export_data: false,
            can_manage_users: false,
            can_delete_user: false,
            can_manage_passwords: false
        };
        
        console.log('📝 Step 1: Creating test user...');
        console.log(`   Username: ${testUser.username}`);
        console.log(`   Initial Password: ${testUser.password}`);
        
        // Create the user
        const createResponse = await fetch('https://mk-attendance.vercel.app/api/admin/users', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(testUser)
        });
        
        const createData = await createResponse.json();
        
        if (!createResponse.ok || !createData.success) {
            console.log('❌ Failed to create test user:', createData.message);
            return;
        }
        
        console.log('✅ Test user created successfully');
        
        // Step 2: Login to get user ID
        console.log('\n🔐 Step 2: Logging in to get user details...');
        const loginResponse = await fetch('https://mk-attendance.vercel.app/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                username: testUser.username,
                password: testUser.password
            })
        });
        
        const loginData = await loginResponse.json();
        
        if (!loginResponse.ok || !loginData.success) {
            console.log('❌ Failed to login with test user:', loginData.message);
            return;
        }
        
        console.log('✅ Login successful');
        console.log('   User ID:', loginData.user.id);
        
        const userId = loginData.user.id;
        const newPassword = 'newpassword123';
        
        // Step 3: Change password
        console.log('\n🔄 Step 3: Changing password...');
        console.log(`   Current Password: ${testUser.password}`);
        console.log(`   New Password: ${newPassword}`);
        
        const changeResponse = await fetch('https://mk-attendance.vercel.app/api/auth/change-password', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                userId: userId,
                currentPassword: testUser.password,
                newPassword: newPassword
            })
        });
        
        const changeData = await changeResponse.json();
        
        console.log('📊 Change Password Response:');
        console.log('   Status:', changeResponse.status);
        console.log('   Response:', changeData);
        
        if (changeResponse.ok && changeData.success) {
            console.log('✅ Password changed successfully!');
            
            // Step 4: Test login with new password
            console.log('\n🔐 Step 4: Testing login with new password...');
            
            const newLoginResponse = await fetch('https://mk-attendance.vercel.app/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    username: testUser.username,
                    password: newPassword
                })
            });
            
            const newLoginData = await newLoginResponse.json();
            
            if (newLoginResponse.ok && newLoginData.success) {
                console.log('✅ Login with new password SUCCESSFUL!');
                
                // Step 5: Verify old password doesn't work
                console.log('\n🔐 Step 5: Verifying old password no longer works...');
                
                const oldLoginResponse = await fetch('https://mk-attendance.vercel.app/api/auth/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        username: testUser.username,
                        password: testUser.password // old password
                    })
                });
                
                const oldLoginData = await oldLoginResponse.json();
                
                if (!oldLoginResponse.ok || !oldLoginData.success) {
                    console.log('✅ Old password correctly rejected!');
                    
                    console.log('\n🎉 CHANGE PASSWORD TEST: COMPLETE SUCCESS!');
                    console.log('✅ Password change works');
                    console.log('✅ New password allows login');
                    console.log('✅ Old password is rejected');
                    
                    console.log('\n📋 TEST USER CREDENTIALS (Updated):');
                    console.log(`   Username: ${testUser.username}`);
                    console.log(`   New Password: ${newPassword}`);
                    
                } else {
                    console.log('❌ Old password still works - this is a problem!');
                }
            } else {
                console.log('❌ Login with new password failed:', newLoginData.message);
            }
        } else {
            console.log('❌ Password change failed:', changeData.error || changeData.message);
        }
        
    } catch (error) {
        console.log('❌ Error:', error.message);
    }
}

// Run the test
testChangePassword();