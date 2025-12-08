import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// GET all users
export async function GET(request: NextRequest) {
  try {
    const [rows]: any = await db.query(
      `SELECT id, username, email, full_name, role, status, 
       can_manage_students, can_add_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data, 
       can_manage_users, can_delete_user, can_manage_passwords, created_at 
       FROM users ORDER BY created_at DESC`
    );

    // Convert 0/1 to boolean for frontend
    const users = rows.map((user: any) => ({
      ...user,
      can_manage_students: Boolean(user.can_manage_students),
      can_add_student: Boolean(user.can_add_student),
      can_upload_students: Boolean(user.can_upload_students),
      can_delete_student: Boolean(user.can_delete_student),
      can_mark_attendance: Boolean(user.can_mark_attendance),
      can_view_reports: Boolean(user.can_view_reports),
      can_export_data: Boolean(user.can_export_data),
      can_manage_users: Boolean(user.can_manage_users),
      can_delete_user: Boolean(user.can_delete_user),
      can_manage_passwords: Boolean(user.can_manage_passwords)
    }));

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

// POST - Create new user
export async function POST(request: NextRequest) {
  try {
    const { 
      username, email, full_name, password, role, status,
      can_manage_students, can_add_student, can_upload_students, can_delete_student,
      can_mark_attendance, can_view_reports, can_export_data, 
      can_manage_users, can_delete_user, can_manage_passwords
    } = await request.json();

    if (!username || !email || !password) {
      return NextResponse.json(
        { success: false, message: 'Username, email, and password are required' },
        { status: 400 }
      );
    }

    // Check if username or email already exists
    const [existing]: any = await db.query(
      'SELECT id FROM users WHERE username = ? OR email = ?',
      [username, email]
    );

    if (existing.length > 0) {
      return NextResponse.json(
        { success: false, message: 'Username or email already exists' },
        { status: 400 }
      );
    }

    // Insert new user (in production, hash the password!)
    const [result] = await db.query(
      `INSERT INTO users (username, email, full_name, password_hash, role, status,
       can_manage_students, can_add_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data, 
       can_manage_users, can_delete_user, can_manage_passwords) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        username, email, full_name || null, password, role || 'user', status || 'active',
        can_manage_students ?? true, can_add_student ?? true, can_upload_students ?? true, can_delete_student ?? false,
        can_mark_attendance ?? true, can_view_reports ?? false, can_export_data ?? false,
        can_manage_users ?? false, can_delete_user ?? false, can_manage_passwords ?? false
      ]
    );

    return NextResponse.json({
      success: true,
      message: 'User created successfully',
      data: {
        id: (result as any).insertId,
        username,
        email,
        full_name,
        role: role || 'user',
        status: status || 'active'
      }
    });
  } catch (error: any) {
    console.error('Create user error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to create user' },
      { status: 500 }
    );
  }
}
