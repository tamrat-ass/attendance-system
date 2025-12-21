import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import bcrypt from 'bcryptjs';

// GET all users - Fixed can_update_student permission
export async function GET(request: NextRequest) {
  try {
    const [rows]: any = await db.query(
      `SELECT id, username, email, full_name, role, status, 
       can_manage_students, can_add_student, can_update_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data, 
       can_manage_users, can_delete_user, can_manage_passwords, created_at 
       FROM users ORDER BY created_at DESC`
    );

    // Convert 0/1 to boolean for frontend
    const users = rows.map((user: any) => ({
      ...user,
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
      can_manage_students, can_add_student, can_update_student, can_upload_students, can_delete_student,
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

    // Hash the password before storing
    const hashedPassword = await bcrypt.hash(password, 12);

    // Set default permissions based on role
    const userRole = role || 'user';
    const defaultPermissions = {
      can_add_student: can_add_student ?? true,
      can_update_student: can_update_student ?? true,
      can_upload_students: can_upload_students ?? (userRole === 'admin' || userRole === 'manager'),
      can_delete_student: can_delete_student ?? (userRole === 'admin'),
      can_mark_attendance: can_mark_attendance ?? true,
      can_view_reports: can_view_reports ?? (userRole === 'admin' || userRole === 'manager'),
      can_export_data: can_export_data ?? (userRole === 'admin' || userRole === 'manager'),
      can_manage_users: can_manage_users ?? (userRole === 'admin'),
      can_delete_user: can_delete_user ?? (userRole === 'admin'),
      can_manage_passwords: can_manage_passwords ?? (userRole === 'admin')
    };

    // Insert new user with hashed password
    const [result] = await db.query(
      `INSERT INTO users (username, email, full_name, password_hash, role, status,
       can_add_student, can_update_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data, 
       can_manage_users, can_delete_user, can_manage_passwords) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        username, email, full_name || null, hashedPassword, userRole, status || 'active',
        defaultPermissions.can_add_student ? 1 : 0,
        defaultPermissions.can_update_student ? 1 : 0,
        defaultPermissions.can_upload_students ? 1 : 0,
        defaultPermissions.can_delete_student ? 1 : 0,
        defaultPermissions.can_mark_attendance ? 1 : 0,
        defaultPermissions.can_view_reports ? 1 : 0,
        defaultPermissions.can_export_data ? 1 : 0,
        defaultPermissions.can_manage_users ? 1 : 0,
        defaultPermissions.can_delete_user ? 1 : 0,
        defaultPermissions.can_manage_passwords ? 1 : 0
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
