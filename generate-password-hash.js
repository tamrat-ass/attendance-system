// Generate bcrypt password hashes for the attendance system
const bcrypt = require('bcryptjs');

async function generateHashes() {
  const passwords = [
    'password123',
    'teacher123', 
    'manager123',
    'user123',
    'admin123'
  ];

  console.log('=== BCRYPT PASSWORD HASHES ===\n');
  
  for (const password of passwords) {
    const hash = await bcrypt.hash(password, 10);
    console.log(`Password: ${password}`);
    console.log(`Hash: ${hash}`);
    console.log('---');
  }

  console.log('\n=== SQL UPDATE STATEMENTS ===\n');
  
  const adminHash = await bcrypt.hash('password123', 10);
  const teacherHash = await bcrypt.hash('teacher123', 10);
  const managerHash = await bcrypt.hash('manager123', 10);
  const userHash = await bcrypt.hash('user123', 10);

  console.log(`-- Update admin password`);
  console.log(`UPDATE users SET password_hash = '${adminHash}' WHERE username = 'admin';`);
  console.log();
  
  console.log(`-- Update teacher password`);
  console.log(`UPDATE users SET password_hash = '${teacherHash}' WHERE username = 'teacher1';`);
  console.log();
  
  console.log(`-- Update manager password`);
  console.log(`UPDATE users SET password_hash = '${managerHash}' WHERE username = 'manager';`);
  console.log();
  
  console.log(`-- Update user password`);
  console.log(`UPDATE users SET password_hash = '${userHash}' WHERE username LIKE 'user%';`);
}

// Run if called directly
if (require.main === module) {
  generateHashes().catch(console.error);
}

module.exports = { generateHashes };