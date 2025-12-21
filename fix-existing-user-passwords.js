// Fix existing user passwords by rehashing them with bcrypt
async function fixExistingUserPasswords() {
    try {
        console.log('🔧 Fixing existing user passwords...');
        
        // Define default passwords for existing users
        const userPasswords = {
            'admin': 'admin123',
            'manager': 'manager123', 
            'yoni': 'yoni123',
            'yedne': 'yedne123'
        };
        
        console.log('📝 Will set these passwords:');
        Object.entries(userPasswords).forEach(([username, password]) => {
            console.log(`  - ${username}: ${password}`);
        });
        
        // Get all users first
        const usersResponse = await fetch('https://mk-attendance.vercel.app/api/admin/users');
        const usersData = await usersResponse.json();
        
        if (usersData.success && usersData.data) {
            for (const user of usersData.data) {
                // Skip the test user (already working)
                if (user.username.startsWith('test_user_')) {
                    console.log(`⏭️  Skipping test user: ${user.username}`);
                    continue;
                }
                
                const newPassword = userPasswords[user.username];
                if (newPassword) {
                    console.log(`\n🔄 Updating password for user: ${user.username}`);
                    
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
                        console.log(`  ✅ Password updated successfully`);
                        
                        // Test the new password
                        console.log(`  🔐 Testing new password...`);
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
                            console.log(`  ✅ Login test SUCCESSFUL!`);
                        } else {
                            console.log(`  ❌ Login test FAILED: ${testData.message}`);
                        }
                    } else {
                        console.log(`  ❌ Password update failed: ${updateData.message}`);
                    }
                } else {
                    console.log(`⏭️  No password defined for user: ${user.username}`);
                }
            }
        }
        
        console.log('\n🎉 Password fix process completed!');
        console.log('\n📋 Updated user credentials:');
        Object.entries(userPasswords).forEach(([username, password]) => {
            console.log(`  - Username: ${username}, Password: ${password}`);
        });
        
    } catch (error) {
        console.log('❌ Error:', error.message);
    }
}

// Run the fix
fixExistingUserPasswords();