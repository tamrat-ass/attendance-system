import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import bcrypt from 'bcryptjs';

export async function POST(request: NextRequest) {
  try {
    const { username, password } = await request.json();

    console.log('Test login attempt:', { username, password });

    // Validate required fields
    if (!username || !password) {
      return NextResponse.json(
        { success: false, message: 'Username and password are required' },
        { status: 400 }
      );
    }

    // Find user by username (no status check)
    const [users]: any = await db.query(
      'SELECT * FROM users WHERE username = ?',
      [username]
    );

    console.log('Users found:', users.length);

    if (users.length === 0) {
      return NextResponse.json(
        { success: false, message: 'User not found' },
        { status: 401 }
      );
    }

    const user = users[0];
    console.log('User data:', { 
      id: user.id, 
      username: user.username, 
      hasPasswordHash: !!user.password_hash,
      passwordHashLength: user.password_hash?.length 
    });

    // Check if password is plain text or hashed
    if (user.password_hash && user.password_hash.length > 50) {
      // Hashed password - use bcrypt
      const isPasswordValid = await bcrypt.compare(password, user.password_hash);
      if (!isPasswordValid) {
        return NextResponse.json(
          { success: false, message: 'Invalid password (hashed)' },
          { status: 401 }
        );
      }
    } else {
      // Plain text password - direct comparison
      if (password !== user.password_hash) {
        return NextResponse.json(
          { success: false, message: 'Invalid password (plain text)' },
          { status: 401 }
        );
      }
    }

    // Return user data (excluding password)
    const { password_hash, ...userWithoutPassword } = user;

    return NextResponse.json({
      success: true,
      message: 'Login successful',
      user: userWithoutPassword,
      debug: {
        passwordType: user.password_hash?.length > 50 ? 'hashed' : 'plain',
        passwordLength: user.password_hash?.length
      }
    });

  } catch (error: any) {
    console.error('Test login error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Login failed', error: error.toString() },
      { status: 500 }
    );
  }
}