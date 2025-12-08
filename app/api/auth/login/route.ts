import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

export async function POST(request: NextRequest) {
  try {
    const { username, password } = await request.json();

    if (!username || !password) {
      return NextResponse.json(
        { success: false, message: 'Username and password are required' },
        { status: 400 }
      );
    }

    // Query user from database
    const [users]: any = await db.query(
      `SELECT id, username, email, full_name, role, status,
       can_manage_students, can_add_student, can_update_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data,
       can_manage_users, can_delete_user, can_manage_passwords
       FROM users WHERE username = ? AND password_hash = ? AND status = ?`,
      [username, password, 'active']
    );

    if (users.length === 0) {
      return NextResponse.json(
        { success: false, message: 'Invalid username or password' },
        { status: 401 }
      );
    }

    const user = users[0];

    // Log the login action
    try {
      const ip_address = request.headers.get('x-forwarded-for') || 
                         request.headers.get('x-real-ip') || 
                         'unknown';
      
      await db.query(
        `INSERT INTO user_logs (user_id, username, action, details, ip_address) 
         VALUES (?, ?, ?, ?, ?)`,
        [user.id, user.username, 'LOGIN', `User logged in (${user.role})`, ip_address]
      );
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
      { success: false, message: 'Login failed' },
      { status: 500 }
    );
  }
}
