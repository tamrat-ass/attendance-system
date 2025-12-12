import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import bcrypt from 'bcryptjs';

export async function POST(request: NextRequest) {
  try {
    const { username, password } = await request.json();

    console.log('=== LOGIN DEBUG ANALYSIS ===');
    console.log('Input:', { username, password });

    // Step 1: Test database connection
    console.log('Step 1: Testing database connection...');
    const [testResult]: any = await db.query('SELECT 1 as test');
    console.log('Database connection:', testResult);

    // Step 2: Find user
    console.log('Step 2: Finding user...');
    const query = 'SELECT * FROM users WHERE username = ?';
    console.log('Query:', query);
    console.log('Params:', [username]);
    
    const [users]: any = await db.query(query, [username]);
    console.log('Users found:', users.length);
    
    if (users.length === 0) {
      return NextResponse.json({
        success: false,
        debug: {
          step: 'user_not_found',
          query: query,
          params: [username],
          usersFound: 0
        }
      });
    }

    const user = users[0];
    console.log('User data:', {
      id: user.id,
      username: user.username,
      hasPasswordHash: !!user.password_hash,
      passwordHashValue: user.password_hash,
      passwordHashLength: user.password_hash?.length,
      passwordHashType: typeof user.password_hash
    });

    // Step 3: Password analysis
    console.log('Step 3: Password analysis...');
    const passwordHash = user.password_hash;
    
    // Check if it's a bcrypt hash (starts with $2a$, $2b$, etc.)
    const isBcryptHash = passwordHash && passwordHash.match(/^\$2[aby]\$/);
    console.log('Is bcrypt hash:', isBcryptHash);
    
    let passwordResult = {
      method: '',
      success: false,
      error: null
    };

    if (isBcryptHash) {
      // Try bcrypt comparison
      console.log('Trying bcrypt comparison...');
      try {
        const isValid = await bcrypt.compare(password, passwordHash);
        passwordResult = {
          method: 'bcrypt',
          success: isValid,
          error: null
        };
        console.log('Bcrypt result:', isValid);
      } catch (error) {
        passwordResult = {
          method: 'bcrypt',
          success: false,
          error: error.toString()
        };
        console.log('Bcrypt error:', error);
      }
    } else {
      // Try plain text comparison
      console.log('Trying plain text comparison...');
      const isValid = password === passwordHash;
      passwordResult = {
        method: 'plaintext',
        success: isValid,
        error: null
      };
      console.log('Plain text result:', isValid);
    }

    // Step 4: Return comprehensive debug info
    return NextResponse.json({
      success: passwordResult.success,
      debug: {
        step: 'password_verification',
        user: {
          id: user.id,
          username: user.username,
          full_name: user.full_name,
          role: user.role
        },
        password: {
          inputPassword: password,
          storedHash: passwordHash,
          hashLength: passwordHash?.length,
          isBcryptHash: !!isBcryptHash,
          verificationMethod: passwordResult.method,
          verificationSuccess: passwordResult.success,
          verificationError: passwordResult.error
        },
        database: {
          query: query,
          params: [username],
          usersFound: users.length
        }
      },
      user: passwordResult.success ? {
        id: user.id,
        username: user.username,
        full_name: user.full_name,
        role: user.role
      } : null
    });

  } catch (error: any) {
    console.error('Debug login error:', error);
    return NextResponse.json({
      success: false,
      debug: {
        step: 'error',
        error: error.message,
        stack: error.stack
      }
    }, { status: 500 });
  }
}