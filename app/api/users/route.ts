import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import bcrypt from 'bcryptjs';

// GET all users
export async function GET() {
  try {
    const [users]: any = await db.query(`
      SELECT 
        id, 
        username, 
        full_name, 
        role, 
        status,
        created_at,
        updated_at
      FROM users 
      ORDER BY created_at DESC
    `);

    return NextResponse.json({
      success: true,
      data: users
    });
  } catch (error: any) {
    console.error('Get users error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to fetch users' },
      { status: 500 }
    );
  }
}

// POST create new user
export async function POST(request: NextRequest) {
  try {
    const { username, full_name, password, role = 'user' } = await request.json();

    // Validate required fields
    if (!username || !full_name || !password) {
      return NextResponse.json(
        { success: false, message: 'Username, full name, and password are required' },
        { status: 400 }
      );
    }

    // Check if username already exists
    const [existingUser]: any = await db.query(
      'SELECT id FROM users WHERE username = ?',
      [username]
    );

    if (existingUser.length > 0) {
      return NextResponse.json(
        { success: false, message: 'Username already exists' },
        { status: 400 }
      );
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert new user
    const [result]: any = await db.query(
      `INSERT INTO users (username, full_name, password, role, status) 
       VALUES (?, ?, ?, ?, 'active')`,
      [username, full_name, hashedPassword, role]
    );

    // Get the created user
    const [newUser]: any = await db.query(
      `SELECT id, username, full_name, role, status, created_at 
       FROM users WHERE id = ?`,
      [result.insertId]
    );

    return NextResponse.json({
      success: true,
      message: 'User created successfully',
      data: newUser[0]
    });
  } catch (error: any) {
    console.error('Create user error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to create user' },
      { status: 500 }
    );
  }
}