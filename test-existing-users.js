// Test existing users and their password storage
async function testExistingUsers() {
    try {
        console.log('🔍 Checking existing users and their password storage...');
        
        // Get all users
        const response = await fetch('https://mk-attendance.vercel.app/api/admin/users');
        const data = await response.json();
        
        if (data.success && data.data) {
            console.log('👥 Found', data.data.length, 'users in database:');
            
            data.data.forEach((user, index) => {
                console.log(`\n👤 User ${index + 1}:`);
                console.log('  - ID:', user.id);
                console.log('  - Username:', user.username);
                console.log('  - Email:', user.email);
                console.log('  - Role:', user.role);
                console.log('  - Status:', user.status);
                console.log('  - Created:', user.created_at);
                
                // Test login for each user with common passwords
                testUserLogin(user.username, ['admin', 'password', '123456', user.username, 'password123']);
            });
        }
        
    } catch (error) {
        console.log('❌ Error:', error.message);
    }
}

async function testUserLogin(username, passwords) {
    console.log(`\n🔐 Testing login for user: ${username}`);
    
    for (const password of passwords) {
        try {
            const response = await fetch('https://mk-attendance.vercel.app/api/auth/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    username: username,
                    password: password
                })
            });
            
            const data = await response.json();
            
            if (response.ok && data.success) {
                console.log(`  ✅ SUCCESS with password: "${password}"`);
                return;
            } else {
                console.log(`  ❌ Failed with password: "${password}" - ${data.message}`);
            }
        } catch (error) {
            console.log(`  ❌ Error with password: "${password}" - ${error.message}`);
        }
    }
}

// Run the test
testExistingUsers();