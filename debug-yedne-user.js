// Debug the yedne user issue specifically
async function debugYedneUser() {
    try {
        console.log('🔍 Debugging yedne user issue...');
        
        // Get all users and check yedne specifically
        const response = await fetch('https://mk-attendance.vercel.app/api/admin/users');
        const data = await response.json();
        
        if (data.success && data.data) {
            console.log('👥 All users in database:');
            
            data.data.forEach((user, index) => {
                console.log(`\n👤 User ${index + 1}:`);
                console.log('  - ID:', user.id);
                console.log('  - Username:', `"${user.username}"`);
                console.log('  - Username length:', user.username.length);
                console.log('  - Email:', user.email);
                console.log('  - Status:', user.status);
                console.log('  - Role:', user.role);
                
                // Check if this is the yedne user
                if (user.username.toLowerCase().includes('yedne') || user.username === 'yedne') {
                    console.log('  🎯 THIS IS THE YEDNE USER!');
                    console.log('  - Exact username bytes:', Array.from(user.username).map(c => c.charCodeAt(0)));
                    
                    // Test login with exact username
                    testLoginWithExactUsername(user.username);
                }
            });
            
            // Also test with different variations of yedne
            console.log('\n🧪 Testing different yedne variations...');
            const variations = ['yedne', 'Yedne', 'YEDNE', 'yedne ', ' yedne', 'yedne\n', 'yedne\r'];
            
            for (const variation of variations) {
                console.log(`\nTesting variation: "${variation}" (length: ${variation.length})`);
                await testLoginVariation(variation, 'yedne123');
            }
        }
        
    } catch (error) {
        console.log('❌ Error:', error.message);
    }
}

async function testLoginWithExactUsername(exactUsername) {
    console.log(`\n🔐 Testing login with exact username: "${exactUsername}"`);
    
    try {
        const response = await fetch('https://mk-attendance.vercel.app/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                username: exactUsername,
                password: 'yedne123'
            })
        });
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            console.log(`  ✅ SUCCESS with exact username!`);
        } else {
            console.log(`  ❌ FAILED with exact username: ${data.message}`);
        }
    } catch (error) {
        console.log(`  ❌ Network error: ${error.message}`);
    }
}

async function testLoginVariation(username, password) {
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
            console.log(`  ✅ SUCCESS!`);
        } else {
            console.log(`  ❌ FAILED: ${data.message}`);
        }
    } catch (error) {
        console.log(`  ❌ Network error: ${error.message}`);
    }
}

// Run the debug
debugYedneUser();