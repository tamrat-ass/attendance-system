import { NextRequest, NextResponse } from 'next/server';
import { sql } from '@vercel/postgres';
import bcrypt from 'bcryptjs';

export async function POST(request: NextRequest) {
  try {
    const { username, password } = await request.json();

    if (!username || !password) {
      return NextResponse.json(
        { success: false, message: 'Username and password are required' },
        { status: 400 }
      );
    }

    // First check if username exists
    const userCheck = await sql`
      SELECT id, username, password_hash, status FROM users WHERE username = ${username}
    `;

    if (userCheck.rows.length === 0) {
      return NextResponse.json(
        { success: false, message: 'You entered wrong username' },
        { status: 401 }
      );
    }

    const userRecord = userCheck.rows[0];

    // Check if user is active
    if (userRecord.status !== 'active') {
      return NextResponse.json(
        { success: false, message: 'Account is not active. Please contact administrator.' },
        { status: 401 }
      );
    }

    // Check password using bcrypt
    const passwordMatch = await bcrypt.compare(password, userRecord.password_hash);
    if (!passwordMatch) {
      return NextResponse.json(
        { success: false, message: 'You entered wrong password' },
        { status: 401 }
      );
    }

    // Get full user details for successful login
    const result = await sql`
      SELECT id, username, email, full_name, role, status,
       can_manage_students, can_add_student, can_update_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data,
       can_manage_users, can_delete_user, can_manage_passwords
       FROM users WHERE username = ${username} AND status = 'active'
    `;

    const user = result.rows[0];

    // Log the login action
    try {
      const ip_address = request.headers.get('x-forwarded-for') || 
                         request.headers.get('x-real-ip') || 
                         'unknown';
      
      await sql`
        INSERT INTO user_logs (user_id, username, action, details, ip_address) 
        VALUES (${user.id}, ${user.username}, 'LOGIN', ${`User logged in (${user.role})`}, ${ip_address})
      `;
    } catch (logError) {
      console.error('Failed to log login:', logError);
    }

    return NextResponse.json({
      success: true,
      message: 'Login successful',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        full_name: user.full_name,
        role: user.role,
        can_manage_students: Boolean(user.can_manage_students),
        can_add_student: Boolean(user.can_add_student),
        can_update_student: Boolean(user.can_update_student),
        can_upload_students: Boolean(user.can_upload_students),
        can_delete_student: Boolean(user.can_delete_student),
        can_mark_attendance: Boolean(user.can_mark_attendance),
        can_view_reports: Boolean(user.can_view_reports),
        can_export_data: Boolean(user.can_export_data),
        can_manage_users: Boolean(user.can_manage_users),
        can_delete_user: Boolean(user.can_delete_user),
        can_manage_passwords: Boolean(user.can_manage_passwords)
      }
    });
  } catch (error: any) {
    console.error('Login error:', error);
    return NextResponse.json(
      { success: false, message: 'Login failed - updated' },
      { status: 500 }
    );
  }
}
