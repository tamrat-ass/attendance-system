import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// Refresh user permissions from database
export async function POST(request: NextRequest) {
  try {
    const { user_id } = await request.json();

    if (!user_id) {
      return NextResponse.json(
        { success: false, message: 'user_id is required' },
        { status: 400 }
      );
    }

    // Fetch latest permissions from database
    const [users]: any = await db.query(
      `SELECT id, username, email, full_name, role, status,
       can_manage_students, can_add_student, can_update_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data,
       can_manage_users, can_delete_user, can_manage_passwords
       FROM users WHERE id = ? AND status = 'active'`,
      [user_id]
    );

    if (users.length === 0) {
      return NextResponse.json(
        { success: false, message: 'User not found or inactive' },
        { status: 404 }
      );
    }

    const user = users[0];

    return NextResponse.json({
      success: true,
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
    console.error('Refresh permissions error:', error);
    return NextResponse.json(
      { success: false, message: 'Failed to refresh permissions' },
      { status: 500 }
    );
  }
}
