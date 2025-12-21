// Fix all user passwords properly
async function fixAllUserPasswords() {
    try {
        console.log('🔧 Fixing ALL user passwords...');
        
        // Get all users first
        const usersResponse = await fetch('https://mk-attendance.vercel.app/api/admin/users');
        const usersData = await usersResponse.json();
        
        if (usersData.success && usersData.data) {
            console.log('👥 Found users in database:');
            
            for (const user of usersData.data) {
                console.log(`\n👤 User: "${user.username}" (ID: ${user.id})`);
                console.log(`   Email: ${user.email}`);
                console.log(`   Role: ${user.role}`);
                console.log(`   Status: ${user.status}`);
                
                // Skip test users
                if (user.username.startsWith('test_user_')) {
                    console.log('   ⏭️  Skipping test user');
                    continue;
                }
                
                // Set password based on username
                let newPassword;
                if (user.username.trim() === 'admin') {
                    newPassword = 'admin123';
                } else if (user.username.trim() === 'manager') {
                    newPassword = 'manager123';
                } else if (user.username.trim() === 'yoni') {
                    newPassword = 'yoni123';
                } else if (user.username.trim() === 'yedne') {
                    newPassword = 'yedne123';
                } else {
                    // For any other user, use username + 123
                    newPassword = user.username.trim() + '123';
                }
                
                console.log(`   🔄 Setting password to: ${newPassword}`);
                
                // Update the user with new password
                const updateResponse = await fetch(`https://mk-attendance.vercel.app/api/admin/users/${user.id}`, {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        username: user.username,
                        email: user.email,
                        full_name: user.full_name,
                        password: newPassword, // This will be hashed by the API
                        role: user.role,
                        status: user.status,
                        can_manage_students: user.can_manage_students,
                        can_add_student: user.can_add_student,
                        can_update_student: user.can_update_student,
                        can_upload_students: user.can_upload_students,
                        can_delete_student: user.can_delete_student,
                        can_mark_attendance: user.can_mark_attendance,
                        can_view_reports: user.can_view_reports,
                        can_export_data: user.can_export_data,
                        can_manage_users: user.can_manage_users,
                        can_delete_user: user.can_delete_user,
                        can_manage_passwords: user.can_manage_passwords
                    })
                });
                
                const updateData = await updateResponse.json();
                
                if (updateResponse.ok && updateData.success) {
                    console.log(`   ✅ Password updated successfully`);
                    
                    // Test the new password
                    console.log(`   🔐 Testing login...`);
                    const testResponse = await fetch('https://mk-attendance.vercel.app/api/auth/login', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            username: user.username,
                            password: newPassword
                        })
                    });
                    
                    const testData = await testResponse.json();
                    
                    if (testResponse.ok && testData.success) {
                        console.log(`   ✅ LOGIN TEST SUCCESSFUL!`);
                    } else {
                        console.log(`   ❌ LOGIN TEST FAILED: ${testData.message}`);
                    }
                } else {
                    console.log(`   ❌ Password update failed: ${updateData.message}`);
                }
            }
        }
        
        console.log('\n🎉 Password fix process completed!');
        console.log('\n📋 FINAL USER CREDENTIALS:');
        
        // Get updated user list
        const finalResponse = await fetch('https://mk-attendance.vercel.app/api/admin/users');
        const finalData = await finalResponse.json();
        
        if (finalData.success && finalData.data) {
            finalData.data.forEach(user => {
                if (!user.username.startsWith('test_user_')) {
                    let password;
                    if (user.username.trim() === 'admin') password = 'admin123';
                    else if (user.username.trim() === 'manager') password = 'manager123';
                    else if (user.username.trim() === 'yoni') password = 'yoni123';
                    else if (user.username.trim() === 'yedne') password = 'yedne123';
                    else password = user.username.trim() + '123';
                    
                    console.log(`   Username: "${user.username}" → Password: "${password}"`);
                }
            });
        }
        
    } catch (error) {
        console.log('❌ Error:', error.message);
    }
}

// Run the fix
fixAllUserPasswords();